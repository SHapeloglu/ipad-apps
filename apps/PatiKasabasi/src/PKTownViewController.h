#import "PKBaseViewController.h"

@class PKGameState;
@class PKActivitySceneView;
@class PKPetAvatarView;

@interface PKTownViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKActivitySceneView *_sceneView;
    UIView *_petMotionView;
    PKPetAvatarView *_petAvatarView;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
    UILabel *_requestLabel;
    UIButton *_eventButton;
    UIButton *_requestButton;
    CGPoint _petHomeCenter;
    NSInteger _dragTargetIndex;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
