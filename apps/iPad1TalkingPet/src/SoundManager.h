#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundManager : NSObject <AVAudioPlayerDelegate> {
    NSMutableDictionary *_players;
    AVAudioPlayer *_musicPlayer;
}
+ (SoundManager *)sharedManager;
- (void)play:(NSString *)name;
- (void)startMusic;
- (void)stopMusic;
- (BOOL)musicEnabled;
- (void)setMusicEnabled:(BOOL)enabled;
@end
