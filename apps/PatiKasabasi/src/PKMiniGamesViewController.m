#import "PKMiniGamesViewController.h"
#import "PKGameState.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>

@interface PKMiniGamesViewController ()
- (void)shuffleMutableArray:(NSMutableArray *)array;
- (void)resetMemoryGame;
- (void)hideMemoryPair:(NSArray *)indexes;
- (void)nextMathQuestion;
@end

@implementation PKMiniGamesViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _memoryValues = [[NSMutableArray alloc] init];
        _memoryButtons = [[NSMutableArray alloc] init];
        _firstMemoryIndex = -1;
        _mathCorrectCount = 0;
        self.title = @"Oyun Bahçesi";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 10.0f, 500.0f, 42.0f) text:@"Mini Oyunlar" fontSize:28.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    UILabel *coins = [self labelWithFrame:CGRectMake(700.0f, 10.0f, 290.0f, 42.0f) text:@"Her oyundan günde 30 pati" fontSize:18.0f bold:YES];
    [self.view addSubview:coins];

    UIView *memoryPanel = [[[UIView alloc] initWithFrame:CGRectMake(30.0f, 60.0f, 470.0f, 505.0f)] autorelease];
    [PKTheme stylePanel:memoryPanel];
    [self.view addSubview:memoryPanel];
    UILabel *memoryTitle = [self labelWithFrame:CGRectMake(15.0f, 10.0f, 300.0f, 38.0f) text:@"Pati Eşleştirme" fontSize:23.0f bold:YES];
    memoryTitle.textAlignment = UITextAlignmentLeft;
    [memoryPanel addSubview:memoryTitle];
    UIButton *shuffle = [self secondaryButtonWithFrame:CGRectMake(330.0f, 8.0f, 125.0f, 42.0f) title:@"Karıştır"];
    shuffle.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [shuffle addTarget:self action:@selector(resetMemoryGame) forControlEvents:UIControlEventTouchUpInside];
    [memoryPanel addSubview:shuffle];
    _memoryStatusLabel = [[self labelWithFrame:CGRectMake(15.0f, 52.0f, 440.0f, 35.0f) text:@"4 çifti bul" fontSize:17.0f bold:NO] retain];
    [memoryPanel addSubview:_memoryStatusLabel];
    _memoryBoard = [[UIView alloc] initWithFrame:CGRectMake(17.0f, 92.0f, 436.0f, 400.0f)];
    [memoryPanel addSubview:_memoryBoard];

    UIView *mathPanel = [[[UIView alloc] initWithFrame:CGRectMake(524.0f, 60.0f, 470.0f, 505.0f)] autorelease];
    [PKTheme stylePanel:mathPanel];
    [self.view addSubview:mathPanel];
    UILabel *mathTitle = [self labelWithFrame:CGRectMake(20.0f, 12.0f, 430.0f, 40.0f) text:@"Mama Matematiği" fontSize:23.0f bold:YES];
    [mathPanel addSubview:mathTitle];
    UILabel *instruction = [self labelWithFrame:CGRectMake(20.0f, 58.0f, 430.0f, 48.0f) text:@"Mama kaplarını say: 5 doğru yanıtla turu tamamla." fontSize:17.0f bold:NO];
    [mathPanel addSubview:instruction];
    _mathQuestionLabel = [[self labelWithFrame:CGRectMake(30.0f, 125.0f, 410.0f, 105.0f) text:@"" fontSize:42.0f bold:YES] retain];
    _mathQuestionLabel.textColor = [PKTheme darkTealColor];
    [mathPanel addSubview:_mathQuestionLabel];
    NSInteger index = 0;
    for (index = 0; index < 3; index++) {
        UIButton *answer = [self secondaryButtonWithFrame:CGRectMake(45.0f, 245.0f + (70.0f * index), 380.0f, 56.0f) title:@"-"];
        answer.tag = 500 + index;
        [answer addTarget:self action:@selector(mathTapped:) forControlEvents:UIControlEventTouchUpInside];
        [mathPanel addSubview:answer];
    }
    _mathStatusLabel = [[self labelWithFrame:CGRectMake(20.0f, 455.0f, 430.0f, 36.0f) text:@"Doğru: 0/5" fontSize:18.0f bold:YES] retain];
    [mathPanel addSubview:_mathStatusLabel];

    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 580.0f, 964.0f, 78.0f) text:@"Bir oyun seç ve eğlen! Ödül sınırı yalnızca parayı etkiler; oynamaya devam edebilirsin." fontSize:18.0f bold:NO] retain];
    _feedbackLabel.backgroundColor = [PKTheme panelColor];
    _feedbackLabel.layer.cornerRadius = 12.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];

    [self resetMemoryGame];
    [self nextMathQuestion];
}

- (void)shuffleMutableArray:(NSMutableArray *)array {
    NSInteger index = (NSInteger)[array count] - 1;
    for (; index > 0; index--) {
        NSUInteger other = (NSUInteger)arc4random_uniform((uint32_t)(index + 1));
        [array exchangeObjectAtIndex:(NSUInteger)index withObjectAtIndex:other];
    }
}

