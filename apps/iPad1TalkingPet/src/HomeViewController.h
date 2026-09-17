#import <UIKit/UIKit.h>
#import "PetAudioManager.h"

@class PetNeedsManager;
@class PetProgressManager;
@class RoomBackgroundView;
@class PetCharacterView;
@class LivingPetManager;

@interface HomeViewController : UIViewController <PetAudioManagerDelegate> {
    RoomBackgroundView *_roomView;
    PetCharacterView *_petView;
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
    NSTimer *_decayTimer;
    LivingPetManager *_livingPet;
}
@end
