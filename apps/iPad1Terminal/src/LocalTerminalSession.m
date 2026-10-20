#import "LocalTerminalSession.h"

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <termios.h>
#include <unistd.h>

static NSString * const LocalTerminalErrorDomain = @"com.olap.ipad1terminal.localpty";

enum {
    LocalTerminalErrorOpenPTMX = 1,
    LocalTerminalErrorGrantPT,
    LocalTerminalErrorUnlockPT,
    LocalTerminalErrorPTSName,
    LocalTerminalErrorFork,
    LocalTerminalErrorOpenSlave,
    LocalTerminalErrorExec
};

@interface LocalTerminalSession ()
- (void)readerMain;
- (void)deliverTextOnMainThread:(NSString *)text;
- (void)deliverExitOnMainThread;
- (void)deliverErrorOnMainThread:(NSError *)error;
- (NSError *)posixErrorWithCode:(NSInteger)code operation:(NSString *)operation;
- (NSString *)decodeAvailableUTF8;
@end

@implementation LocalTerminalSession

@synthesize delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
        _masterFD = -1;
        _childPID = -1;
        _running = NO;
        _readerThread = nil;
        _pendingUTF8 = [[NSMutableData alloc] init];
    }
    return self;
}

- (BOOL)isRunning
{
    return _running;
}

- (pid_t)childPID
{
    return _childPID;
}

- (NSError *)posixErrorWithCode:(NSInteger)code operation:(NSString *)operation
{
    NSString *message = [NSString stringWithFormat:@"%@ failed: %s",
                         operation, strerror(errno)];
    NSDictionary *info = [NSDictionary dictionaryWithObject:message
                                                     forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:LocalTerminalErrorDomain
                               code:code
                           userInfo:info];
}

- (BOOL)startWithError:(NSError **)error
{
    if (_running) {
        return YES;
    }

    int master = posix_openpt(O_RDWR | O_NOCTTY);
    if (master < 0) {
        if (error) *error = [self posixErrorWithCode:LocalTerminalErrorOpenPTMX
                                           operation:@"posix_openpt"];
        return NO;
    }

    if (grantpt(master) != 0) {
        if (error) *error = [self posixErrorWithCode:LocalTerminalErrorGrantPT
                                           operation:@"grantpt"];
        close(master);
        return NO;
    }

    if (unlockpt(master) != 0) {
        if (error) *error = [self posixErrorWithCode:LocalTerminalErrorUnlockPT
                                           operation:@"unlockpt"];
        close(master);
        return NO;
    }

    char *slaveName = ptsname(master);
    if (slaveName == NULL) {
        if (error) *error = [self posixErrorWithCode:LocalTerminalErrorPTSName
                                           operation:@"ptsname"];
        close(master);
        return NO;
    }

    pid_t pid = fork();
    if (pid < 0) {
        if (error) *error = [self posixErrorWithCode:LocalTerminalErrorFork
                                           operation:@"fork"];
        close(master);
        return NO;
    }

    if (pid == 0) {
        close(master);

        if (setsid() < 0) {
            _exit(126);
        }

        int slave = open(slaveName, O_RDWR);
        if (slave < 0) {
            _exit(126);
        }

        /*
         * TerminalInputView sends DEL (0x7F) for Backspace.
         * Make the PTY canonical erase character match it.
         */
        {
            struct termios tio;
            if (tcgetattr(slave, &tio) == 0) {
                tio.c_cc[VERASE] = 0x7F;
                tcsetattr(slave, TCSANOW, &tio);
            }
        }

#ifdef TIOCSCTTY
        ioctl(slave, TIOCSCTTY, 0);
#endif

        dup2(slave, STDIN_FILENO);
        dup2(slave, STDOUT_FILENO);
        dup2(slave, STDERR_FILENO);

        if (slave > STDERR_FILENO) {
            close(slave);
        }

        setenv("TERM", "vt100", 1);
        setenv("HOME", "/var/mobile", 1);
        setenv("SHELL", "/bin/sh", 1);

        chdir("/var/mobile");

        execl("/bin/sh", "sh", "-i", (char *)NULL);

        /* If /bin/sh is unexpectedly unavailable, try bash. */
        execl("/bin/bash", "bash", "-i", (char *)NULL);

        _exit(127);
    }

    _masterFD = master;
    _childPID = pid;
    _running = YES;

    int flags = fcntl(_masterFD, F_GETFL, 0);
    if (flags >= 0) {
        fcntl(_masterFD, F_SETFL, flags | O_NONBLOCK);
    }

    [_readerThread release];
    _readerThread = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(readerMain)
                                              object:nil];
    [_readerThread start];

    return YES;
}

- (BOOL)writeData:(NSData *)data
{
    if (!_running || _masterFD < 0 || [data length] == 0) {
        return NO;
    }

    const unsigned char *bytes = (const unsigned char *)[data bytes];
    NSUInteger total = [data length];
    NSUInteger offset = 0;

    while (offset < total && _running) {
        ssize_t written = write(_masterFD, bytes + offset, total - offset);
        if (written > 0) {
            offset += (NSUInteger)written;
        } else if (written < 0 && (errno == EINTR)) {
            continue;
        } else if (written < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
            usleep(1000);
        } else {
            return NO;
        }
    }

    return (offset == total);
}

- (BOOL)writeString:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self writeData:data];
}

