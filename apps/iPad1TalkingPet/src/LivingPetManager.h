#import <Foundation/Foundation.h>
@class PetCharacterView;

@interface LivingPetManager : NSObject {
    PetCharacterView *_pet;
    NSTimer *_timer;
}
- (id)initWithPet:(PetCharacterView *)pet;
- (void)start;
- (void)stop;
@end
