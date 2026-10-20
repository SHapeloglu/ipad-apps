#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol PetAudioManagerDelegate <NSObject>
- (void)petAudioDidFinishRepeat;
@end

@interface PetAudioManager : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    id<PetAudioManagerDelegate> _delegate;
    BOOL _recording;
}
@property (nonatomic, assign) id<PetAudioManagerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL recording;

- (BOOL)startRecording;
- (void)stopAndRepeat;
- (void)stopAll;
@end
