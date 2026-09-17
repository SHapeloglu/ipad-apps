#import "PKBaseViewController.h"

@class PKGameState;
@class PKActivitySceneView;
@class PKPetAvatarView;

@interface PKSkillsViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKActivitySceneView *_sceneView;
    UIView *_petMotionView;
    PKPetAvatarView *_petAvatarView;
    NSArray *_activityButtons;
    UISegmentedControl *_modeControl;
    UIButton *_workButton;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
    UIBarButtonItem *_requestButton;
    CGPoint _petHomeCenter;
    NSInteger _dragTargetIndex;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
