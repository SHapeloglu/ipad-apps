#import <UIKit/UIKit.h>
#import "GameView.h"

@interface GameViewController : UIViewController {
    GameView *_gameView;
}
- (id)initWithGameView:(GameView *)gameView;
@end

@implementation GameViewController

- (id)initWithGameView:(GameView *)gameView
{
    self = [super init];
    if (self) {
        _gameView = [gameView retain];
    }
    return self;
}

- (void)loadView
{
    self.view = _gameView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation == UIInterfaceOrientationLandscapeLeft ||
            orientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc
{
    [_gameView release];
    [super dealloc];
}

@end


@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *_window;
    GameView *_gameView;
    GameViewController *_viewController;
}

@property(nonatomic, retain) UIWindow *window;

@end


@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    (void)application;
    (void)launchOptions;

    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    _window = [[UIWindow alloc] initWithFrame:screenBounds];

    _gameView = [[GameView alloc] initWithFrame:screenBounds];

    _viewController =
        [[GameViewController alloc] initWithGameView:_gameView];

    _window.rootViewController = _viewController;

    _window.backgroundColor = [UIColor blackColor];

    [_window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    (void)application;
    [_gameView pauseGame];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    (void)application;
    [_gameView resumeGame];
}

- (void)dealloc
{
    [_viewController release];
    [_gameView release];
    [_window release];
    [super dealloc];
}

@end
