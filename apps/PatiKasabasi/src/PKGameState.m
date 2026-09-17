#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"

static NSString * const PKSavedGameKey = @"PatiKasabasiSavedGameV1";

@interface PKGameState ()
- (void)advanceAction;
- (void)applyCommonNeedDecay;
- (NSString *)finishActivityWithQuestEvent:(NSString *)eventIdentifier oldStage:(NSString *)oldStage;
- (void)addCollectionIdentifier:(NSString *)identifier;
- (void)pruneMemoryPhotos;
@end

@implementation PKGameState

@synthesize pet = _pet;
@synthesize sourceIdentifier = _sourceIdentifier;
@synthesize coins = _coins;
@synthesize day = _day;
@synthesize actionCount = _actionCount;
@synthesize newHomeBadge = _newHomeBadge;
@synthesize starterToy = _starterToy;
@synthesize inventoryIdentifiers = _inventoryIdentifiers;
@synthesize placedItemIdentifiers = _placedItemIdentifiers;
@synthesize memories = _memories;
@synthesize collections = _collections;
@synthesize ownedAccessoryIdentifiers = _ownedAccessoryIdentifiers;
@synthesize equippedAccessories = _equippedAccessories;
@synthesize questStep = _questStep;
@synthesize soundEnabled = _soundEnabled;

- (id)init {
    self = [super init];
    if (self) {
        _coins = 0;
        _day = 1;
        _actionCount = 0;
        _newHomeBadge = NO;
        _starterToy = NO;
        _inventoryIdentifiers = [[NSMutableArray alloc] init];
        _placedItemIdentifiers = [[NSMutableArray alloc] init];
        _memories = [[NSMutableArray alloc] init];
        _collections = [[NSMutableArray alloc] init];
        _ownedAccessoryIdentifiers = [[NSMutableArray alloc] init];
        _equippedAccessories = [[NSMutableDictionary alloc] init];
        _questStep = 0;
        _soundEnabled = YES;
        _miniGameRewardDays = [[NSMutableDictionary alloc] init];
        _lastTownEventDay = 0;
        _lastNeighborRequestDay = 0;
        _lastWorkDay = 0;
    }
    return self;
}

- (BOOL)hasSavedGame {
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:PKSavedGameKey];
    return ([dictionary isKindOfClass:[NSDictionary class]] && [dictionary objectForKey:@"pet"] != nil);
}

