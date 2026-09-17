#import <UIKit/UIKit.h>
@class PetNeedsManager;
@class PetProgressManager;

@interface BathViewController : UIViewController {
    PetNeedsManager *_needs;
    PetProgressManager *_progress;
    UIView *_catArea;
    UIButton *_soap;
    UIButton *_shower;
    UILabel *_status;
    NSInteger _soapRubCount;
    BOOL _soapy;
}
- (id)initWithNeeds:(PetNeedsManager *)needs progress:(PetProgressManager *)progress;
@end
