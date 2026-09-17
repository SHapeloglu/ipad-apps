#import <UIKit/UIKit.h>

@class PKGameState;

@interface PKAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *_window;
    UINavigationController *_navigationController;
    PKGameState *_gameState;
}

@property(nonatomic, retain) UIWindow *window;
@property(nonatomic, retain) UINavigationController *navigationController;
@property(nonatomic, retain) PKGameState *gameState;

- (void)showWelcome;
- (void)showHome;

@end
