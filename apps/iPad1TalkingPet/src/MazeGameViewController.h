#import <UIKit/UIKit.h>
@class PetProgressManager;
@interface MazeGameViewController : UIViewController {
    PetProgressManager *_progress;
    UIView *_player;
    UILabel *_status;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