- (BOOL)load {
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:PKSavedGameKey];
    if (![dictionary isKindOfClass:[NSDictionary class]]) return NO;
    NSDictionary *petDictionary = [dictionary objectForKey:@"pet"];
    if (![petDictionary isKindOfClass:[NSDictionary class]]) return NO;

    PKPet *loadedPet = [[PKPet alloc] initWithDictionary:petDictionary];
    self.pet = loadedPet;
    [loadedPet release];
    self.sourceIdentifier = [dictionary objectForKey:@"source"];

    NSNumber *value = nil;
    value = [dictionary objectForKey:@"coins"]; _coins = value ? [value integerValue] : 500;
    value = [dictionary objectForKey:@"day"]; _day = value ? [value integerValue] : 1;
    value = [dictionary objectForKey:@"actionCount"]; _actionCount = value ? [value integerValue] : 0;
    value = [dictionary objectForKey:@"newHomeBadge"]; _newHomeBadge = value ? [value boolValue] : NO;
    value = [dictionary objectForKey:@"starterToy"]; _starterToy = value ? [value boolValue] : NO;
    value = [dictionary objectForKey:@"questStep"]; _questStep = value ? [value integerValue] : 0;
    value = [dictionary objectForKey:@"soundEnabled"]; _soundEnabled = value ? [value boolValue] : YES;
    value = [dictionary objectForKey:@"lastTownEventDay"]; _lastTownEventDay = value ? [value integerValue] : 0;
    value = [dictionary objectForKey:@"lastNeighborRequestDay"]; _lastNeighborRequestDay = value ? [value integerValue] : 0;
    value = [dictionary objectForKey:@"lastWorkDay"]; _lastWorkDay = value ? [value integerValue] : 0;

    NSArray *savedInventory = [dictionary objectForKey:@"inventory"];
    [_inventoryIdentifiers removeAllObjects];
    if ([savedInventory isKindOfClass:[NSArray class]]) [_inventoryIdentifiers addObjectsFromArray:savedInventory];
    if ([_inventoryIdentifiers count] == 0) [_inventoryIdentifiers addObjectsFromArray:[NSArray arrayWithObjects:@"bed", @"bowl", nil]];

    NSArray *savedPlaced = [dictionary objectForKey:@"placedItems"];
    [_placedItemIdentifiers removeAllObjects];
    if ([savedPlaced isKindOfClass:[NSArray class]]) [_placedItemIdentifiers addObjectsFromArray:savedPlaced];
    if ([_placedItemIdentifiers count] == 0) [_placedItemIdentifiers addObjectsFromArray:[NSArray arrayWithObjects:@"bed", @"bowl", nil]];

    NSArray *savedMemories = [dictionary objectForKey:@"memories"];
    [_memories removeAllObjects];
    if ([savedMemories isKindOfClass:[NSArray class]]) [_memories addObjectsFromArray:savedMemories];
    NSArray *savedCollections = [dictionary objectForKey:@"collections"];
    [_collections removeAllObjects];
    if ([savedCollections isKindOfClass:[NSArray class]]) [_collections addObjectsFromArray:savedCollections];
    NSDictionary *savedRewards = [dictionary objectForKey:@"miniGameRewardDays"];
    [_miniGameRewardDays removeAllObjects];
    if ([savedRewards isKindOfClass:[NSDictionary class]]) [_miniGameRewardDays addEntriesFromDictionary:savedRewards];

    NSArray *savedAccessories = [dictionary objectForKey:@"ownedAccessories"];
    [_ownedAccessoryIdentifiers removeAllObjects];
    if ([savedAccessories isKindOfClass:[NSArray class]]) [_ownedAccessoryIdentifiers addObjectsFromArray:savedAccessories];
    if ([_ownedAccessoryIdentifiers count] == 0) [_ownedAccessoryIdentifiers addObjectsFromArray:[NSArray arrayWithObjects:@"redbow", @"greencollar", nil]];
    NSDictionary *savedEquipped = [dictionary objectForKey:@"equippedAccessories"];
    [_equippedAccessories removeAllObjects];
    if ([savedEquipped isKindOfClass:[NSDictionary class]]) [_equippedAccessories addEntriesFromDictionary:savedEquipped];
    if ([dictionary objectForKey:@"ownedAccessories"] == nil) {
        [_equippedAccessories setObject:@"redbow" forKey:@"head"];
        [_equippedAccessories setObject:@"greencollar" forKey:@"neck"];
    }

    if (_day < 1) _day = 1;
    if (_coins < 0) _coins = 0;
    if (_questStep < 0) _questStep = 0;
    if (_questStep > 6) _questStep = 6;
    return YES;
}

- (void)save {
    if (!_pet) return;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:3], @"saveVersion",
        [_pet dictionaryRepresentation], @"pet",
        (_sourceIdentifier ? _sourceIdentifier : @"shelter"), @"source",
        [NSNumber numberWithInteger:_coins], @"coins",
        [NSNumber numberWithInteger:_day], @"day",
        [NSNumber numberWithInteger:_actionCount], @"actionCount",
        [NSNumber numberWithBool:_newHomeBadge], @"newHomeBadge",
        [NSNumber numberWithBool:_starterToy], @"starterToy",
        (_inventoryIdentifiers ? _inventoryIdentifiers : [NSArray array]), @"inventory",
        (_placedItemIdentifiers ? _placedItemIdentifiers : [NSArray array]), @"placedItems",
        (_memories ? _memories : [NSArray array]), @"memories",
        (_collections ? _collections : [NSArray array]), @"collections",
        (_ownedAccessoryIdentifiers ? _ownedAccessoryIdentifiers : [NSArray array]), @"ownedAccessories",
        (_equippedAccessories ? _equippedAccessories : [NSDictionary dictionary]), @"equippedAccessories",
        [NSNumber numberWithInteger:_questStep], @"questStep",
        [NSNumber numberWithBool:_soundEnabled], @"soundEnabled",
        (_miniGameRewardDays ? _miniGameRewardDays : [NSDictionary dictionary]), @"miniGameRewardDays",
        [NSNumber numberWithInteger:_lastTownEventDay], @"lastTownEventDay",
        [NSNumber numberWithInteger:_lastNeighborRequestDay], @"lastNeighborRequestDay",
        [NSNumber numberWithInteger:_lastWorkDay], @"lastWorkDay",
        nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dictionary forKey:PKSavedGameKey];
    [defaults synchronize];
}

