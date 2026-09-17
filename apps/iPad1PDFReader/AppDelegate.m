#import "AppDelegate.h"
#import "PDFLibraryViewController.h"
@implementation AppDelegate
@synthesize window=_window,navigationController=_navigationController;
- (BOOL)application:(UIApplication*)app didFinishLaunchingWithOptions:(NSDictionary*)opts{self.window=[[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]]autorelease];PDFLibraryViewController*l=[[[PDFLibraryViewController alloc]init]autorelease];self.navigationController=[[[UINavigationController alloc]initWithRootViewController:l]autorelease];self.window.rootViewController=self.navigationController;[self.window makeKeyAndVisible];NSURL*u=[opts objectForKey:UIApplicationLaunchOptionsURLKey];if(u)[l importExternalPDFURL:u];return YES;}
- (BOOL)application:(UIApplication*)app handleOpenURL:(NSURL*)url{PDFLibraryViewController*l=(PDFLibraryViewController*)[self.navigationController.viewControllers objectAtIndex:0];[l importExternalPDFURL:url];return YES;}
- (void)dealloc{[_navigationController release];[_window release];[super dealloc];}
@end
