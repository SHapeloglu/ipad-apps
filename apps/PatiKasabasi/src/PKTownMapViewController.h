#import "PKBaseViewController.h"

@class PKGameState;
@class PKTownMapView;
@class PKPetAvatarView;

@interface PKTownMapViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKTownMapView *_mapView;
    UILabel *_statusLabel;
    UILabel *_requestLabel;
    NSArray *_locationButtons;
    NSArray *_ambientViews;
    UIView *_petTokenView;
    PKPetAvatarView *_petTokenAvatar;
    CGPoint _petHomeCenter;
    NSInteger _dragTargetTag;
    NSInteger _pendingDestinationTag;
    BOOL _openingDestination;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