- (void)resetMemoryGame {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSUInteger oldIndex = 0;
    for (oldIndex = 0; oldIndex < [_memoryButtons count]; oldIndex++) [[_memoryButtons objectAtIndex:oldIndex] removeFromSuperview];
    [_memoryButtons removeAllObjects];
    [_memoryValues removeAllObjects];
    NSInteger pair = 1;
    for (pair = 1; pair <= 4; pair++) {
        [_memoryValues addObject:[NSNumber numberWithInteger:pair]];
        [_memoryValues addObject:[NSNumber numberWithInteger:pair]];
    }
    [self shuffleMutableArray:_memoryValues];
    NSInteger index = 0;
    for (index = 0; index < 8; index++) {
        NSInteger column = index % 4;
        NSInteger row = index / 4;
        UIButton *button = [self primaryButtonWithFrame:CGRectMake(7.0f + (107.0f * column), 12.0f + (181.0f * row), 100.0f, 150.0f) title:@"?"];
        button.tag = index;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:38.0f];
        [button addTarget:self action:@selector(memoryTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_memoryBoard addSubview:button];
        [_memoryButtons addObject:button];
    }
    _firstMemoryIndex = -1;
    _foundPairs = 0;
    _memoryLocked = NO;
    _memoryStatusLabel.text = @"4 çifti bul";
}

- (void)memoryTapped:(UIButton *)sender {
    if (_memoryLocked || !sender.enabled || sender.tag == _firstMemoryIndex) return;
    NSInteger index = sender.tag;
    NSNumber *value = [_memoryValues objectAtIndex:(NSUInteger)index];
    [sender setTitle:[value stringValue] forState:UIControlStateNormal];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    if (_firstMemoryIndex < 0) {
        _firstMemoryIndex = index;
        return;
    }
    UIButton *firstButton = [_memoryButtons objectAtIndex:(NSUInteger)_firstMemoryIndex];
    NSNumber *firstValue = [_memoryValues objectAtIndex:(NSUInteger)_firstMemoryIndex];
    if ([firstValue isEqualToNumber:value]) {
        firstButton.enabled = NO;
        sender.enabled = NO;
        firstButton.alpha = 0.55f;
        sender.alpha = 0.55f;
        _firstMemoryIndex = -1;
        _foundPairs += 1;
        _memoryStatusLabel.text = [NSString stringWithFormat:@"Bulunan çift: %ld/4", (long)_foundPairs];
        if (_foundPairs == 4) {
            _feedbackLabel.text = [_gameState awardMiniGameIdentifier:@"memory"];
            [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
        }
    } else {
        _memoryLocked = YES;
        NSArray *indexes = [NSArray arrayWithObjects:[NSNumber numberWithInteger:_firstMemoryIndex], [NSNumber numberWithInteger:index], nil];
        [self performSelector:@selector(hideMemoryPair:) withObject:indexes afterDelay:0.65f];
    }
}

- (void)hideMemoryPair:(NSArray *)indexes {
    NSUInteger index = 0;
    for (index = 0; index < [indexes count]; index++) {
        NSInteger buttonIndex = [[indexes objectAtIndex:index] integerValue];
        UIButton *button = [_memoryButtons objectAtIndex:(NSUInteger)buttonIndex];
        [button setTitle:@"?" forState:UIControlStateNormal];
    }
    _firstMemoryIndex = -1;
    _memoryLocked = NO;
}

- (void)nextMathQuestion {
    NSInteger left = 1 + (NSInteger)arc4random_uniform(9);
    NSInteger right = 1 + (NSInteger)arc4random_uniform(9);
    _mathAnswer = left + right;
    _mathQuestionLabel.text = [NSString stringWithFormat:@"%ld + %ld = ?", (long)left, (long)right];
    NSMutableArray *answers = [NSMutableArray arrayWithObjects:
        [NSNumber numberWithInteger:_mathAnswer],
        [NSNumber numberWithInteger:_mathAnswer + 1 + (NSInteger)arc4random_uniform(3)],
        [NSNumber numberWithInteger:MAX(1, _mathAnswer - 1 - (NSInteger)arc4random_uniform(3))], nil];
    if ([[answers objectAtIndex:1] isEqual:[answers objectAtIndex:2]]) [answers replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:_mathAnswer + 4]];
    [self shuffleMutableArray:answers];
    NSInteger index = 0;
    for (index = 0; index < 3; index++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:500 + index];
        NSInteger answer = [[answers objectAtIndex:(NSUInteger)index] integerValue];
        button.accessibilityValue = [NSString stringWithFormat:@"%ld", (long)answer];
        [button setTitle:[NSString stringWithFormat:@"%ld", (long)answer] forState:UIControlStateNormal];
    }
}

- (void)mathTapped:(UIButton *)sender {
    NSInteger selected = [sender.accessibilityValue integerValue];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    if (selected == _mathAnswer) {
        _mathCorrectCount += 1;
        _feedbackLabel.text = @"Doğru! Yeni bir mama hesabı geliyor.";
        if (_mathCorrectCount >= 5) {
            _feedbackLabel.text = [_gameState awardMiniGameIdentifier:@"math"];
            _mathCorrectCount = 0;
            [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
        }
    } else {
        _feedbackLabel.text = [NSString stringWithFormat:@"Yaklaştın. Doğru cevap %ld; yeni soruda tekrar deneyelim.", (long)_mathAnswer];
    }
    _mathStatusLabel.text = [NSString stringWithFormat:@"Doğru: %ld/5", (long)_mathCorrectCount];
    [self nextMathQuestion];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_gameState save];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_gameState release];
    [_memoryValues release];
    [_memoryButtons release];
    [_memoryBoard release];
    [_memoryStatusLabel release];
    [_mathQuestionLabel release];
    [_mathStatusLabel release];
    [_feedbackLabel release];
    [super dealloc];
}

@end
