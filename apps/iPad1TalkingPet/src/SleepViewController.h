#import <UIKit/UIKit.h>
@class PetNeedsManager;
@class PetProgressManager;

@interface SleepViewController : UIViewController {
    PetNeedsManager *_needs;
    PetProgressManager *_progress;
    UIView *_room;
    UILabel *_status;
    UIButton *_lampButton;
    BOOL _lightsOff;
}
- (id)initWithNeeds:(PetNeedsManager *)needs progress:(PetProgressManager *)progress;
@end