- (void)clear {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PKSavedGameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.pet = nil;
    self.sourceIdentifier = nil;
    [_inventoryIdentifiers removeAllObjects];
    [_placedItemIdentifiers removeAllObjects];
    [_memories removeAllObjects];
    [_collections removeAllObjects];
    [_ownedAccessoryIdentifiers removeAllObjects];
    [_equippedAccessories removeAllObjects];
    [_miniGameRewardDays removeAllObjects];
    _coins = 0;
    _day = 1;
    _actionCount = 0;
    _newHomeBadge = NO;
    _starterToy = NO;
    _questStep = 0;
    _soundEnabled = YES;
    _lastTownEventDay = 0;
    _lastNeighborRequestDay = 0;
    _lastWorkDay = 0;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        NSString *folder = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PatiMemories"];
        [[NSFileManager defaultManager] removeItemAtPath:folder error:nil];
    }
}

- (void)beginWithSource:(NSString *)source species:(NSString *)species name:(NSString *)name personality:(NSString *)personality {
    PKPet *newPet = [[PKPet alloc] initWithSpeciesIdentifier:species];
    newPet.name = name;
    newPet.personalityIdentifier = personality;
    if ([personality isEqualToString:@"musical"]) [newPet increaseSkillIdentifier:@"music" amount:1];
    if ([personality isEqualToString:@"curious"]) [newPet increaseSkillIdentifier:@"logic" amount:1];
    self.pet = newPet;
    [newPet release];
    self.sourceIdentifier = source;
    _coins = [source isEqualToString:@"shop"] ? 300 : 500;
    _day = 1;
    _actionCount = 0;
    _newHomeBadge = [source isEqualToString:@"shelter"];
    _starterToy = [source isEqualToString:@"shop"];
    _questStep = 0;
    _lastTownEventDay = 0;
    _lastNeighborRequestDay = 0;
    _lastWorkDay = 0;
    [_inventoryIdentifiers removeAllObjects];
    [_inventoryIdentifiers addObjectsFromArray:[NSArray arrayWithObjects:@"bed", @"bowl", nil]];
    if (_starterToy) [_inventoryIdentifiers addObject:@"ball"];
    [_placedItemIdentifiers removeAllObjects];
    [_placedItemIdentifiers addObjectsFromArray:[NSArray arrayWithObjects:@"bed", @"bowl", nil]];
    if (_starterToy) [_placedItemIdentifiers addObject:@"ball"];
    [_memories removeAllObjects];
    [_collections removeAllObjects];
    [_ownedAccessoryIdentifiers removeAllObjects];
    [_ownedAccessoryIdentifiers addObjectsFromArray:[NSArray arrayWithObjects:@"redbow", @"greencollar", nil]];
    [_equippedAccessories removeAllObjects];
    [_equippedAccessories setObject:@"redbow" forKey:@"head"];
    [_equippedAccessories setObject:@"greencollar" forKey:@"neck"];
    [_miniGameRewardDays removeAllObjects];
    [self addMemoryWithTitle:@"Yeni yuvamıza geldik" filename:nil];
    [self save];
}

- (void)advanceAction {
    _actionCount += 1;
    _pet.growthPoints += 1;
    if ((_actionCount % 4) == 0) {
        _day += 1;
        _coins += 20;
    }
}

- (void)applyCommonNeedDecay {
    _pet.satiety -= 3;
    _pet.energy -= 2;
    _pet.hygiene -= 1;
    _pet.fun -= 1;
    _pet.social -= 1;
    _pet.affection -= 1;
}

