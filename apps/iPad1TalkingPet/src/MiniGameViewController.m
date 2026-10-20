#import "MiniGameViewController.h"
#import "PetProgressManager.h"

@implementation MiniGameViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self = [super init];
    if (self) _progress = [progress retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.90 green:0.96 blue:1.0 alpha:1.0];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(50, 35, 668, 55)] autorelease];
    title.text = @"Pati Yakala";
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:32];
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 105, 260, 45)];
    _scoreLabel.backgroundColor = [UIColor clearColor];
    _scoreLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:_scoreLabel];

    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(448, 105, 260, 45)];
    _timeLabel.textAlignment = UITextAlignmentRight;
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:_timeLabel];

    _targetButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _targetButton.frame = CGRectMake(300, 400, 150, 100);
    [_targetButton setTitle:@"PATİ!" forState:UIControlStateNormal];
    _targetButton.titleLabel.font = [UIFont boldSystemFontOfSize:26];
    [_targetButton addTarget:self action:@selector(hitTarget) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_targetButton];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30, 920, 160, 60);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    _score = 0;
    _secondsLeft = 20;
    [self updateLabels];
    [self moveTarget];
    _timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES] retain];
}

- (void)hitTarget {
    if (_secondsLeft <= 0) return;
    _score += 1;
    [self moveTarget];
    [self updateLabels];
}

- (void)moveTarget {
    CGFloat x = 40 + (arc4random() % 570);
    CGFloat y = 190 + (arc4random() % 620);
    _targetButton.frame = CGRectMake(x, y, 150, 100);
}

- (void)tick {
    _secondsLeft--;
    [self updateLabels];
    if (_secondsLeft <= 0) {
        [_timer invalidate];
        [_progress addCoins:_score * 3];
        [_progress addXP:_score * 2];
        _targetButton.enabled = NO;

        UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Oyun Bitti"
                                                   message:[NSString stringWithFormat:@"%ld puan! %ld coin kazandın.",
                                                            (long)_score, (long)(_score*3)]
                                                  delegate:nil
                                         cancelButtonTitle:@"Tamam"
                                         otherButtonTitles:nil] autorelease];
        [a show];
    }
}

- (void)updateLabels {
    _scoreLabel.text = [NSString stringWithFormat:@"Puan: %ld", (long)_score];
    _timeLabel.text = [NSString stringWithFormat:@"Süre: %ld", (long)_secondsLeft];
}

- (void)goBack {
    [_timer invalidate];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_timer invalidate];
    [_timer release];
    [_targetButton release];
    [_progress release];
    [_scoreLabel release];
    [_timeLabel release];
    [super dealloc];
}
@end
