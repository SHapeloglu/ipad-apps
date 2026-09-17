#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface KaraokeViewController : UIViewController <AVAudioPlayerDelegate> {
    AVAudioPlayer *_audioPlayer;
    UILabel *_titleLabel;
    UILabel *_lyricLabel;
    UILabel *_timeLabel;
    UIButton *_playPauseButton;
    UISlider *_progressSlider;
    NSTimer *_timer;
    NSArray *_lyrics;
    NSInteger _currentLyricIndex;
}
@end
