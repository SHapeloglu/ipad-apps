#import <Foundation/Foundation.h>

@interface PKCatalog : NSObject

+ (NSArray *)itemIdentifiers;
+ (NSDictionary *)itemForIdentifier:(NSString *)identifier;
+ (NSArray *)skillIdentifiers;
+ (NSString *)skillDisplayName:(NSString *)identifier;
+ (NSArray *)neighbors;
+ (NSDictionary *)neighborForIdentifier:(NSString *)identifier;
+ (NSArray *)careerIdentifiers;
+ (NSString *)careerDisplayName:(NSString *)identifier;
+ (NSString *)careerSkillIdentifier:(NSString *)identifier;
+ (NSArray *)accessoryIdentifiers;
+ (NSDictionary *)accessoryForIdentifier:(NSString *)identifier;
+ (NSArray *)accessorySlots;
+ (NSString *)accessorySlotDisplayName:(NSString *)slotIdentifier;
+ (NSArray *)neighborRequests;
+ (NSDictionary *)neighborRequestForDay:(NSInteger)day;
+ (NSString *)locationDisplayName:(NSString *)identifier;

@end
