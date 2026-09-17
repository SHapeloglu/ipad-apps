#import "PetNeedsManager.h"

@implementation PetNeedsManager
@synthesize hunger = _hunger;
@synthesize happiness = _happiness;
@synthesize hygiene = _hygiene;
@synthesize energy = _energy;

- (id)init {
    self = [super init];
    if (self) {
        [self loadState];
        [self applyOfflineDecay];
    }
    return self;
}

- (NSInteger)clamp:(NSInteger)v {
    if (v < 0) return 0;
    if (v > 100) return 100;
    return v;
}

- (void)loadState {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([d objectForKey:@"pet.hunger"] == nil) {
        _hunger = 75; _happiness = 80; _hygiene = 70; _energy = 65;
        [self saveState];
    } else {
        _hunger = [d integerForKey:@"pet.hunger"];
        _happiness = [d integerForKey:@"pet.happiness"];
        _hygiene = [d integerForKey:@"pet.hygiene"];
        _energy = [d integerForKey:@"pet.energy"];
    }
}

- (void)saveState {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setInteger:_hunger forKey:@"pet.hunger"];
    [d setInteger:_happiness forKey:@"pet.happiness"];
    [d setInteger:_hygiene forKey:@"pet.hygiene"];
    [d setInteger:_energy forKey:@"pet.energy"];
    [d setObject:[NSDate date] forKey:@"pet.lastSaved"];
    [d synchronize];
}

- (void)applyOfflineDecay {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSDate *last = [d objectForKey:@"pet.lastSaved"];
    if (!last) { [self saveState]; return; }

    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:last];
    NSInteger hours = (NSInteger)(elapsed / 3600.0);
    if (hours <= 0) return;
    if (hours > 48) hours = 48;

    _hunger = [self clamp:_hunger - hours * 3];
    _happiness = [self clamp:_happiness - hours * 2];
    _hygiene = [self clamp:_hygiene - hours * 2];
    _energy = [self clamp:_energy - hours * 2];
    [self saveState];
}

- (void)applyMinuteDecay {
    _hunger = [self clamp:_hunger - 1];
    _happiness = [self clamp:_happiness - ((_hunger < 25) ? 1 : 0)];
    _hygiene = [self clamp:_hygiene - ((_hunger < 40) ? 1 : 0)];
    _energy = [self clamp:_energy - 1];
    [self saveState];
}

- (void)feed {
    _hunger = [self clamp:_hunger + 18];
    _happiness = [self clamp:_happiness + 2];
    _hygiene = [self clamp:_hygiene - 1];
    [self saveState];
}

- (void)play {
    _happiness = [self clamp:_happiness + 16];
    _energy = [self clamp:_energy - 8];
    _hunger = [self clamp:_hunger - 5];
    _hygiene = [self clamp:_hygiene - 3];
    [self saveState];
}

- (void)bathe {
    _hygiene = [self clamp:_hygiene + 25];
    _happiness = [self clamp:_happiness + 2];
    [self saveState];
}

- (void)sleep {
    _energy = [self clamp:_energy + 30];
    _hunger = [self clamp:_hunger - 5];
    [self saveState];
}
@end
