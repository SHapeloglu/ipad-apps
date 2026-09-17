#import <UIKit/UIKit.h>
@class PetProgressManager;

@interface FoodCatchViewController : UIViewController {
    PetProgressManager *_progress;
    UIButton *_food;
    UIButton *_basket;
    UILabel *_label;
    NSTimer *_timer;
    NSInteger _score;
    NSInteger _ticks;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