- (NSString *)finishActivityWithQuestEvent:(NSString *)eventIdentifier oldStage:(NSString *)oldStage {
    [_pet clampNeeds];
    [self advanceAction];
    NSMutableString *extra = [NSMutableString string];
    NSString *quest = [self registerQuestEvent:eventIdentifier];
    if ([quest length] > 0) [extra appendFormat:@"\n%@", quest];
    NSString *newStage = [_pet lifeStageIdentifier];
    if (oldStage && ![oldStage isEqualToString:newStage]) {
        NSString *title = [NSString stringWithFormat:@"%@ artık %@", _pet.name, [_pet lifeStageDisplayName]];
        [self addMemoryWithTitle:title filename:nil];
        [extra appendFormat:@"\nBüyüme anı: %@!", title];
    }
    NSString *freeWill = [self autonomousMessage];
    if ([freeWill length] > 0) [extra appendFormat:@"\n%@", freeWill];
    [self save];
    return extra;
}

- (NSString *)performActionIdentifier:(NSString *)identifier {
    if (!_pet) return @"Önce bir yavru sahiplenmelisin.";
    if ([identifier isEqualToString:@"feed"] && _coins < 5) return @"Mama için 5 pati parası gerekiyor.";
    NSString *oldStage = [_pet lifeStageIdentifier];
    [self applyCommonNeedDecay];
    NSString *message = nil;
    if ([identifier isEqualToString:@"feed"]) {
        _coins -= 5;
        _pet.satiety += 33 + ([self hasFunctionalItemForIdentifier:@"feed"] ? 5 : 0);
        message = @"Mamasını afiyetle yedi.";
    } else if ([identifier isEqualToString:@"play"]) {
        NSInteger bonus = [_pet.personalityIdentifier isEqualToString:@"playful"] ? 8 : 0;
        if ([self hasFunctionalItemForIdentifier:@"play"]) bonus += 5;
        _pet.fun += 25 + bonus;
        _pet.social += 10;
        _pet.energy -= 8;
        _pet.hygiene -= 5;
        message = @"Birlikte çok güzel oynadınız!";
    } else if ([identifier isEqualToString:@"sleep"]) {
        NSInteger bonus = [_pet.personalityIdentifier isEqualToString:@"sleepy"] ? 10 : 0;
        if ([self hasFunctionalItemForIdentifier:@"sleep"]) bonus += 5;
        _pet.energy += 35 + bonus;
        _pet.satiety -= 8;
        message = @"Güzel bir uyku çekti.";
    } else if ([identifier isEqualToString:@"clean"]) {
        _pet.hygiene += 38;
        _pet.fun -= 2;
        message = @"Şimdi tertemiz oldu.";
    } else if ([identifier isEqualToString:@"cuddle"]) {
        NSInteger bonus = [_pet.personalityIdentifier isEqualToString:@"social"] ? 8 : 0;
        _pet.affection += 30 + bonus;
        _pet.social += 18 + bonus;
        message = @"Sevildiğini hissetti.";
    } else {
        return @"Bu eylem henüz hazır değil.";
    }
    NSString *extra = [self finishActivityWithQuestEvent:identifier oldStage:oldStage];
    return [message stringByAppendingString:extra];
}

- (BOOL)ownsItemIdentifier:(NSString *)identifier { return [_inventoryIdentifiers containsObject:identifier]; }
- (BOOL)isItemPlaced:(NSString *)identifier { return [_placedItemIdentifiers containsObject:identifier]; }

- (BOOL)hasFunctionalItemForIdentifier:(NSString *)identifier {
    NSUInteger index = 0;
    for (index = 0; index < [_placedItemIdentifiers count]; index++) {
        NSDictionary *item = [PKCatalog itemForIdentifier:[_placedItemIdentifiers objectAtIndex:index]];
        if ([[item objectForKey:@"action"] isEqualToString:identifier]) return YES;
        if ([[item objectForKey:@"skill"] isEqualToString:identifier]) return YES;
    }
    return NO;
}

- (NSString *)interactWithPlacedItemIdentifier:(NSString *)identifier {
    if (![self isItemPlaced:identifier]) return @"Bu eşya şu anda odada değil.";
    NSDictionary *item = [PKCatalog itemForIdentifier:identifier];
    NSString *action = [item objectForKey:@"action"];
    NSString *skill = [item objectForKey:@"skill"];
    if ([action length] > 0) return [self performActionIdentifier:action];
    if ([skill length] > 0) return [self trainSkillIdentifier:skill];
    if ([identifier isEqualToString:@"rug"]) {
        NSString *message = [self performActionIdentifier:@"cuddle"];
        return [NSString stringWithFormat:@"Pati halısında birlikte dinlendiniz.\n%@", message];
    }
    return [NSString stringWithFormat:@"%@ odayı güzelleştiriyor.", [item objectForKey:@"name"]];
}

