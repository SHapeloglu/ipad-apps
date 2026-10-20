#import "PKVoiceRepeatManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation PKVoiceRepeatManager

- (id)init {
    self = [super init];
    if (self) {
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"pati-ses.caf"];
        _recordingURL = [[NSURL fileURLWithPath:path] retain];
    }
    return self;
}

- (BOOL)startRecording {
    [self cancel];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) return NO;
    if (![session setActive:YES error:&error]) return NO;

    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInt:kAudioFormatAppleIMA4], AVFormatIDKey,
        [NSNumber numberWithFloat:22050.0f], AVSampleRateKey,
        [NSNumber numberWithInteger:1], AVNumberOfChannelsKey,
        [NSNumber numberWithInteger:AVAudioQualityLow], AVEncoderAudioQualityKey,
        nil];
    _recorder = [[AVAudioRecorder alloc] initWithURL:_recordingURL settings:settings error:&error];
    if (!_recorder || ![_recorder prepareToRecord] || ![_recorder record]) {
        [_recorder release];
        _recorder = nil;
        [session setActive:NO error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[_recordingURL path] error:nil];
        return NO;
    }
    return YES;
}

- (BOOL)stopRecordingAndPlay {
    if (!_recorder || ![_recorder isRecording]) return NO;
    [_recorder stop];
    [_recorder release];
    _recorder = nil;

    NSError *error = nil;
    [_player release];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordingURL error:&error];
    if (!_player || ![_player prepareToPlay]) {
        [_player release];
        _player = nil;
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        return NO;
    }
    _player.volume = 1.0f;
    return [_player play];
}

- (void)cancel {
    if ([_recorder isRecording]) [_recorder stop];
    if ([_player isPlaying]) [_player stop];
    [_recorder release];
    _recorder = nil;
    [_player release];
    _player = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    if (_recordingURL) [[NSFileManager defaultManager] removeItemAtPath:[_recordingURL path] error:nil];
}

- (BOOL)isRecording {
    return (_recorder && [_recorder isRecording]);
}

- (void)dealloc {
    [self cancel];
    [_recordingURL release];
    [super dealloc];
}

@end
