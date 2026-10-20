#import <Foundation/Foundation.h>

@interface AchievementManager : NSObject
+ (AchievementManager *)sharedManager;
- (void)increment:(NSString *)key amount:(NSInteger)amount;
- (NSInteger)valueFor:(NSString *)key;
- (NSArray *)achievementRows;
- (NSArray *)dailyTaskRows;
- (void)resetDailyIfNeeded;
@end
