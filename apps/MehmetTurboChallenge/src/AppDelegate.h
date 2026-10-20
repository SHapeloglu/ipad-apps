#import <UIKit/UIKit.h>

@class GameView;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *_window;
    GameView *_gameView;
}
@property(nonatomic, retain) UIWindow *window;
@end
