#import "AppDelegate.h"
#import "HomeViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    (void)application;
    (void)launchOptions;

    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[[UIWindow alloc] initWithFrame:frame] autorelease];

    HomeViewController *home = [[[HomeViewController alloc] init] autorelease];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:home] autorelease];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)dealloc
{
    [_navigationController release];
    [_window release];
    [super dealloc];
}

@end
