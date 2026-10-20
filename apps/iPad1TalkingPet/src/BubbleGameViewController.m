#import "BubbleGameViewController.h"
#import "PetProgressManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation BubbleGameViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self = [super init];
    if (self) _progress = [progress retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.85 green:0.96 blue:1 alpha:1];

    _score = 0;
    _secondsLeft = 20;

    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(40,40,300,50)];
    _scoreLabel.backgroundColor = [UIColor clearColor];
    _scoreLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:_scoreLabel];

    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(430,40,298,50)];
    _timeLabel.textAlignment = UITextAlignmentRight;
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:_timeLabel];

    for (NSInteger i=0; i<12; i++) [self spawnBubble];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    [self updateLabels];
    _timer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES] retain];
}

- (void)spawnBubble {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat size = 54 + (arc4random() % 35);
    CGFloat x = 20 + (arc4random() % 650);
    CGFloat y = 110 + (arc4random() % 730);
    b.frame = CGRectMake(x,y,size,size);
    b.backgroundColor = [UIColor colorWithRed:0.55 green:0.82 blue:1 alpha:0.70];
    b.layer.cornerRadius = size/2.0;
    [b addTarget:self action:@selector(popBubble:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
}

- (void)popBubble:(UIButton *)b {
    if (_secondsLeft <= 0) return;
    _score++;
    [b removeFromSuperview];
    [self spawnBubble];
    [self updateLabels];
}

- (void)tick {
    _secondsLeft--;
    [self updateLabels];
    if (_secondsLeft <= 0) {
        [_timer invalidate];
        [_progress addCoins:_score * 2];
        [_progress addXP:_score];
        UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Baloncuk Patlat"
                                                    message:[NSString stringWithFormat:@"%ld baloncuk! %ld coin.",
                                                             (long)_score,(long)(_score*2)]
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
        [a show];
    }
}

- (void)updateLabels {
    _scoreLabel.text = [NSString stringWithFormat:@"Puan: %ld",(long)_score];
    _timeLabel.text = [NSString stringWithFormat:@"Süre: %ld",(long)_secondsLeft];
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
    [_scoreLabel release];
    [_timeLabel release];
    [_progress release];
    [super dealloc];
}
@end
