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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if(!url) return NO;
    NSString *path=nil;
    if([[url scheme] caseInsensitiveCompare:@"kidsdraw"]==NSOrderedSame){
        NSString *q=[url query];
        if([q hasPrefix:@"path="]) path=[[q substringFromIndex:5] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if(path && [self.viewController respondsToSelector:@selector(openExternalImageAtPath:)]){[self.viewController openExternalImageAtPath:path];return YES;}
    return NO;
}

- (void)dealloc
{
    [_viewController release];
    [_window release];
    [super dealloc];
}

@end
