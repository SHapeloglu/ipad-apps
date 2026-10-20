#import <UIKit/UIKit.h>
@class PetProgressManager;
@interface BasketGameViewController : UIViewController {
    PetProgressManager *_progress;
    UIButton *_ball;
    UIView *_basket;
    UILabel *_scoreLabel;
    NSInteger _score;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
