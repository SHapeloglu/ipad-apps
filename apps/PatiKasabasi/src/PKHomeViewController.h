#import "PKBaseViewController.h"

@class PKGameState;
@class PKPetAvatarView;
@class PKNeedBarView;
@class PKRoomBackgroundView;
@class PKActionPropView;
@class PKThoughtBubbleView;
@class PKVoiceRepeatManager;

@interface PKHomeViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKRoomBackgroundView *_roomView;
    UIView *_avatarMotionView;
    PKPetAvatarView *_avatarView;
    NSArray *_actionButtons;
    UIView *_propPaletteView;
    NSArray *_propViews;
    NSArray *_foodChoiceButtons;
    NSString *_selectedFoodIdentifier;
    NSString *_activeFoodPreference;
    PKActionPropView *_activePropView;
    PKThoughtBubbleView *_thoughtBubbleView;
    CGPoint _propHomeCenters[3];
    CGPoint _avatarHomeCenter;
    NSInteger _dragActionIndex;
    NSString *_activeVisualActionIdentifier;
    BOOL _pendingAutonomousMoment;
    UILabel *_nameLabel;
    UILabel *_profileLabel;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
    UILabel *_questLabel;
    UIBarButtonItem *_soundButton;
    UIBarButtonItem *_voiceButton;
    PKVoiceRepeatManager *_voiceManager;
    PKNeedBarView *_satietyBar;
    PKNeedBarView *_energyBar;
    PKNeedBarView *_hygieneBar;
    PKNeedBarView *_funBar;
    PKNeedBarView *_socialBar;
    PKNeedBarView *_affectionBar;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