- (BOOL)ownsAccessoryIdentifier:(NSString *)identifier {
    return [_ownedAccessoryIdentifiers containsObject:identifier];
}

- (BOOL)isAccessoryEquipped:(NSString *)identifier {
    NSDictionary *accessory = [PKCatalog accessoryForIdentifier:identifier];
    NSString *slot = [accessory objectForKey:@"slot"];
    return [[_equippedAccessories objectForKey:slot] isEqualToString:identifier];
}

- (NSString *)buyAccessoryIdentifier:(NSString *)identifier {
    NSDictionary *accessory = [PKCatalog accessoryForIdentifier:identifier];
    if (!accessory) return @"Bu aksesuar bulunamadı.";
    if ([self ownsAccessoryIdentifier:identifier]) return @"Bu aksesuar zaten dolabında.";
    NSInteger price = [[accessory objectForKey:@"price"] integerValue];
    if (_coins < price) return @"Bu aksesuar için yeterli pati paran yok.";
    _coins -= price;
    [_ownedAccessoryIdentifiers addObject:identifier];
    [_equippedAccessories setObject:identifier forKey:[accessory objectForKey:@"slot"]];
    [self save];
    return [NSString stringWithFormat:@"%@ satın alındı ve giyildi.", [accessory objectForKey:@"name"]];
}

- (NSString *)toggleAccessoryIdentifier:(NSString *)identifier {
    NSDictionary *accessory = [PKCatalog accessoryForIdentifier:identifier];
    if (!accessory) return @"Bu aksesuar bulunamadı.";
    if (![self ownsAccessoryIdentifier:identifier]) return @"Önce bu aksesuarı almalısın.";
    NSString *slot = [accessory objectForKey:@"slot"];
    if ([self isAccessoryEquipped:identifier]) {
        [_equippedAccessories removeObjectForKey:slot];
        [self save];
        return [NSString stringWithFormat:@"%@ çıkarıldı.", [accessory objectForKey:@"name"]];
    }
    [_equippedAccessories setObject:identifier forKey:slot];
    [self save];
    return [NSString stringWithFormat:@"%@ giyildi.", [accessory objectForKey:@"name"]];
}

- (NSString *)buyItemIdentifier:(NSString *)identifier {
    NSDictionary *item = [PKCatalog itemForIdentifier:identifier];
    if (!item) return @"Bu eşya bulunamadı.";
    if ([self ownsItemIdentifier:identifier]) return @"Bu eşya zaten envanterinde.";
    NSInteger price = [[item objectForKey:@"price"] integerValue];
    if (_coins < price) return @"Bu eşya için yeterli pati paran yok.";
    _coins -= price;
    [_inventoryIdentifiers addObject:identifier];
    [self save];
    return [NSString stringWithFormat:@"%@ envanterine eklendi.", [item objectForKey:@"name"]];
}

- (NSString *)togglePlacementOfItemIdentifier:(NSString *)identifier {
    NSDictionary *item = [PKCatalog itemForIdentifier:identifier];
    if (![self ownsItemIdentifier:identifier]) return @"Önce bu eşyayı almalısın.";
    if ([self isItemPlaced:identifier]) {
        [_placedItemIdentifiers removeObject:identifier];
        [self save];
        return [NSString stringWithFormat:@"%@ envantere kaldırıldı.", [item objectForKey:@"name"]];
    }
    if ([_placedItemIdentifiers count] >= 6) return @"Odada en fazla 6 eşya olabilir.";
    [_placedItemIdentifiers addObject:identifier];
    NSString *quest = [self registerQuestEvent:@"decorate"];
    [self save];
    if ([quest length] > 0) return [NSString stringWithFormat:@"%@ odaya yerleşti.\n%@", [item objectForKey:@"name"], quest];
    return [NSString stringWithFormat:@"%@ odaya yerleşti.", [item objectForKey:@"name"]];
}

