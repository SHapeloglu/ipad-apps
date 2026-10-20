#import "IP1AppRegistry.h"

@implementation IP1AppRegistry
+ (NSArray *)defaultRegistrations { return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"pdf",@"extension",@"iPad1PDFReader",@"name",@"ipad1pdf",@"scheme",@"ipad1pdf://open?path=%@",@"url",nil],nil]; }
+ (NSDictionary *)registrationForExtension:(NSString *)extension { if (![extension length]) return nil; NSString *ext=[extension lowercaseString]; if ([ext hasPrefix:@"."]) ext=[ext substringFromIndex:1]; for (NSDictionary *item in [self defaultRegistrations]) if ([[item objectForKey:@"extension"] isEqualToString:ext]) return item; return nil; }
+ (NSDictionary *)registrationForPath:(NSString *)path { return [self registrationForExtension:[path pathExtension]]; }
+ (NSString *)displayNameForPath:(NSString *)path { return [[self registrationForPath:path] objectForKey:@"name"]; }
@end
