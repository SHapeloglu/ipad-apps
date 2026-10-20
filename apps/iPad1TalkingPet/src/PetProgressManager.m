#import "PetProgressManager.h"

@implementation PetProgressManager
@synthesize xp = _xp;
@synthesize level = _level;
@synthesize coins = _coins;

- (id)init {
    self = [super init];
    if (self) [self load];
    return self;
}

- (void)load {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([d objectForKey:@"progress.level"] == nil) {
        _level = 1;
        _xp = 0;
        _coins = 1250;
        [self save];
    } else {
        _level = [d integerForKey:@"progress.level"];
        _xp = [d integerForKey:@"progress.xp"];
        _coins = [d integerForKey:@"progress.coins"];
    }
    [_lastDailyRewardDate release];
    _lastDailyRewardDate = [[d stringForKey:@"progress.lastDailyReward"] retain];
}

- (void)save {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setInteger:_level forKey:@"progress.level"];
    [d setInteger:_xp forKey:@"progress.xp"];
    [d setInteger:_coins forKey:@"progress.coins"];
    if (_lastDailyRewardDate) [d setObject:_lastDailyRewardDate forKey:@"progress.lastDailyReward"];
    [d synchronize];
}

- (NSString *)todayKey {
    NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
    [fmt setDateFormat:@"yyyy-MM-dd"];
    return [fmt stringFromDate:[NSDate date]];
}

- (BOOL)claimDailyRewardIfAvailable {
    NSString *today = [self todayKey];
    if (_lastDailyRewardDate && [_lastDailyRewardDate isEqualToString:today]) return NO;
    [_lastDailyRewardDate release];
    _lastDailyRewardDate = [today copy];
    _coins += 50;
    [self addXP:10];
    [self save];
    return YES;
}

- (NSInteger)xpNeededForNextLevel {
    return 100 + ((_level - 1) * 25);
}

- (void)addXP:(NSInteger)amount {
    _xp += amount;
    NSInteger needed = [self xpNeededForNextLevel];
    while (_xp >= needed) {
        _xp -= needed;
        _level += 1;
        _coins += 100;
        needed = [self xpNeededForNextLevel];
    }
    [self save];
}

- (void)addCoins:(NSInteger)amount {
    _coins += amount;
    [self save];
}

- (BOOL)spendCoins:(NSInteger)amount {
    if (amount <= 0 || _coins < amount) return NO;
    _coins -= amount;
    [self save];
    return YES;
}

- (void)dealloc {
    [_lastDailyRewardDate release];
    [super dealloc];
}
@end
