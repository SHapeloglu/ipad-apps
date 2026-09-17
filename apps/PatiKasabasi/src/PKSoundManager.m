#import "PKSoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

static SystemSoundID PKTapSound = 0;
static SystemSoundID PKSuccessSound = 0;

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
    if ([name isEqualToString:@"success"]) {
        PKSuccessSound = [self loadSoundNamed:@"success" current:PKSuccessSound];
        if (PKSuccessSound != 0) AudioServicesPlaySystemSound(PKSuccessSound);
    } else {
        PKTapSound = [self loadSoundNamed:@"tap" current:PKTapSound];
        if (PKTapSound != 0) AudioServicesPlaySystemSound(PKTapSound);
    }
}

@end
