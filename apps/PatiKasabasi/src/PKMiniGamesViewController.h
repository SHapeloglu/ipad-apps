#import "PKBaseViewController.h"

@class PKGameState;

@interface PKMiniGamesViewController : PKBaseViewController {
    PKGameState *_gameState;
    NSMutableArray *_memoryValues;
    NSMutableArray *_memoryButtons;
    NSInteger _firstMemoryIndex;
    NSInteger _foundPairs;
    BOOL _memoryLocked;
    UIView *_memoryBoard;
    UILabel *_memoryStatusLabel;
    UILabel *_mathQuestionLabel;
    UILabel *_mathStatusLabel;
    UILabel *_feedbackLabel;
    NSInteger _mathAnswer;
    NSInteger _mathCorrectCount;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
