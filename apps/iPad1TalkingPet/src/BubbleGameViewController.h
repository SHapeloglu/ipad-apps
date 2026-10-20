#import <UIKit/UIKit.h>
@class PetProgressManager;

@interface BubbleGameViewController : UIViewController {
    PetProgressManager *_progress;
    NSInteger _score;
    NSInteger _secondsLeft;
    UILabel *_scoreLabel;
    UILabel *_timeLabel;
    NSTimer *_timer;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
