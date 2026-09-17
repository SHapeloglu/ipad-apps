#import "PKBaseViewController.h"

@class PKGameState;
@class PKPetCardControl;

@interface PKPetSelectionViewController : PKBaseViewController {
    PKGameState *_gameState;
    NSString *_sourceIdentifier;
    NSMutableArray *_cards;
    NSString *_selectedSpeciesIdentifier;
    UIButton *_continueButton;
}

- (id)initWithGameState:(PKGameState *)gameState source:(NSString *)source;

@end
