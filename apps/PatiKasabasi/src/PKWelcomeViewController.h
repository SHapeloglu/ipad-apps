#import "PKBaseViewController.h"

@class PKGameState;

@interface PKWelcomeViewController : PKBaseViewController <UIAlertViewDelegate> {
    PKGameState *_gameState;
    UIButton *_continueButton;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
