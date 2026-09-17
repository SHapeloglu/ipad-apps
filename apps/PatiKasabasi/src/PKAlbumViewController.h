#import "PKBaseViewController.h"

@class PKGameState;

@interface PKAlbumViewController : PKBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    PKGameState *_gameState;
    UITableView *_tableView;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
