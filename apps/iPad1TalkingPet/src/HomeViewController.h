#import <UIKit/UIKit.h>
#import "PetAudioManager.h"

@class PetNeedsManager;
@class PetProgressManager;

@interface HomeViewController : UIViewController <PetAudioManagerDelegate> {
    UIImageView *_backgroundView;
    PetNeedsManager *_needs;
    PetProgressManager *_progress;
    PetAudioManager *_audio;

    UIProgressView *_hungerBar;
    UIProgressView *_happinessBar;
    UIProgressView *_hygieneBar;
    UIProgressView *_energyBar;
    UIProgressView *_xpBar;

    UILabel *_coinLabel;
    UILabel *_levelLabel;
    UILabel *_speechLabel;

    UIButton *_talkButton;
    NSTimer *_idleTimer;
    NSTimer *_decayTimer;
}
@end
