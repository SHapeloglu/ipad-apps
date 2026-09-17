#import "PKSoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

static SystemSoundID PKTapSound = 0;
static SystemSoundID PKSuccessSound = 0;
static SystemSoundID PKEatSound = 0;
static SystemSoundID PKSleepSound = 0;
static SystemSoundID PKBallSound = 0;
static SystemSoundID PKBubbleSound = 0;
static SystemSoundID PKLaughSound = 0;
static SystemSoundID PKSurpriseSound = 0;

@interface PKSoundManager ()
+ (SystemSoundID)loadSoundNamed:(NSString *)name current:(SystemSoundID)current;
@end

@implementation PKSoundManager

+ (SystemSoundID)loadSoundNamed:(NSString *)name current:(SystemSoundID)current {
    if (current != 0) return current;
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
    if (!path) return 0;
    SystemSoundID sound = 0;
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &sound);
    return sound;
}

+ (void)playEffectNamed:(NSString *)name enabled:(BOOL)enabled {
    if (!enabled) return;
    NSString *resource = @"tap";
    SystemSoundID *slot = &PKTapSound;
    if ([name isEqualToString:@"success"]) { resource = @"success"; slot = &PKSuccessSound; }
    else if ([name isEqualToString:@"eat"]) { resource = @"eat"; slot = &PKEatSound; }
    else if ([name isEqualToString:@"sleep"]) { resource = @"sleep"; slot = &PKSleepSound; }
    else if ([name isEqualToString:@"ball"]) { resource = @"ball"; slot = &PKBallSound; }
    else if ([name isEqualToString:@"bubble"]) { resource = @"bubble"; slot = &PKBubbleSound; }
    else if ([name isEqualToString:@"laugh"]) { resource = @"laugh"; slot = &PKLaughSound; }
    else if ([name isEqualToString:@"surprise"]) { resource = @"surprise"; slot = &PKSurpriseSound; }
    *slot = [self loadSoundNamed:resource current:*slot];
    if (*slot != 0) AudioServicesPlaySystemSound(*slot);
}

@end
