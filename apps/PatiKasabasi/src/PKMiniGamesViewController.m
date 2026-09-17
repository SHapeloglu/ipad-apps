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
- (void)startBallGame;
- (void)advanceBallRound;
- (void)ballTapped:(UIButton *)sender;
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
        _ballGameActive = NO;
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

    UIView *memoryPanel = [[[UIView alloc] initWithFrame:CGRectMake(22.0f, 60.0f, 318.0f, 505.0f)] autorelease];
    [PKTheme stylePanel:memoryPanel];
    [self.view addSubview:memoryPanel];
    UILabel *memoryTitle = [self labelWithFrame:CGRectMake(12.0f, 10.0f, 196.0f, 38.0f) text:@"Pati Eşleştirme" fontSize:21.0f bold:YES];
    memoryTitle.textAlignment = UITextAlignmentLeft;
    [memoryPanel addSubview:memoryTitle];
    UIButton *shuffle = [self secondaryButtonWithFrame:CGRectMake(214.0f, 8.0f, 92.0f, 42.0f) title:@"Karıştır"];
    shuffle.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    [shuffle addTarget:self action:@selector(resetMemoryGame) forControlEvents:UIControlEventTouchUpInside];
    [memoryPanel addSubview:shuffle];
    _memoryStatusLabel = [[self labelWithFrame:CGRectMake(12.0f, 52.0f, 294.0f, 35.0f) text:@"4 çifti bul" fontSize:17.0f bold:NO] retain];
    [memoryPanel addSubview:_memoryStatusLabel];
    _memoryBoard = [[UIView alloc] initWithFrame:CGRectMake(12.0f, 92.0f, 294.0f, 400.0f)];
    [memoryPanel addSubview:_memoryBoard];

    UIView *mathPanel = [[[UIView alloc] initWithFrame:CGRectMake(353.0f, 60.0f, 318.0f, 505.0f)] autorelease];
    [PKTheme stylePanel:mathPanel];
    [self.view addSubview:mathPanel];
    UILabel *mathTitle = [self labelWithFrame:CGRectMake(16.0f, 12.0f, 286.0f, 40.0f) text:@"Mama Matematiği" fontSize:21.0f bold:YES];
    [mathPanel addSubview:mathTitle];
    UILabel *instruction = [self labelWithFrame:CGRectMake(16.0f, 58.0f, 286.0f, 58.0f) text:@"Mama kaplarını say: 5 doğru yanıtla turu tamamla." fontSize:16.0f bold:NO];
    [mathPanel addSubview:instruction];
    _mathQuestionLabel = [[self labelWithFrame:CGRectMake(20.0f, 125.0f, 278.0f, 105.0f) text:@"" fontSize:38.0f bold:YES] retain];
    _mathQuestionLabel.textColor = [PKTheme darkTealColor];
    [mathPanel addSubview:_mathQuestionLabel];
    NSInteger index = 0;
    for (index = 0; index < 3; index++) {
        UIButton *answer = [self secondaryButtonWithFrame:CGRectMake(25.0f, 245.0f + (70.0f * index), 268.0f, 56.0f) title:@"-"];
        answer.tag = 500 + index;
        [answer addTarget:self action:@selector(mathTapped:) forControlEvents:UIControlEventTouchUpInside];
        [mathPanel addSubview:answer];
    }
    _mathStatusLabel = [[self labelWithFrame:CGRectMake(16.0f, 455.0f, 286.0f, 36.0f) text:@"Doğru: 0/5" fontSize:18.0f bold:YES] retain];
    [mathPanel addSubview:_mathStatusLabel];

    UIView *ballPanel = [[[UIView alloc] initWithFrame:CGRectMake(684.0f, 60.0f, 318.0f, 505.0f)] autorelease];
    [PKTheme stylePanel:ballPanel];
    [self.view addSubview:ballPanel];
    UILabel *ballTitle = [self labelWithFrame:CGRectMake(16.0f, 10.0f, 286.0f, 38.0f) text:@"Top Yakala" fontSize:21.0f bold:YES];
    [ballPanel addSubview:ballTitle];
    UILabel *ballInstruction = [self labelWithFrame:CGRectMake(16.0f, 48.0f, 286.0f, 44.0f) text:@"Hareket eden topa 8 turda en az 5 kez dokun." fontSize:15.0f bold:NO];
    [ballPanel addSubview:ballInstruction];
    _ballBoard = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 94.0f, 286.0f, 330.0f)];
    _ballBoard.backgroundColor = [UIColor colorWithRed:0.88f green:0.96f blue:0.91f alpha:1.0f];
    _ballBoard.layer.cornerRadius = 14.0f;
    [ballPanel addSubview:_ballBoard];
    _ballButton = [[self primaryButtonWithFrame:CGRectMake(111.0f, 130.0f, 64.0f, 64.0f) title:@"TOP"] retain];
    _ballButton.layer.cornerRadius = 32.0f;
    _ballButton.hidden = YES;
    _ballButton.accessibilityLabel = @"Hareket eden top";
    [_ballButton addTarget:self action:@selector(ballTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_ballBoard addSubview:_ballButton];
    _ballStartButton = [[self primaryButtonWithFrame:CGRectMake(24.0f, 435.0f, 130.0f, 54.0f) title:@"Başlat"] retain];
    [_ballStartButton addTarget:self action:@selector(startBallGame) forControlEvents:UIControlEventTouchUpInside];
    [ballPanel addSubview:_ballStartButton];
    _ballStatusLabel = [[self labelWithFrame:CGRectMake(162.0f, 435.0f, 140.0f, 54.0f) text:@"Hazır" fontSize:16.0f bold:YES] retain];
    [ballPanel addSubview:_ballStatusLabel];

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
        UIButton *button = [self primaryButtonWithFrame:CGRectMake(4.0f + (72.0f * column), 12.0f + (181.0f * row), 66.0f, 150.0f) title:@"?"];
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

- (void)startBallGame {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(advanceBallRound) object:nil];
    _ballRound = 0;
    _ballScore = 0;
    _ballGameActive = YES;
    _ballCaughtThisRound = NO;
    _ballButton.hidden = NO;
    _ballButton.alpha = 1.0f;
    _ballButton.transform = CGAffineTransformIdentity;
    _ballStartButton.enabled = NO;
    [_ballStartButton setTitle:@"Oynanıyor" forState:UIControlStateNormal];
    _feedbackLabel.text = @"Topun yeni yerine dikkat et ve hızlıca dokun!";
    [self advanceBallRound];
}

