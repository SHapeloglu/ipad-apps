#import "PKBaseViewController.h"

@class PKGameState;

@interface PKTownViewController : PKBaseViewController {
    PKGameState *_gameState;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
    UILabel *_requestLabel;
    UIButton *_requestButton;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
