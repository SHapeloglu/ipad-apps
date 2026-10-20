#import <UIKit/UIKit.h>

@class DrawingViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow *_window;
    DrawingViewController *_viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) DrawingViewController *viewController;

@end
