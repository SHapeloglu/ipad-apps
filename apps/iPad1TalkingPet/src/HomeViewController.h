#import <UIKit/UIKit.h>

@class PetNeedsManager;

@interface HomeViewController : UIViewController {
    UIImageView *_backgroundView;
    PetNeedsManager *_needs;

    UIProgressView *_hungerBar;
    UIProgressView *_happinessBar;
    UIProgressView *_hygieneBar;
    UIProgressView *_energyBar;
    UILabel *_coinLabel;

    NSTimer *_idleTimer;
    CGFloat _baseScale;
}

@end
