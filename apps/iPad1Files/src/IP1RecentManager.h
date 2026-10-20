#import <Foundation/Foundation.h>
@interface IP1RecentManager : NSObject
+ (IP1RecentManager *)sharedManager;
- (void)recordPath:(NSString *)path;
- (NSArray *)recentPaths;
- (void)removePath:(NSString *)path;
- (void)pruneMissingPaths;
@end
