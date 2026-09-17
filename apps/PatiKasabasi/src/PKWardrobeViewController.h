#import "PKBaseViewController.h"

@class PKGameState;
@class PKPetAvatarView;

@interface PKWardrobeViewController : PKBaseViewController <UITableViewDataSource, UITableViewDelegate> {
    PKGameState *_gameState;
    PKPetAvatarView *_avatarView;
    UITableView *_tableView;
    UILabel *_statusLabel;
    UILabel *_feedbackLabel;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
