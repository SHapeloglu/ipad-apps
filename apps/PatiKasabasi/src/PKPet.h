#import <Foundation/Foundation.h>

@interface PKPet : NSObject {
    NSString *_name;
    NSString *_speciesIdentifier;
    NSString *_personalityIdentifier;
    NSInteger _satiety;
    NSInteger _energy;
    NSInteger _hygiene;
    NSInteger _fun;
    NSInteger _social;
    NSInteger _affection;
    NSInteger _growthPoints;
    NSMutableDictionary *_skills;
    NSMutableDictionary *_relationships;
    NSString *_careerIdentifier;
}

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *speciesIdentifier;
@property(nonatomic, copy) NSString *personalityIdentifier;
@property(nonatomic, assign) NSInteger satiety;
@property(nonatomic, assign) NSInteger energy;
@property(nonatomic, assign) NSInteger hygiene;
@property(nonatomic, assign) NSInteger fun;
@property(nonatomic, assign) NSInteger social;
@property(nonatomic, assign) NSInteger affection;
@property(nonatomic, assign) NSInteger growthPoints;
@property(nonatomic, retain) NSMutableDictionary *skills;
@property(nonatomic, retain) NSMutableDictionary *relationships;
@property(nonatomic, copy) NSString *careerIdentifier;

- (id)initWithSpeciesIdentifier:(NSString *)speciesIdentifier;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;
- (NSString *)speciesDisplayName;
- (NSString *)personalityDisplayName;
- (NSString *)moodText;
- (NSString *)lifeStageIdentifier;
- (NSString *)lifeStageDisplayName;
- (NSInteger)skillLevelForIdentifier:(NSString *)identifier;
- (NSInteger)increaseSkillIdentifier:(NSString *)identifier amount:(NSInteger)amount;
- (NSInteger)friendshipForNeighborIdentifier:(NSString *)identifier;
- (NSInteger)increaseFriendshipForNeighborIdentifier:(NSString *)identifier amount:(NSInteger)amount;
- (void)clampNeeds;

@end
