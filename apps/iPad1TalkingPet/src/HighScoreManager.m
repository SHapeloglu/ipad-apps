#import "HighScoreManager.h"

@implementation HighScoreManager

+ (HighScoreManager *)sharedManager {
    static HighScoreManager *s=nil;
    if(!s) s=[[HighScoreManager alloc] init];
    return s;
}

- (NSString *)key:(NSString *)gameKey {
    return [@"highscore." stringByAppendingString:gameKey];
}

- (NSInteger)highScoreForGame:(NSString *)gameKey {
    return [[NSUserDefaults standardUserDefaults] integerForKey:[self key:gameKey]];
}

- (BOOL)submitScore:(NSInteger)score forGame:(NSString *)gameKey {
    NSInteger old=[self highScoreForGame:gameKey];
    if(score<=old) return NO;
    [[NSUserDefaults standardUserDefaults] setInteger:score forKey:[self key:gameKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (NSInteger)comboBonusForCombo:(NSInteger)combo {
    if(combo>=10) return 3;
    if(combo>=5) return 2;
    return 1;
}

@end
