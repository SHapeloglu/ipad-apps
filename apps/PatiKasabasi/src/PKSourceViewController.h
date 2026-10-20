#import "PKBaseViewController.h"

@class PKGameState;

@interface PKSourceViewController : PKBaseViewController {
    PKGameState *_gameState;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
