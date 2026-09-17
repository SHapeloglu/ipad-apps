#import <Foundation/Foundation.h>

@interface HighScoreManager : NSObject
+ (HighScoreManager *)sharedManager;
- (NSInteger)highScoreForGame:(NSString *)gameKey;
- (BOOL)submitScore:(NSInteger)score forGame:(NSString *)gameKey;
- (NSInteger)comboBonusForCombo:(NSInteger)combo;
@end
