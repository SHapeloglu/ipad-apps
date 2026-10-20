#import "AppDelegate.h"
#import "FileBrowserViewController.h"
#import "IP1SharedStorage.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application;
    (void)launchOptions;

    [[IP1SharedStorage sharedStorage] ensureDirectoryStructure];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    FileBrowserViewController *browser =
        [[[FileBrowserViewController alloc] initWithPath:[[IP1SharedStorage sharedStorage] rootPath]] autorelease];

    self.navigationController =
        [[[UINavigationController alloc] initWithRootViewController:browser] autorelease];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    (void)application;

    if (!url || ![[url scheme] isEqualToString:@"ipad1files"]) {
        return NO;
    }

    NSString *absolute = [url absoluteString];
    NSRange marker = [absolute rangeOfString:@"path="];
    if (marker.location == NSNotFound) {
        return YES;
    }

    NSString *encoded = [absolute substringFromIndex:marker.location + marker.length];
    NSString *path = [encoded stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
        FileBrowserViewController *browser =
            [[[FileBrowserViewController alloc] initWithPath:path] autorelease];
        [self.navigationController pushViewController:browser animated:YES];
    }
    return YES;
}

- (void)dealloc {
    [_navigationController release];
    [_window release];
    [super dealloc];
}

@end
