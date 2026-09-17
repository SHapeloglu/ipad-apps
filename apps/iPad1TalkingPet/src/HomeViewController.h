#import <UIKit/UIKit.h>
#import "PetAudioManager.h"

@class PetNeedsManager;
@class PetProgressManager;
@class PetAnimator;
@class PetAccessoryView;

@interface HomeViewController : UIViewController <PetAudioManagerDelegate> {
    UIImageView *_backgroundView;
    UIView *_themeOverlay;
    PetAccessoryView *_accessoryView;
    PetNeedsManager *_needs;
    PetProgressManager *_progress;
    PetAudioManager *_audio;
    PetAnimator *_animator;

    UIProgressView *_hungerBar;
    UIProgressView *_happinessBar;
    UIProgressView *_hygieneBar;
    UIProgressView *_energyBar;
    UIProgressView *_xpBar;

    UILabel *_coinLabel;
    UILabel *_levelLabel;
    UILabel *_speechLabel;
    UIButton *_talkButton;
    UIButton *_decorButton;
    NSTimer *_decayTimer;
}
@end
