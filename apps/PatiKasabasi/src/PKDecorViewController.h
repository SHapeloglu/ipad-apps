#import "PKBaseViewController.h"

@class PKGameState;

@interface PKDecorViewController : PKBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    PKGameState *_gameState;
    UITableView *_tableView;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