- (NSString *)trainSkillIdentifier:(NSString *)identifier {
    if (_coins < 10) return @"Ders için 10 pati parası gerekiyor.";
    NSString *oldStage = [_pet lifeStageIdentifier];
    _coins -= 10;
    NSInteger amount = [self hasFunctionalItemForIdentifier:identifier] ? 2 : 1;
    NSInteger level = [_pet increaseSkillIdentifier:identifier amount:amount];
    _pet.fun += 5;
    _pet.energy -= 5;
    NSString *extra = [self finishActivityWithQuestEvent:@"train" oldStage:oldStage];
    return [NSString stringWithFormat:@"%@ becerisi %ld oldu.%@", [PKCatalog skillDisplayName:identifier], (long)level, extra];
}

- (NSString *)chooseCareerIdentifier:(NSString *)identifier {
    if (![[_pet lifeStageIdentifier] isEqualToString:@"adult"]) return @"Meslek seçimi yetişkinlikte açılır.";
    NSString *skill = [PKCatalog careerSkillIdentifier:identifier];
    if ([_pet skillLevelForIdentifier:skill] < 3) return @"Bu meslek için ilgili becerinin en az 3 olması gerekiyor.";
    _pet.careerIdentifier = identifier;
    [self addMemoryWithTitle:[NSString stringWithFormat:@"İlk mesleğim: %@", [PKCatalog careerDisplayName:identifier]] filename:nil];
    [self save];
    return [NSString stringWithFormat:@"%@ mesleği seçildi!", [PKCatalog careerDisplayName:identifier]];
}

- (NSString *)workCareer {
    if ([_pet.careerIdentifier length] == 0) return @"Önce bir meslek seçmelisin.";
    if (_lastWorkDay == _day) return @"Bugünkü işi tamamladın; yarın yine çalışabilirsin.";
    NSString *oldStage = [_pet lifeStageIdentifier];
    _lastWorkDay = _day;
    _coins += 45;
    _pet.energy -= 8;
    NSString *extra = [self finishActivityWithQuestEvent:@"work" oldStage:oldStage];
    return [NSString stringWithFormat:@"%@ olarak çalıştı ve 45 pati parası kazandı.%@", [PKCatalog careerDisplayName:_pet.careerIdentifier], extra];
}

- (NSString *)visitNeighborIdentifier:(NSString *)identifier {
    NSDictionary *neighbor = [PKCatalog neighborForIdentifier:identifier];
    if (!neighbor) return @"Komşu bulunamadı.";
    NSString *oldStage = [_pet lifeStageIdentifier];
    NSInteger friendship = [_pet increaseFriendshipForNeighborIdentifier:identifier amount:8];
    [_pet increaseSkillIdentifier:[neighbor objectForKey:@"skill"] amount:1];
    _pet.social += 12;
    _pet.fun += 6;
    NSString *extra = [self finishActivityWithQuestEvent:@"town" oldStage:oldStage];
    if (friendship >= 40) [self addCollectionIdentifier:[NSString stringWithFormat:@"friend_%@", identifier]];
    [self save];
    return [NSString stringWithFormat:@"%@ ile güzel vakit geçirdi. Arkadaşlık: %ld/100.%@", [neighbor objectForKey:@"name"], (long)friendship, extra];
}

- (NSString *)attendTownEvent {
    if (_lastTownEventDay == _day) return @"Bugünün kasaba etkinliğine zaten katıldın.";
    NSString *oldStage = [_pet lifeStageIdentifier];
    _lastTownEventDay = _day;
    _coins += 25;
    [self addCollectionIdentifier:[NSString stringWithFormat:@"event_%ld", (long)((_day - 1) % 4)]];
    [self addMemoryWithTitle:[NSString stringWithFormat:@"%@ etkinliğine katıldık", [self townEventDisplayName]] filename:nil];
    NSString *extra = [self finishActivityWithQuestEvent:@"town" oldStage:oldStage];
    return [NSString stringWithFormat:@"%@ tamamlandı: 25 pati parası ve bir koleksiyon rozeti!%@", [self townEventDisplayName], extra];
}

