#import <UIKit/UIKit.h>

@class HomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *_window;
    HomeViewController *_homeViewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
