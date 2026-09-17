#import <UIKit/UIKit.h>
@class PetProgressManager;
@interface TravelViewController : UIViewController {
    PetProgressManager *_progress;
    UILabel *_status;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
