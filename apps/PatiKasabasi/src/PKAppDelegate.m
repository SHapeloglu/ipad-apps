#import "PKAppDelegate.h"
#import "PKGameState.h"
#import "PKWelcomeViewController.h"
#import "PKHomeViewController.h"
#import "PKTheme.h"

@implementation PKAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize gameState = _gameState;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application;
    (void)launchOptions;

    PKGameState *state = [[PKGameState alloc] init];
    self.gameState = state;
    [state release];
    [self.gameState load];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    PKWelcomeViewController *welcome = [[PKWelcomeViewController alloc] initWithGameState:self.gameState];
    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:welcome] autorelease];
    [welcome release];
    self.navigationController.navigationBar.tintColor = [PKTheme darkTealColor];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    (void)application;
    [self.gameState save];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    (void)application;
    [self.gameState save];
}

- (void)showWelcome {
    PKWelcomeViewController *welcome = [[PKWelcomeViewController alloc] initWithGameState:self.gameState];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:welcome] animated:YES];
    [welcome release];
}

- (void)showHome {
    if (!self.gameState.pet) return;
    PKHomeViewController *home = [[PKHomeViewController alloc] initWithGameState:self.gameState];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:home] animated:YES];
    [home release];
}

- (void)dealloc {
    [_window release];
    [_navigationController release];
    [_gameState release];
    [super dealloc];
}

@end
