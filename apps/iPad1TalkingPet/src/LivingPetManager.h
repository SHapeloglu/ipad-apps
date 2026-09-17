#import <Foundation/Foundation.h>
@class PetCharacterView;
@class PetNeedsManager;

@interface LivingPetManager : NSObject {
    PetCharacterView *_pet;
    PetNeedsManager *_needs;
    NSTimer *_timer;
}
- (id)initWithPet:(PetCharacterView *)pet needs:(PetNeedsManager *)needs;
- (void)start;
- (void)stop;
- (void)performImmediateMoodReaction;
@end
