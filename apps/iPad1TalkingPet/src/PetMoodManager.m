#import "PetMoodManager.h"
#import "PetNeedsManager.h"

@implementation PetMoodManager

+ (PetMoodManager *)sharedManager {
    static PetMoodManager *s=nil;
    if(!s) s=[[PetMoodManager alloc] init];
    return s;
}

- (PetMood)moodForNeeds:(PetNeedsManager *)n {
    if(!n) return PetMoodNeutral;

    NSInteger hunger=n.hunger;
    NSInteger happiness=n.happiness;
    NSInteger hygiene=n.hygiene;
    NSInteger energy=n.energy;

    if(energy < 25) return PetMoodSleepy;
    if(hunger < 25) return PetMoodHungry;
    if(hygiene < 25) return PetMoodDirty;
    if(happiness < 25) return PetMoodBored;

    if(hunger > 70 && happiness > 70 && hygiene > 70 && energy > 70)
        return PetMoodHappy;

    return PetMoodNeutral;
}

- (NSString *)moodTitleForNeeds:(PetNeedsManager *)n {
    switch([self moodForNeeds:n]) {
        case PetMoodHappy: return @"Mutlu";
        case PetMoodHungry: return @"Acıktı";
        case PetMoodDirty: return @"Banyo İstiyor";
        case PetMoodSleepy: return @"Uykusu Var";
        case PetMoodBored: return @"Sıkıldı";
        default: return @"İyi";
    }
}

- (NSString *)moodHintForNeeds:(PetNeedsManager *)n {
    switch([self moodForNeeds:n]) {
        case PetMoodHappy: return @"Bugün çok keyifli!";
        case PetMoodHungry: return @"Yemek kabına bakıyor.";
        case PetMoodDirty: return @"Kendini temizlemeye çalışıyor.";
        case PetMoodSleepy: return @"Esniyor ve yatağı düşünüyor.";
        case PetMoodBored: return @"Bir oyun oynamak istiyor.";
        default: return @"Biraz ilgi iyi gelebilir.";
    }
}

@end
