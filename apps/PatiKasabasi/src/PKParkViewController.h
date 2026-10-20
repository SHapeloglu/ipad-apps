#import "PKBaseViewController.h"

@class PKGameState;
@class PKActivitySceneView;
@class PKPetAvatarView;

@interface PKParkViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKActivitySceneView *_sceneView;
    UIView *_petMotionView;
    PKPetAvatarView *_petAvatarView;
    NSArray *_neighborButtons;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
    UILabel *_requestLabel;
    UIButton *_requestButton;
    CGPoint _petHomeCenter;
    NSInteger _dragTargetIndex;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
