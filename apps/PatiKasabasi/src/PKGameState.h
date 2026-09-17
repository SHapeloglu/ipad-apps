#import <Foundation/Foundation.h>

@class PKPet;

@interface PKGameState : NSObject {
    PKPet *_pet;
    NSString *_sourceIdentifier;
    NSInteger _coins;
    NSInteger _day;
    NSInteger _actionCount;
    BOOL _newHomeBadge;
    BOOL _starterToy;
    NSMutableArray *_inventoryIdentifiers;
    NSMutableArray *_placedItemIdentifiers;
    NSMutableArray *_memories;
    NSMutableArray *_collections;
    NSMutableArray *_ownedAccessoryIdentifiers;
    NSMutableDictionary *_equippedAccessories;
    NSInteger _questStep;
    BOOL _soundEnabled;
    NSMutableDictionary *_miniGameRewardDays;
    NSInteger _lastTownEventDay;
    NSInteger _lastNeighborRequestDay;
    NSInteger _lastWorkDay;
}

@property(nonatomic, retain) PKPet *pet;
@property(nonatomic, copy) NSString *sourceIdentifier;
@property(nonatomic, assign) NSInteger coins;
@property(nonatomic, assign) NSInteger day;
@property(nonatomic, assign) NSInteger actionCount;
@property(nonatomic, assign) BOOL newHomeBadge;
@property(nonatomic, assign) BOOL starterToy;
@property(nonatomic, retain) NSMutableArray *inventoryIdentifiers;
@property(nonatomic, retain) NSMutableArray *placedItemIdentifiers;
@property(nonatomic, retain) NSMutableArray *memories;
@property(nonatomic, retain) NSMutableArray *collections;
@property(nonatomic, retain) NSMutableArray *ownedAccessoryIdentifiers;
@property(nonatomic, retain) NSMutableDictionary *equippedAccessories;
@property(nonatomic, assign) NSInteger questStep;
@property(nonatomic, assign) BOOL soundEnabled;

- (BOOL)hasSavedGame;
- (BOOL)load;
- (void)save;
- (void)clear;
- (void)beginWithSource:(NSString *)source
                species:(NSString *)species
                   name:(NSString *)name
            personality:(NSString *)personality;

- (NSString *)performActionIdentifier:(NSString *)identifier;
- (NSString *)performFeedWithFoodIdentifier:(NSString *)foodIdentifier;
- (NSString *)buyItemIdentifier:(NSString *)identifier;
- (NSString *)togglePlacementOfItemIdentifier:(NSString *)identifier;
- (BOOL)ownsItemIdentifier:(NSString *)identifier;
- (BOOL)isItemPlaced:(NSString *)identifier;
- (BOOL)hasFunctionalItemForIdentifier:(NSString *)identifier;
- (NSString *)interactWithPlacedItemIdentifier:(NSString *)identifier;

- (BOOL)ownsAccessoryIdentifier:(NSString *)identifier;
- (BOOL)isAccessoryEquipped:(NSString *)identifier;
- (NSString *)buyAccessoryIdentifier:(NSString *)identifier;
- (NSString *)toggleAccessoryIdentifier:(NSString *)identifier;

- (NSString *)trainSkillIdentifier:(NSString *)identifier;
- (NSString *)chooseCareerIdentifier:(NSString *)identifier;
- (NSString *)workCareer;
- (NSString *)visitNeighborIdentifier:(NSString *)identifier;
- (NSString *)attendTownEvent;
- (NSString *)neighborRequestText;
- (NSDictionary *)currentNeighborRequest;
- (BOOL)isNeighborRequestAtLocation:(NSString *)locationIdentifier;
- (BOOL)isNeighborRequestCompletedToday;
- (NSString *)completeNeighborRequest;
- (NSString *)completeNeighborRequestAtLocation:(NSString *)locationIdentifier;
- (NSString *)awardMiniGameIdentifier:(NSString *)identifier;

- (void)addMemoryWithTitle:(NSString *)title filename:(NSString *)filename;
- (NSString *)registerQuestEvent:(NSString *)eventIdentifier;
- (NSString *)questText;
- (NSString *)sourceDisplayName;
- (NSString *)dayPartDisplayName;
- (NSString *)seasonDisplayName;
- (NSString *)townEventDisplayName;
- (NSString *)autonomousMessage;

@end
