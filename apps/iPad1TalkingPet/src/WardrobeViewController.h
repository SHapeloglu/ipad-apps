#import <UIKit/UIKit.h>
@class PetProgressManager;

@interface WardrobeViewController : UIViewController {
    PetProgressManager *_progress;
    UILabel *_coinLabel;
    UILabel *_selectedLabel;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
