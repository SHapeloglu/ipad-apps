#import <UIKit/UIKit.h>
@class PetNeedsManager;
@class PetProgressManager;

@interface FoodViewController : UIViewController {
    PetNeedsManager *_needs;
    PetProgressManager *_progress;
    UILabel *_statusLabel;
    UIView *_mouthTarget;
    UIButton *_foodButton;
    CGPoint _foodHome;
    NSInteger _selectedFood;
}
- (id)initWithNeeds:(PetNeedsManager *)needs progress:(PetProgressManager *)progress;
@end
