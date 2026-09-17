#import "PKPet.h"

static NSInteger PKClampedNeed(NSInteger value) {
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
}

@implementation PKPet

@synthesize name = _name;
@synthesize speciesIdentifier = _speciesIdentifier;
@synthesize personalityIdentifier = _personalityIdentifier;
@synthesize satiety = _satiety;
@synthesize energy = _energy;
@synthesize hygiene = _hygiene;
@synthesize fun = _fun;
@synthesize social = _social;
@synthesize affection = _affection;
@synthesize growthPoints = _growthPoints;
@synthesize skills = _skills;
@synthesize relationships = _relationships;
@synthesize careerIdentifier = _careerIdentifier;

- (id)init {
    return [self initWithSpeciesIdentifier:@"cat"];
}

- (id)initWithSpeciesIdentifier:(NSString *)speciesIdentifier {
    self = [super init];
    if (self) {
        _name = [@"Minik" copy];
        _speciesIdentifier = [speciesIdentifier copy];
        _personalityIdentifier = [@"playful" copy];
        _satiety = 72;
        _energy = 76;
        _hygiene = 82;
        _fun = 68;
        _social = 70;
        _affection = 80;
        _growthPoints = 0;
        _skills = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                   [NSNumber numberWithInteger:0], @"music",
                   [NSNumber numberWithInteger:0], @"art",
                   [NSNumber numberWithInteger:0], @"nature",
                   [NSNumber numberWithInteger:0], @"logic",
                   [NSNumber numberWithInteger:0], @"social",
                   nil];
        _relationships = [[NSMutableDictionary alloc] init];
        _careerIdentifier = [@"" copy];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSString *species = [dictionary objectForKey:@"species"];
    self = [self initWithSpeciesIdentifier:(species ? species : @"cat")];
    if (self) {
        NSString *savedName = [dictionary objectForKey:@"name"];
        NSString *personality = [dictionary objectForKey:@"personality"];
        if ([savedName length] > 0) self.name = savedName;
        if ([personality length] > 0) self.personalityIdentifier = personality;

        NSNumber *value = nil;
        value = [dictionary objectForKey:@"satiety"]; if (value) _satiety = [value integerValue];
        value = [dictionary objectForKey:@"energy"]; if (value) _energy = [value integerValue];
        value = [dictionary objectForKey:@"hygiene"]; if (value) _hygiene = [value integerValue];
        value = [dictionary objectForKey:@"fun"]; if (value) _fun = [value integerValue];
        value = [dictionary objectForKey:@"social"]; if (value) _social = [value integerValue];
        value = [dictionary objectForKey:@"affection"]; if (value) _affection = [value integerValue];
        value = [dictionary objectForKey:@"growthPoints"]; if (value) _growthPoints = [value integerValue];
        NSDictionary *savedSkills = [dictionary objectForKey:@"skills"];
        if ([savedSkills isKindOfClass:[NSDictionary class]]) {
            [_skills addEntriesFromDictionary:savedSkills];
        }
        NSDictionary *savedRelationships = [dictionary objectForKey:@"relationships"];
        if ([savedRelationships isKindOfClass:[NSDictionary class]]) {
            [_relationships addEntriesFromDictionary:savedRelationships];
        }
        NSString *career = [dictionary objectForKey:@"career"];
        if ([career isKindOfClass:[NSString class]]) self.careerIdentifier = career;
        if (_growthPoints < 0) _growthPoints = 0;
        [self clampNeeds];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            (_name ? _name : @"Minik"), @"name",
            (_speciesIdentifier ? _speciesIdentifier : @"cat"), @"species",
            (_personalityIdentifier ? _personalityIdentifier : @"playful"), @"personality",
            [NSNumber numberWithInteger:_satiety], @"satiety",
            [NSNumber numberWithInteger:_energy], @"energy",
            [NSNumber numberWithInteger:_hygiene], @"hygiene",
            [NSNumber numberWithInteger:_fun], @"fun",
            [NSNumber numberWithInteger:_social], @"social",
            [NSNumber numberWithInteger:_affection], @"affection",
            [NSNumber numberWithInteger:_growthPoints], @"growthPoints",
            (_skills ? _skills : [NSDictionary dictionary]), @"skills",
            (_relationships ? _relationships : [NSDictionary dictionary]), @"relationships",
            (_careerIdentifier ? _careerIdentifier : @""), @"career",
            nil];
}

