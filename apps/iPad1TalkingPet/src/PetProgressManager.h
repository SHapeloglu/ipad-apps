#import <Foundation/Foundation.h>

@interface PetProgressManager : NSObject {
    NSInteger _xp;
    NSInteger _level;
    NSInteger _coins;
    NSString *_lastDailyRewardDate;
}
@property (nonatomic, assign) NSInteger xp;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger coins;

- (void)load;
- (void)save;
- (BOOL)claimDailyRewardIfAvailable;
- (void)addXP:(NSInteger)amount;
- (void)addCoins:(NSInteger)amount;
- (BOOL)spendCoins:(NSInteger)amount;
- (NSInteger)xpNeededForNextLevel;
@end
