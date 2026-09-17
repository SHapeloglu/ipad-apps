#import <UIKit/UIKit.h>
@class PetProgressManager;
@interface RunnerGameViewController : UIViewController {
    PetProgressManager *_progress;
    UIView *_runner;
    UIView *_obstacle;
    UILabel *_label;
    NSTimer *_timer;
    NSInteger _score;
    BOOL _jumping;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
