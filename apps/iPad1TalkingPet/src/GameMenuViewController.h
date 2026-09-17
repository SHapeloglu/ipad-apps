#import <UIKit/UIKit.h>
@class PetProgressManager;

@interface GameMenuViewController : UIViewController {
    PetProgressManager *_progress;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
