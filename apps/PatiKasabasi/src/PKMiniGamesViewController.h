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
    UIView *_ballBoard;
    UIButton *_ballButton;
    UIButton *_ballStartButton;
    UILabel *_ballStatusLabel;
    NSInteger _ballRound;
    NSInteger _ballScore;
    BOOL _ballGameActive;
    BOOL _ballCaughtThisRound;
}

- (id)initWithGameState:(PKGameState *)gameState;

@end
