#import "AppDelegate.h"
#import "FileBrowserViewController.h"
#import "IP1SharedStorage.h"

@implementation AppDelegate

static NSString *IP1SharedRootPath(void) {
    return @"/var/mobile/Media/iPad1Files";
}

static BOOL IP1PathIsInsideSharedRoot(NSString *path) {
    if (![path length]) return NO;

    NSString *root = [IP1SharedRootPath() stringByStandardizingPath];
    NSString *candidate = [path stringByStandardizingPath];

    if ([candidate isEqualToString:root]) return YES;

    NSString *prefix = [root stringByAppendingString:@"/"];
    return [candidate hasPrefix:prefix];
}

static NSString *IP1QueryValue(NSURL *url, NSString *wantedKey) {
    NSString *query = [url query];
    if (![query length]) return nil;

    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSRange equals = [pair rangeOfString:@"="];
        NSString *key = nil;
        NSString *value = nil;

        if (equals.location == NSNotFound) {
            key = pair;
            value = @"";
        } else {
            key = [pair substringToIndex:equals.location];
            value = [pair substringFromIndex:equals.location + 1];
        }

        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if ([key isEqualToString:wantedKey]) {
            return [value stringByReplacingPercentEscapesUsingEncoding:
                          NSUTF8StringEncoding];
        }
    }

    return nil;
}

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application;

    [[IP1SharedStorage sharedStorage] ensureDirectoryStructure];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    FileBrowserViewController *browser =
        [[[FileBrowserViewController alloc] initWithPath:[[IP1SharedStorage sharedStorage] rootPath]] autorelease];

    self.navigationController =
        [[[UINavigationController alloc] initWithRootViewController:browser] autorelease];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    /*
     * iOS 5 cold launch through URL scheme.
     * handleOpenURL: covers the warm-launch case.
     */
    NSURL *launchURL =
        [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];

    if (launchURL) {
        [self application:application handleOpenURL:launchURL];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    (void)application;

    if (!url || ![[url scheme] isEqualToString:@"ipad1files"]) {
        return NO;
    }

    /*
     * External read-only file picker contract:
     *
     * ipad1files://pick?callback=ipad1pdf
     *
     * For this integration only ipad1pdf is accepted.
     * Picker always starts at the canonical shared root.
     */
    NSString *absolute = [url absoluteString];
    BOOL pickerRequest = [[url host] isEqualToString:@"pick"];

    /*
     * Older Foundation URL parsing on iOS 5 can be conservative with
     * custom schemes. Fall back to the literal contract as well.
     */
    if (!pickerRequest &&
        [absolute hasPrefix:@"ipad1files://pick?"]) {
        pickerRequest = YES;
    }

    if (pickerRequest) {
        NSString *callback = IP1QueryValue(url, @"callback");

        if (![callback length]) {
            NSRange marker = [absolute rangeOfString:@"callback="];
            if (marker.location != NSNotFound) {
                NSString *value =
                    [absolute substringFromIndex:
                        marker.location + marker.length];

                NSRange amp = [value rangeOfString:@"&"];
                if (amp.location != NSNotFound) {
                    value = [value substringToIndex:amp.location];
                }

                callback =
                    [value stringByReplacingPercentEscapesUsingEncoding:
                        NSUTF8StringEncoding];
            }
        }

        if (![callback isEqualToString:@"ipad1pdf"]) {
            return YES;
        }

        FileBrowserViewController *browser =
            [[[FileBrowserViewController alloc]
                initWithPath:IP1SharedRootPath()
                pickerCallbackScheme:callback] autorelease];

        [self.navigationController setViewControllers:
            [NSArray arrayWithObject:browser]
            animated:NO];

        return YES;
    }

    /*
     * Preserve the existing directory deep-link behavior, but never permit
     * an external URL to navigate iPad1Files outside its shared root.
     */
    NSString *path = IP1QueryValue(url, @"path");

    if (![path length] || !IP1PathIsInsideSharedRoot(path)) {
        return YES;
    }

    BOOL isDirectory = NO;

    if ([[NSFileManager defaultManager] fileExistsAtPath:path
                                             isDirectory:&isDirectory] &&
        isDirectory) {

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
