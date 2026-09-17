#import "AchievementManager.h"

@implementation AchievementManager

+ (AchievementManager *)sharedManager {
    static AchievementManager *s=nil;
    if(!s) s=[[AchievementManager alloc] init];
    return s;
}

- (NSString *)fullKey:(NSString *)k { return [@"ach." stringByAppendingString:k]; }

- (void)increment:(NSString *)key amount:(NSInteger)amount {
    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    NSString *k=[self fullKey:key];
    NSInteger v=[d integerForKey:k]+amount;
    [d setInteger:v forKey:k];
    [d synchronize];
}

- (NSInteger)valueFor:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] integerForKey:[self fullKey:key]];
}

- (NSArray *)achievementRows {
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"Arkadaş",@"title",@"talk",@"key",[NSNumber numberWithInt:20],@"goal",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Lezzet Uzmanı",@"title",@"feed",@"key",[NSNumber numberWithInt:30],@"goal",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Temizlikçi",@"title",@"bath",@"key",[NSNumber numberWithInt:15],@"goal",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Oyun Ustası",@"title",@"game",@"key",[NSNumber numberWithInt:20],@"goal",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Gezgin",@"title",@"travel",@"key",[NSNumber numberWithInt:10],@"goal",nil],
            nil];
}

- (NSString *)today {
    NSDateFormatter *f=[[[NSDateFormatter alloc] init] autorelease];
    [f setDateFormat:@"yyyy-MM-dd"];
    return [f stringFromDate:[NSDate date]];
}

- (void)resetDailyIfNeeded {
    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    NSString *today=[self today];
    NSString *last=[d stringForKey:@"daily.date"];
    if(!last || ![last isEqualToString:today]) {
        [d setObject:today forKey:@"daily.date"];
        [d setInteger:0 forKey:@"daily.feed"];
        [d setInteger:0 forKey:@"daily.bath"];
        [d setInteger:0 forKey:@"daily.game"];
        [d setInteger:0 forKey:@"daily.photo"];
        [d synchronize];
    }
}

- (NSArray *)dailyTaskRows {
    [self resetDailyIfNeeded];
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"3 kez yemek ver",@"title",@"daily.feed",@"key",[NSNumber numberWithInt:3],@"goal",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Banyoyu tamamla",@"title",@"daily.bath",@"key",[NSNumber numberWithInt:1],@"goal",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"2 mini oyun oyna",@"title",@"daily.game",@"key",[NSNumber numberWithInt:2],@"goal",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Fotoğraf çek",@"title",@"daily.photo",@"key",[NSNumber numberWithInt:1],@"goal",nil],
            nil];
}

@end
