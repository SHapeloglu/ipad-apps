#import <Foundation/Foundation.h>

@interface IP1AppRegistry : NSObject
+ (NSArray *)defaultRegistrations;
+ (NSDictionary *)registrationForExtension:(NSString *)extension;
+ (NSDictionary *)registrationForPath:(NSString *)path;
+ (NSString *)displayNameForPath:(NSString *)path;
@end
