#import "PKBaseViewController.h"

@class PKGameState;
@class PKPetAvatarView;

@interface PKNamingViewController : PKBaseViewController <UITextFieldDelegate> {
    PKGameState *_gameState;
    NSString *_sourceIdentifier;
    NSString *_speciesIdentifier;
    UITextField *_nameField;
    UISegmentedControl *_personalityControl;
    UILabel *_personalityDescriptionLabel;
    PKPetAvatarView *_avatarView;
}

- (id)initWithGameState:(PKGameState *)gameState
                  source:(NSString *)source
                 species:(NSString *)species;

@end
