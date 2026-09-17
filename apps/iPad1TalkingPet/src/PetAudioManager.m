#import "PetAudioManager.h"

@implementation PetAudioManager
@synthesize delegate = _delegate;
@synthesize recording = _recording;

- (NSString *)recordingPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"pet_repeat.caf"];
}

- (BOOL)startRecording {
    [self stopAll];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    [session setActive:YES error:&err];

    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
        [NSNumber numberWithFloat:22050.0f], AVSampleRateKey,
        [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
        nil];

    NSURL *url = [NSURL fileURLWithPath:[self recordingPath]];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
    if (!_recorder || err) {
        [_recorder release]; _recorder = nil;
        return NO;
    }

    _recorder.delegate = self;
    _recorder.meteringEnabled = NO;
    [_recorder prepareToRecord];
    _recording = [_recorder record];
    return _recording;
}

- (void)stopAndRepeat {
    if (!_recorder) return;
    [_recorder stop];
    _recording = NO;
    [_recorder release];
    _recorder = nil;

    NSError *err = nil;
    NSURL *url = [NSURL fileURLWithPath:[self recordingPath]];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (!_player || err) {
        [_player release]; _player = nil;
        if ([_delegate respondsToSelector:@selector(petAudioDidFinishRepeat)])
            [_delegate petAudioDidFinishRepeat];
        return;
    }

    _player.delegate = self;
    if ([_player respondsToSelector:@selector(setEnableRate:)]) {
        _player.enableRate = YES;
        if ([_player respondsToSelector:@selector(setRate:)]) _player.rate = 1.35f;
    }
    [_player prepareToPlay];
    [_player play];
}

- (void)stopAll {
    if (_recorder) {
        [_recorder stop];
        [_recorder release];
        _recorder = nil;
    }
    if (_player) {
        [_player stop];
        [_player release];
        _player = nil;
    }
    _recording = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_player release];
    _player = nil;
    if ([_delegate respondsToSelector:@selector(petAudioDidFinishRepeat)])
        [_delegate petAudioDidFinishRepeat];
}

- (void)dealloc {
    [self stopAll];
    [super dealloc];
}
@end