- (void)advanceBallRound {
    if (!_ballGameActive) return;
    if (_ballRound >= 8) {
        _ballGameActive = NO;
        _ballButton.hidden = YES;
        _ballStartButton.enabled = YES;
        [_ballStartButton setTitle:@"Tekrar" forState:UIControlStateNormal];
        _ballStatusLabel.text = [NSString stringWithFormat:@"Skor: %ld/8", (long)_ballScore];
        if (_ballScore >= 5) {
            _feedbackLabel.text = [_gameState awardMiniGameIdentifier:@"catch"];
            [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
        } else {
            _feedbackLabel.text = @"Çok yaklaştın! Ödül için en az 5 top yakala.";
        }
        return;
    }

    CGPoint positions[8] = {
        CGPointMake(43.0f, 45.0f), CGPointMake(143.0f, 73.0f),
        CGPointMake(239.0f, 46.0f), CGPointMake(224.0f, 165.0f),
        CGPointMake(64.0f, 176.0f), CGPointMake(145.0f, 252.0f),
        CGPointMake(242.0f, 286.0f), CGPointMake(48.0f, 286.0f)
    };
    _ballCaughtThisRound = NO;
    _ballButton.alpha = 1.0f;
    _ballButton.transform = CGAffineTransformMakeScale(0.78f, 0.78f);
    CGPoint target = positions[_ballRound];
    _ballRound += 1;
    _ballStatusLabel.text = [NSString stringWithFormat:@"Tur %ld/8 • %ld", (long)_ballRound, (long)_ballScore];
    [UIView beginAnimations:@"catchBallArrive" context:nil];
    [UIView setAnimationDuration:0.20f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _ballButton.center = target;
    _ballButton.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [self performSelector:@selector(advanceBallRound) withObject:nil afterDelay:0.82f];
}

- (void)ballTapped:(UIButton *)sender {
    if (!_ballGameActive || _ballCaughtThisRound) return;
    _ballCaughtThisRound = YES;
    _ballScore += 1;
    _ballStatusLabel.text = [NSString stringWithFormat:@"Tur %ld/8 • %ld", (long)_ballRound, (long)_ballScore];
    [PKSoundManager playEffectNamed:@"ball" enabled:_gameState.soundEnabled];
    [UIView beginAnimations:@"catchBallCaught" context:nil];
    [UIView setAnimationDuration:0.16f];
    sender.alpha = 0.48f;
    sender.transform = CGAffineTransformMakeScale(0.72f, 0.72f);
    [UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _ballGameActive = NO;
    [_gameState save];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_ballGameActive) {
        _ballButton.hidden = YES;
        _ballStartButton.enabled = YES;
        [_ballStartButton setTitle:(_ballRound > 0 ? @"Tekrar" : @"Başlat") forState:UIControlStateNormal];
    }
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
    [_ballBoard release];
    [_ballButton release];
    [_ballStartButton release];
    [_ballStatusLabel release];
    [_feedbackLabel release];
    [super dealloc];
}

@end
