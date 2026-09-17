#import "FoodCatchViewController.h"
#import "PetProgressManager.h"

@implementation FoodCatchViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self = [super init];
    if (self) _progress = [progress retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:1.0 blue:0.88 alpha:1];

    _label = [[UILabel alloc] initWithFrame:CGRectMake(30,35,708,55)];
    _label.textAlignment = UITextAlignmentCenter;
    _label.font = [UIFont boldSystemFontOfSize:26];
    _label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_label];

    _basket = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _basket.frame = CGRectMake(280,850,210,80);
    [_basket setTitle:@"SEPET" forState:UIControlStateNormal];
    [_basket addTarget:self action:@selector(basketDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [self.view addSubview:_basket];

    _food = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _food.frame = CGRectMake(350,120,80,65);
    [_food setTitle:@"YEMEK" forState:UIControlStateNormal];
    [self.view addSubview:_food];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    _timer = [[NSTimer scheduledTimerWithTimeInterval:0.08 target:self selector:@selector(tick) userInfo:nil repeats:YES] retain];
    [self updateLabel];
}

- (void)basketDrag:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *t = [[event allTouches] anyObject];
    CGPoint p = [t locationInView:self.view];
    p.y = sender.center.y;
    if (p.x < 105) p.x = 105;
    if (p.x > 663) p.x = 663;
    sender.center = p;
}

- (void)tick {
    _ticks++;
    CGRect f = _food.frame;
    f.origin.y += 9;
    _food.frame = f;

    if (CGRectIntersectsRect(_food.frame, _basket.frame)) {
        _score++;
        [self resetFood];
    } else if (CGRectGetMinY(_food.frame) > 920) {
        [self resetFood];
    }

    if (_ticks >= 375) {
        [_timer invalidate];
        [_progress addCoins:_score*4];
        [_progress addXP:_score*2];
        UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Yemek Yakala"
                                                    message:[NSString stringWithFormat:@"%ld yakaladın. %ld coin kazandın.",
                                                             (long)_score,(long)(_score*4)]
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
        [a show];
    }
    [self updateLabel];
}

- (void)resetFood {
    CGFloat x = 40 + (arc4random() % 650);
    _food.frame = CGRectMake(x,110,80,65);
}

- (void)updateLabel {
    NSInteger secs = MAX(0, (NSInteger)((375-_ticks)*0.08));
    _label.text = [NSString stringWithFormat:@"Yakaladığın: %ld   Süre: %ld",(long)_score,(long)secs];
}

- (void)goBack {
    [_timer invalidate];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_timer invalidate]; [_timer release];
    [_food release]; [_basket release]; [_label release];
    [_progress release];
    [super dealloc];
}
@end
