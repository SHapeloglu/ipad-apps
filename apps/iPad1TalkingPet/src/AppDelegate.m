#import "AppDelegate.h"
#import "HomeViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    _homeViewController = [[HomeViewController alloc] init];
    self.window.rootViewController = _homeViewController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)dealloc {
    [_homeViewController release];
    [_window release];
    [super dealloc];
}

@end
