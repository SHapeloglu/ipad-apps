#import "PetNeedsManager.h"

static NSString * const kPetHungerKey = @"pet.hunger";
static NSString * const kPetHappinessKey = @"pet.happiness";
static NSString * const kPetHygieneKey = @"pet.hygiene";
static NSString * const kPetEnergyKey = @"pet.energy";
static NSString * const kPetCoinsKey = @"pet.coins";

@implementation PetNeedsManager

@synthesize hunger = _hunger;
@synthesize happiness = _happiness;
@synthesize hygiene = _hygiene;
@synthesize energy = _energy;
@synthesize coins = _coins;

- (id)init {
    self = [super init];
    if (self) {
        [self loadState];
    }
    return self;
}

- (NSInteger)clamp:(NSInteger)value {
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
}

- (void)loadState {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([d objectForKey:kPetHungerKey] == nil) {
        _hunger = 75;
        _happiness = 80;
        _hygiene = 70;
        _energy = 65;
        _coins = 1250;
        [self saveState];
        return;
    }

    _hunger = [d integerForKey:kPetHungerKey];
    _happiness = [d integerForKey:kPetHappinessKey];
    _hygiene = [d integerForKey:kPetHygieneKey];
    _energy = [d integerForKey:kPetEnergyKey];
    _coins = [d integerForKey:kPetCoinsKey];
}

- (void)saveState {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setInteger:_hunger forKey:kPetHungerKey];
    [d setInteger:_happiness forKey:kPetHappinessKey];
    [d setInteger:_hygiene forKey:kPetHygieneKey];
    [d setInteger:_energy forKey:kPetEnergyKey];
    [d setInteger:_coins forKey:kPetCoinsKey];
    [d synchronize];
}

- (void)feed {
    _hunger = [self clamp:_hunger + 15];
    _happiness = [self clamp:_happiness + 3];
    if (_coins >= 10) _coins -= 10;
    [self saveState];
}

- (void)play {
    _happiness = [self clamp:_happiness + 15];
    _energy = [self clamp:_energy - 8];
    _hunger = [self clamp:_hunger - 4];
    [self saveState];
}

- (void)bathe {
    _hygiene = [self clamp:_hygiene + 20];
    _happiness = [self clamp:_happiness + 2];
    [self saveState];
}

- (void)sleep {
    _energy = [self clamp:_energy + 25];
    _hunger = [self clamp:_hunger - 5];
    [self saveState];
}

@end
