#import "AppDelegate.h"
#import "TicketViewController.h"

@implementation AppDelegate
@synthesize window = _window;
@synthesize ticketViewController = _ticketViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.ticketViewController = [[[TicketViewController alloc] init] autorelease];
    self.window.rootViewController = self.ticketViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [_ticketViewController release];
    [_window release];
    [super dealloc];
}
@end
