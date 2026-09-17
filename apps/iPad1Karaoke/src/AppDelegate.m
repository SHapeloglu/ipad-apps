#import "AppDelegate.h"
#import "KaraokeViewController.h"

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application;
    (void)launchOptions;

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    _karaokeViewController = [[KaraokeViewController alloc] init];
    self.window.rootViewController = _karaokeViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [_karaokeViewController release];
    [_window release];
    [super dealloc];
}
@end
