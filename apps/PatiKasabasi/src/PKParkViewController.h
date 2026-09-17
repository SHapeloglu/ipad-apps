#import "PKBaseViewController.h"

@class PKGameState;

@interface PKParkViewController : PKBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    PKGameState *_gameState;
    UITableView *_tableView;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
    UILabel *_requestLabel;
    UIButton *_requestButton;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
