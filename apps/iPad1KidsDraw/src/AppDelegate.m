#import "AppDelegate.h"
#import "DrawingViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    DrawingViewController *controller = [[[DrawingViewController alloc] init] autorelease];
    self.viewController = controller;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [_viewController release];
    [_window release];
    [super dealloc];
}

@end
