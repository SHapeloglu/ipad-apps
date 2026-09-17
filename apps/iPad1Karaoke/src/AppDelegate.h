#import <UIKit/UIKit.h>

@class KaraokeViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *_window;
    KaraokeViewController *_karaokeViewController;
}
@property (nonatomic, retain) UIWindow *window;
@end