- (void)resizeRows:(unsigned short)rows columns:(unsigned short)columns
{
    if (_masterFD < 0) {
        return;
    }

    struct winsize ws;
    memset(&ws, 0, sizeof(ws));
    ws.ws_row = rows;
    ws.ws_col = columns;
    ioctl(_masterFD, TIOCSWINSZ, &ws);

    if (_childPID > 0) {
        kill(_childPID, SIGWINCH);
    }
}

- (NSString *)decodeAvailableUTF8
{
    if ([_pendingUTF8 length] == 0) {
        return nil;
    }

    NSString *text = [[[NSString alloc] initWithData:_pendingUTF8
                                            encoding:NSUTF8StringEncoding] autorelease];
    if (text != nil) {
        [_pendingUTF8 setLength:0];
        return text;
    }

    /*
     * UTF-8 may be split across read() boundaries. Try keeping up to the
     * final 3 bytes for the next read, while decoding the valid prefix.
     */
    NSUInteger length = [_pendingUTF8 length];
    NSUInteger keep;
    for (keep = 1; keep <= 3 && keep < length; keep++) {
        NSUInteger prefixLength = length - keep;
        NSData *prefix = [_pendingUTF8 subdataWithRange:NSMakeRange(0, prefixLength)];
        NSString *prefixText = [[[NSString alloc] initWithData:prefix
                                                      encoding:NSUTF8StringEncoding] autorelease];
        if (prefixText != nil) {
            NSData *suffix = [_pendingUTF8 subdataWithRange:NSMakeRange(prefixLength, keep)];
            [_pendingUTF8 setData:suffix];
            return prefixText;
        }
    }

    /*
     * Avoid unbounded accumulation on non-UTF8 byte streams.
     * Fall back to ISO Latin-1 for what we have.
     */
    if (length > 4096) {
        NSString *fallback = [[[NSString alloc] initWithData:_pendingUTF8
                                                    encoding:NSISOLatin1StringEncoding] autorelease];
        [_pendingUTF8 setLength:0];
        return fallback;
    }

    return nil;
}

- (void)readerMain
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    unsigned char buffer[2048];

    while (_running && _masterFD >= 0) {
        fd_set readSet;
        FD_ZERO(&readSet);
        FD_SET(_masterFD, &readSet);

        struct timeval timeout;
        timeout.tv_sec = 0;
        timeout.tv_usec = 250000;

        int ready = select(_masterFD + 1, &readSet, NULL, NULL, &timeout);

        if (!_running) {
            break;
        }

        if (ready > 0 && FD_ISSET(_masterFD, &readSet)) {
            ssize_t count = read(_masterFD, buffer, sizeof(buffer));

            if (count > 0) {
                [_pendingUTF8 appendBytes:buffer length:(NSUInteger)count];
                NSString *text = [self decodeAvailableUTF8];
                if (text && [text length] > 0) {
                    [self performSelectorOnMainThread:@selector(deliverTextOnMainThread:)
                                           withObject:text
                                        waitUntilDone:NO];
                }
            } else if (count == 0) {
                break;
            } else if (errno != EINTR && errno != EAGAIN && errno != EWOULDBLOCK) {
                NSError *readError = [self posixErrorWithCode:errno operation:@"read"];
                [self performSelectorOnMainThread:@selector(deliverErrorOnMainThread:)
                                       withObject:readError
                                    waitUntilDone:NO];
                break;
            }
        } else if (ready < 0 && errno != EINTR) {
            NSError *selectError = [self posixErrorWithCode:errno operation:@"select"];
            [self performSelectorOnMainThread:@selector(deliverErrorOnMainThread:)
                                   withObject:selectError
                                waitUntilDone:NO];
            break;
        }

        int status = 0;
        pid_t result = waitpid(_childPID, &status, WNOHANG);
        if (result == _childPID) {
            break;
        }

        [pool drain];
        pool = [[NSAutoreleasePool alloc] init];
    }

    if (_running) {
        _running = NO;
        [self performSelectorOnMainThread:@selector(deliverExitOnMainThread)
                               withObject:nil
                            waitUntilDone:NO];
    }

    [pool drain];
}

- (void)deliverTextOnMainThread:(NSString *)text
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(localTerminalSession:didReceiveText:)]) {
        [_delegate localTerminalSession:self didReceiveText:text];
    }
}

- (void)deliverExitOnMainThread
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(localTerminalSessionDidExit:)]) {
        [_delegate localTerminalSessionDidExit:self];
    }
}

- (void)deliverErrorOnMainThread:(NSError *)error
{
    if (_delegate &&
        [_delegate respondsToSelector:@selector(localTerminalSession:didFailWithError:)]) {
        [_delegate localTerminalSession:self didFailWithError:error];
    }
}

- (void)stop
{
    if (!_running && _masterFD < 0 && _childPID <= 0) {
        return;
    }

    _running = NO;

    if (_childPID > 0) {
        kill(_childPID, SIGHUP);
        usleep(100000);

        int status = 0;
        pid_t result = waitpid(_childPID, &status, WNOHANG);
        if (result == 0) {
            kill(_childPID, SIGTERM);
            usleep(100000);
            result = waitpid(_childPID, &status, WNOHANG);
        }
        if (result == 0) {
            kill(_childPID, SIGKILL);
            waitpid(_childPID, &status, 0);
        }
    }

    if (_masterFD >= 0) {
        close(_masterFD);
        _masterFD = -1;
    }

    _childPID = -1;
}

- (void)dealloc
{
    _delegate = nil;
    [self stop];

    [_readerThread release];
    [_pendingUTF8 release];

    [super dealloc];
}

@end
