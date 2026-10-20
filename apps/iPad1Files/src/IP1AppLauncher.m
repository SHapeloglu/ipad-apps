#import "IP1AppLauncher.h"
#import "IP1AppRegistry.h"

@implementation IP1AppLauncher
+ (NSString *)escapedPath:(NSString *)path { return [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; }
+ (BOOL)canOpenRegistration:(NSDictionary *)registration { NSString *scheme=[registration objectForKey:@"scheme"]; if (![scheme length]) return NO; NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@://",scheme]]; return url ? [[UIApplication sharedApplication] canOpenURL:url] : NO; }
+ (BOOL)openPath:(NSString *)path withRegistration:(NSDictionary *)registration { if (![path length] || !registration || ![self canOpenRegistration:registration]) return NO; NSString *format=[registration objectForKey:@"url"]; if (![format length]) return NO; NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:format,[self escapedPath:path]]]; return url ? [[UIApplication sharedApplication] openURL:url] : NO; }
+ (BOOL)canOpenRegisteredAppForPath:(NSString *)path { return [self canOpenRegistration:[IP1AppRegistry registrationForPath:path]]; }
+ (BOOL)openRegisteredAppForPath:(NSString *)path { NSDictionary *r=[IP1AppRegistry registrationForPath:path]; return [self openPath:path withRegistration:r]; }
+ (BOOL)canOpenPDFReader { return [self canOpenRegistration:[IP1AppRegistry registrationForExtension:@"pdf"]]; }
+ (BOOL)openPDFReaderWithPath:(NSString *)path { return [self openPath:path withRegistration:[IP1AppRegistry registrationForExtension:@"pdf"]]; }
+ (BOOL)openFilesWithPath:(NSString *)path { NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"ipad1files://open?path=%@",[self escapedPath:path]]]; return url ? [[UIApplication sharedApplication] openURL:url] : NO; }
@end
