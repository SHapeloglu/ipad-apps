#import <UIKit/UIKit.h>
@class PetProgressManager;
@interface MatchGameViewController : UIViewController {
    PetProgressManager *_progress;
    UILabel *_status;
    NSInteger _score;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
