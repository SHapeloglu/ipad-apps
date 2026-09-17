#import "PKBaseViewController.h"

@class PKGameState;
@class PKRoomBackgroundView;
@class PKPetAvatarView;

@interface PKRoomPlayViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKRoomBackgroundView *_roomView;
    UIView *_avatarMotionView;
    PKPetAvatarView *_avatarView;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
