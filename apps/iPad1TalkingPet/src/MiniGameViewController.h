#import <UIKit/UIKit.h>
@class PetProgressManager;

@interface MiniGameViewController : UIViewController {
    PetProgressManager *_progress;
    UILabel *_scoreLabel;
    UILabel *_timeLabel;
    UIButton *_targetButton;
    NSInteger _score;
    NSInteger _secondsLeft;
    NSTimer *_timer;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