- (NSString *)speciesDisplayName {
    if ([_speciesIdentifier isEqualToString:@"dog"]) return @"Köpek";
    if ([_speciesIdentifier isEqualToString:@"rabbit"]) return @"Tavşan";
    if ([_speciesIdentifier isEqualToString:@"panda"]) return @"Panda";
    return @"Kedi";
}

- (NSString *)personalityDisplayName {
    if ([_personalityIdentifier isEqualToString:@"curious"]) return @"Meraklı";
    if ([_personalityIdentifier isEqualToString:@"sleepy"]) return @"Uykucu";
    if ([_personalityIdentifier isEqualToString:@"social"]) return @"Sosyal";
    if ([_personalityIdentifier isEqualToString:@"musical"]) return @"Müziksever";
    return @"Oyuncu";
}

- (NSString *)moodText {
    if (_satiety < 25) return @"Çok acıktım";
    if (_energy < 25) return @"Biraz uykum var";
    if (_hygiene < 25) return @"Temizlenmek istiyorum";
    if (_fun < 25) return @"Birlikte oynayalım";
    if (_social < 25) return @"Biraz yalnız hissettim";
    if (_affection < 25) return @"Beni sever misin?";

    NSInteger average = (_satiety + _energy + _hygiene + _fun + _social + _affection) / 6;
    if (average >= 85) return @"Bugün harika hissediyorum!";
    if (average >= 65) return @"Keyfim yerinde";
    return @"Birlikte bir şey yapalım";
}

- (NSString *)lifeStageIdentifier {
    if (_growthPoints >= 24) return @"adult";
    if (_growthPoints >= 8) return @"young";
    return @"baby";
}

- (NSString *)lifeStageDisplayName {
    NSString *stage = [self lifeStageIdentifier];
    if ([stage isEqualToString:@"adult"]) return @"Yetişkin";
    if ([stage isEqualToString:@"young"]) return @"Genç";
    return @"Yavru";
}

- (NSString *)favoriteFoodIdentifier {
    if ([_speciesIdentifier isEqualToString:@"cat"]) return @"food_fish";
    if ([_speciesIdentifier isEqualToString:@"rabbit"]) return @"food_carrot";
    if ([_speciesIdentifier isEqualToString:@"panda"]) return @"food_cookie";
    return @"food_kibble";
}

- (NSString *)dislikedFoodIdentifier {
    if ([_speciesIdentifier isEqualToString:@"rabbit"] || [_speciesIdentifier isEqualToString:@"panda"]) return @"food_fish";
    return @"food_carrot";
}

- (NSString *)foodPreferenceForIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:[self favoriteFoodIdentifier]]) return @"favorite";
    if ([identifier isEqualToString:[self dislikedFoodIdentifier]]) return @"disliked";
    return @"neutral";
}

- (NSInteger)skillLevelForIdentifier:(NSString *)identifier {
    NSNumber *value = [_skills objectForKey:identifier];
    return value ? [value integerValue] : 0;
}

- (NSInteger)increaseSkillIdentifier:(NSString *)identifier amount:(NSInteger)amount {
    NSInteger value = [self skillLevelForIdentifier:identifier] + amount;
    if (value < 0) value = 0;
    if (value > 10) value = 10;
    if (identifier) [_skills setObject:[NSNumber numberWithInteger:value] forKey:identifier];
    return value;
}

- (NSInteger)friendshipForNeighborIdentifier:(NSString *)identifier {
    NSNumber *value = [_relationships objectForKey:identifier];
    return value ? [value integerValue] : 0;
}

- (NSInteger)increaseFriendshipForNeighborIdentifier:(NSString *)identifier amount:(NSInteger)amount {
    NSInteger value = [self friendshipForNeighborIdentifier:identifier] + amount;
    if (value < 0) value = 0;
    if (value > 100) value = 100;
    if (identifier) [_relationships setObject:[NSNumber numberWithInteger:value] forKey:identifier];
    return value;
}

- (void)clampNeeds {
    _satiety = PKClampedNeed(_satiety);
    _energy = PKClampedNeed(_energy);
    _hygiene = PKClampedNeed(_hygiene);
    _fun = PKClampedNeed(_fun);
    _social = PKClampedNeed(_social);
    _affection = PKClampedNeed(_affection);
}

- (void)dealloc {
    [_name release];
    [_speciesIdentifier release];
    [_personalityIdentifier release];
    [_skills release];
    [_relationships release];
    [_careerIdentifier release];
    [super dealloc];
}

@end
