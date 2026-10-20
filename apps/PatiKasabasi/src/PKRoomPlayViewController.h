#import "PKBaseViewController.h"

@class PKGameState;
@class PKRoomBackgroundView;
@class PKPetAvatarView;
@class PKActionPropView;
@class PKThoughtBubbleView;

@interface PKRoomPlayViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKRoomBackgroundView *_roomView;
    UIView *_avatarMotionView;
    PKPetAvatarView *_avatarView;
    PKActionPropView *_effectPropView;
    PKThoughtBubbleView *_thoughtBubbleView;
    CGPoint _avatarHomeCenter;
    NSString *_dragItemIdentifier;
    NSString *_activeVisualActionIdentifier;
    NSString *_activeRoomItemIdentifier;
    BOOL _pendingAutonomousMoment;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
