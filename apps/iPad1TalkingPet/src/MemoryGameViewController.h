#import <UIKit/UIKit.h>
@class PetProgressManager;

@interface MemoryGameViewController : UIViewController {
    PetProgressManager *_progress;
    NSMutableArray *_buttons;
    NSMutableArray *_values;
    UIButton *_first;
    BOOL _locked;
    NSInteger _matches;
}
- (id)initWithProgressManager:(PetProgressManager *)progress;
@end
