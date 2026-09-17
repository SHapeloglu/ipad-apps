#import <Foundation/Foundation.h>
@interface PageManager:NSObject
+ (BOOL)exportDocumentAtPath:(NSString*)path pageOrder:(NSArray*)pages toPath:(NSString*)outPath;
@end