- (NSString *)neighborRequestText {
    NSDictionary *request = [self currentNeighborRequest];
    NSDictionary *neighbor = [PKCatalog neighborForIdentifier:[request objectForKey:@"neighbor"]];
    if (_lastNeighborRequestDay == _day) return [NSString stringWithFormat:@"%@'nın “%@” isteği tamamlandı ✓", [neighbor objectForKey:@"name"], [request objectForKey:@"title"]];
    return [NSString stringWithFormat:@"%@ — %@\nYer: %@", [request objectForKey:@"title"], [request objectForKey:@"detail"], [PKCatalog locationDisplayName:[request objectForKey:@"location"]]];
}

- (NSDictionary *)currentNeighborRequest {
    return [PKCatalog neighborRequestForDay:_day];
}

- (BOOL)isNeighborRequestAtLocation:(NSString *)locationIdentifier {
    return [[[self currentNeighborRequest] objectForKey:@"location"] isEqualToString:locationIdentifier];
}

- (BOOL)isNeighborRequestCompletedToday {
    return _lastNeighborRequestDay == _day;
}

- (NSString *)completeNeighborRequest {
    return [self completeNeighborRequestAtLocation:[[self currentNeighborRequest] objectForKey:@"location"]];
}

- (NSString *)completeNeighborRequestAtLocation:(NSString *)locationIdentifier {
    if (_lastNeighborRequestDay == _day) return @"Bugünkü komşu isteğini zaten tamamladın.";
    NSDictionary *request = [self currentNeighborRequest];
    NSString *expectedLocation = [request objectForKey:@"location"];
    if (![expectedLocation isEqualToString:locationIdentifier]) return [NSString stringWithFormat:@"Bu görev %@ bölgesinde yapılmalı.", [PKCatalog locationDisplayName:expectedLocation]];
    NSDictionary *neighbor = [PKCatalog neighborForIdentifier:[request objectForKey:@"neighbor"]];
    NSString *identifier = [request objectForKey:@"neighbor"];
    NSString *oldStage = [_pet lifeStageIdentifier];
    _lastNeighborRequestDay = _day;
    _coins += 20;
    NSInteger friendship = [_pet increaseFriendshipForNeighborIdentifier:identifier amount:12];
    [_pet increaseSkillIdentifier:[request objectForKey:@"skill"] amount:1];
    _pet.social += 8;
    NSString *extra = [self finishActivityWithQuestEvent:@"town" oldStage:oldStage];
    if (friendship >= 40) [self addCollectionIdentifier:[NSString stringWithFormat:@"friend_%@", identifier]];
    [self save];
    return [NSString stringWithFormat:@"“%@” tamamlandı! %@ ile arkadaşlık %ld/100 ve 20 pati kazandın.%@", [request objectForKey:@"title"], [neighbor objectForKey:@"name"], (long)friendship, extra];
}

- (NSString *)awardMiniGameIdentifier:(NSString *)identifier {
    NSNumber *rewardDay = [_miniGameRewardDays objectForKey:identifier];
    if (rewardDay && [rewardDay integerValue] == _day) return @"Harika! Bugünün ödülünü daha önce aldın.";
    NSString *oldStage = [_pet lifeStageIdentifier];
    [_miniGameRewardDays setObject:[NSNumber numberWithInteger:_day] forKey:identifier];
    _coins += 30;
    _pet.fun += 12;
    NSString *extra = [self finishActivityWithQuestEvent:@"game" oldStage:oldStage];
    return [NSString stringWithFormat:@"Kazandın! 30 pati parası senin.%@", extra];
}

- (void)addMemoryWithTitle:(NSString *)title filename:(NSString *)filename {
    if ([title length] == 0) return;
    NSDictionary *memory = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", [NSNumber numberWithInteger:_day], @"day", (filename ? filename : @""), @"filename", nil];
    [_memories insertObject:memory atIndex:0];
    while ([_memories count] > 12) [_memories removeLastObject];
    [self pruneMemoryPhotos];
}

