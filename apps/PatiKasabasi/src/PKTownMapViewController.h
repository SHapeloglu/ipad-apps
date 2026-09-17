#import "PKBaseViewController.h"

@class PKGameState;
@class PKTownMapView;

@interface PKTownMapViewController : PKBaseViewController {
    PKGameState *_gameState;
    PKTownMapView *_mapView;
    UILabel *_statusLabel;
    UILabel *_requestLabel;
    NSArray *_locationButtons;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
