#import "PKBaseViewController.h"

@class PKGameState;

@interface PKSkillsViewController : PKBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    PKGameState *_gameState;
    UITableView *_tableView;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
    UIBarButtonItem *_requestButton;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
