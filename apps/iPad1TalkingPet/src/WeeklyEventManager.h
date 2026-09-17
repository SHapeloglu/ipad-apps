#import <Foundation/Foundation.h>

@interface WeeklyEventManager : NSObject
+ (WeeklyEventManager *)sharedManager;
- (NSString *)todayEventTitle;
- (NSString *)todayEventDetail;
- (NSInteger)coinMultiplierForMiniGames;
- (NSInteger)foodDiscountPercent;
- (NSInteger)wardrobeDiscountPercent;
- (NSInteger)dailyBonusCoins;
@end
