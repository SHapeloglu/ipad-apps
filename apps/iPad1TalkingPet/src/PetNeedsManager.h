#import <Foundation/Foundation.h>

@interface PetNeedsManager : NSObject {
    NSInteger _hunger;
    NSInteger _happiness;
    NSInteger _hygiene;
    NSInteger _energy;
    NSInteger _coins;
}

@property (nonatomic, assign) NSInteger hunger;
@property (nonatomic, assign) NSInteger happiness;
@property (nonatomic, assign) NSInteger hygiene;
@property (nonatomic, assign) NSInteger energy;
@property (nonatomic, assign) NSInteger coins;

- (void)loadState;
- (void)saveState;
- (void)feed;
- (void)play;
- (void)bathe;
- (void)sleep;

@end