- (void)pruneMemoryPhotos {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0) return;
    NSString *folder = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PatiMemories"];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    if (![files isKindOfClass:[NSArray class]]) return;
    NSMutableSet *kept = [NSMutableSet set];
    NSUInteger index = 0;
    for (index = 0; index < [_memories count]; index++) {
        NSString *filename = [[_memories objectAtIndex:index] objectForKey:@"filename"];
        if ([filename length] > 0) [kept addObject:filename];
    }
    for (index = 0; index < [files count]; index++) {
        NSString *filename = [files objectAtIndex:index];
        if (![kept containsObject:filename]) [[NSFileManager defaultManager] removeItemAtPath:[folder stringByAppendingPathComponent:filename] error:nil];
    }
}

- (void)addCollectionIdentifier:(NSString *)identifier {
    if (identifier && ![_collections containsObject:identifier]) [_collections addObject:identifier];
}

- (NSString *)registerQuestEvent:(NSString *)eventIdentifier {
    NSArray *events = [NSArray arrayWithObjects:@"feed", @"play", @"clean", @"town", @"train", @"decorate", nil];
    if (_questStep >= (NSInteger)[events count]) return @"";
    if (![[events objectAtIndex:(NSUInteger)_questStep] isEqualToString:eventIdentifier]) return @"";
    _questStep += 1;
    NSInteger reward = (_questStep == (NSInteger)[events count]) ? 50 : 15;
    _coins += reward;
    if (_questStep == (NSInteger)[events count]) {
        [self addMemoryWithTitle:@"İlk Pati Rehberini tamamladık" filename:nil];
        return @"Pati Rehberi tamamlandı! 50 pati parası kazandın.";
    }
    return [NSString stringWithFormat:@"Rehber adımı tamamlandı: %ld pati parası!", (long)reward];
}

- (NSString *)questText {
    NSArray *texts = [NSArray arrayWithObjects:@"İlk görev: yavrunu besle", @"Birlikte oyun oyna", @"Yavrunu temizle", @"Kasabada bir komşuyu ziyaret et", @"Okulda bir beceri çalış", @"Odana yeni bir eşya yerleştir", nil];
    if (_questStep >= (NSInteger)[texts count]) return @"Pati Rehberi tamamlandı ✓";
    return [texts objectAtIndex:(NSUInteger)_questStep];
}

- (NSString *)sourceDisplayName { return [_sourceIdentifier isEqualToString:@"shop"] ? @"Pet Shop" : @"Barınak"; }

- (NSString *)dayPartDisplayName {
    NSInteger part = _actionCount % 4;
    if (part == 0) return @"Sabah";
    if (part == 1) return @"Öğle";
    if (part == 2) return @"Akşam";
    return @"Gece";
}

- (NSString *)seasonDisplayName {
    NSInteger season = ((_day - 1) / 3) % 4;
    if (season == 0) return @"İlkbahar";
    if (season == 1) return @"Yaz";
    if (season == 2) return @"Sonbahar";
    return @"Kış";
}

- (NSString *)townEventDisplayName {
    NSInteger event = (_day - 1) % 4;
    if (event == 0) return @"Çiçek Pikniği";
    if (event == 1) return @"Müzik Günü";
    if (event == 2) return @"Renk Şenliği";
    return @"Yıldız Gecesi";
}

- (NSString *)autonomousMessage {
    if (_actionCount == 0 || (_actionCount % 3) != 0) return @"";
    NSString *personality = _pet.personalityIdentifier;
    if ([personality isEqualToString:@"curious"]) return [NSString stringWithFormat:@"%@ merakla penceredeki kuşu izledi.", _pet.name];
    if ([personality isEqualToString:@"sleepy"]) return [NSString stringWithFormat:@"%@ yatağında keyifle esnedi.", _pet.name];
    if ([personality isEqualToString:@"social"]) return [NSString stringWithFormat:@"%@ komşularına el salladı.", _pet.name];
    if ([personality isEqualToString:@"musical"]) return [NSString stringWithFormat:@"%@ kendi kendine bir melodi mırıldandı.", _pet.name];
    return [NSString stringWithFormat:@"%@ topuyla kısa bir oyun kurdu.", _pet.name];
}

- (void)dealloc {
    [_pet release];
    [_sourceIdentifier release];
    [_inventoryIdentifiers release];
    [_placedItemIdentifiers release];
    [_memories release];
    [_collections release];
    [_ownedAccessoryIdentifiers release];
    [_equippedAccessories release];
    [_miniGameRewardDays release];
    [super dealloc];
}

@end
