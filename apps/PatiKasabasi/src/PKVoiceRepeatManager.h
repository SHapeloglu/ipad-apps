#import <Foundation/Foundation.h>

@class AVAudioRecorder;
@class AVAudioPlayer;

@interface PKVoiceRepeatManager : NSObject {
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    NSURL *_recordingURL;
}

- (BOOL)startRecording;
- (BOOL)stopRecordingAndPlay;
- (void)cancel;
- (BOOL)isRecording;

@end
