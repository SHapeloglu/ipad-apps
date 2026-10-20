#import <Foundation/Foundation.h>
#import <sys/types.h>

@protocol LocalTerminalSessionDelegate;

@interface LocalTerminalSession : NSObject
{
    int _masterFD;
    pid_t _childPID;
    NSThread *_readerThread;
    BOOL _running;
    id<LocalTerminalSessionDelegate> _delegate;

    NSMutableData *_pendingUTF8;
}

@property (nonatomic, assign) id<LocalTerminalSessionDelegate> delegate;
@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, readonly) pid_t childPID;

- (BOOL)startWithError:(NSError **)error;
- (void)stop;
- (BOOL)writeData:(NSData *)data;
- (BOOL)writeString:(NSString *)string;
- (void)resizeRows:(unsigned short)rows columns:(unsigned short)columns;

@end

@protocol LocalTerminalSessionDelegate <NSObject>
- (void)localTerminalSession:(LocalTerminalSession *)session
             didReceiveText:(NSString *)text;
- (void)localTerminalSessionDidExit:(LocalTerminalSession *)session;
- (void)localTerminalSession:(LocalTerminalSession *)session
            didFailWithError:(NSError *)error;
@end
