#import "PKBaseViewController.h"

@class PKGameState;
@class PKPetAvatarView;
@class PKNeedBarView;
@class PKRoomBackgroundView;

@interface PKHomeViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKRoomBackgroundView *_roomView;
    UIView *_avatarMotionView;
    PKPetAvatarView *_avatarView;
    NSArray *_actionButtons;
    CGPoint _avatarHomeCenter;
    NSInteger _dragActionIndex;
    UILabel *_nameLabel;
    UILabel *_profileLabel;
    UILabel *_statusLabel;
    UILabel *_moodLabel;
    UILabel *_feedbackLabel;
    UILabel *_questLabel;
    UIBarButtonItem *_soundButton;
    PKNeedBarView *_satietyBar;
    PKNeedBarView *_energyBar;
    PKNeedBarView *_hygieneBar;
    PKNeedBarView *_funBar;
    PKNeedBarView *_socialBar;
    PKNeedBarView *_affectionBar;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
