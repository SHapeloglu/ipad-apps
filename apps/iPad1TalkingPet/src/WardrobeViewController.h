#import <UIKit/UIKit.h>
@class PetProgressManager;

@interface WardrobeViewController : UIViewController {
    PetProgressManager *_progress;
    UILabel *_coinLabel;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
