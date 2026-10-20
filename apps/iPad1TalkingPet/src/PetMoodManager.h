#import <Foundation/Foundation.h>

typedef enum {
    PetMoodHappy = 0,
    PetMoodHungry,
    PetMoodDirty,
    PetMoodSleepy,
    PetMoodBored,
    PetMoodNeutral
} PetMood;

@class PetNeedsManager;

@interface PetMoodManager : NSObject
+ (PetMoodManager *)sharedManager;
- (PetMood)moodForNeeds:(PetNeedsManager *)needs;
- (NSString *)moodTitleForNeeds:(PetNeedsManager *)needs;
- (NSString *)moodHintForNeeds:(PetNeedsManager *)needs;
@end
