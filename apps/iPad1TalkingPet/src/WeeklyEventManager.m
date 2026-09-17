#import "WeeklyEventManager.h"

@implementation WeeklyEventManager

+ (WeeklyEventManager *)sharedManager {
    static WeeklyEventManager *s=nil;
    if(!s) s=[[WeeklyEventManager alloc] init];
    return s;
}

- (NSInteger)weekday {
    NSCalendar *c=[NSCalendar currentCalendar];
    NSDateComponents *cmp=[c components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    return [cmp weekday]; // 1 Sunday ... 7 Saturday
}

- (NSString *)todayEventTitle {
    switch([self weekday]) {
        case 2: return @"Pazartesi Oyun Günü";
        case 3: return @"Salı Lezzet Günü";
        case 4: return @"Çarşamba Moda Günü";
        case 5: return @"Perşembe Fotoğraf Günü";
        case 6: return @"Cuma Gezi Günü";
        case 7: return @"Cumartesi Süper Ödül";
        default: return @"Pazar Dinlenme Günü";
    }
}

- (NSString *)todayEventDetail {
    switch([self weekday]) {
        case 2: return @"Mini oyun coin ödülleri 2x.";
        case 3: return @"Yemeklerde %25 indirim.";
        case 4: return @"Gardıropta %20 indirim.";
        case 5: return @"İlk fotoğraf +20 coin.";
        case 6: return @"Seyahat XP ödülü +%50.";
        case 7: return @"Günlük bonus +100 coin.";
        default: return @"Uyku ve bakım XP +%25.";
    }
}

- (NSInteger)coinMultiplierForMiniGames { return [self weekday]==2 ? 2 : 1; }
- (NSInteger)foodDiscountPercent { return [self weekday]==3 ? 25 : 0; }
- (NSInteger)wardrobeDiscountPercent { return [self weekday]==4 ? 20 : 0; }
- (NSInteger)dailyBonusCoins { return [self weekday]==7 ? 100 : 0; }

@end
