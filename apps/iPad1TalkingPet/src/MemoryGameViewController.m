#import "MemoryGameViewController.h"
#import "PetProgressManager.h"

@implementation MemoryGameViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self = [super init];
    if (self) _progress = [progress retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.94 blue:0.82 alpha:1];
    _buttons = [[NSMutableArray alloc] init];
    _values = [[NSMutableArray alloc] initWithObjects:@"A",@"A",@"B",@"B",@"C",@"C",@"D",@"D",nil];

    for (NSInteger i=[_values count]-1; i>0; i--) {
        NSInteger j = arc4random() % (i+1);
        [_values exchangeObjectAtIndex:i withObjectAtIndex:j];
    }

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(30,40,708,55)] autorelease];
    title.text = @"Hafıza Kartları";
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:32];
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    for (NSInteger i=0;i<8;i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSInteger row = i / 2;
        NSInteger col = i % 2;
        b.frame = CGRectMake(110 + col*330, 150 + row*165, 220, 125);
        b.tag = i;
        [b setTitle:@"?" forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont boldSystemFontOfSize:36];
        [b addTarget:self action:@selector(flip:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
        [_buttons addObject:b];
    }

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)flip:(UIButton *)b {
    if (_locked || !b.enabled || b == _first) return;
    [b setTitle:[_values objectAtIndex:b.tag] forState:UIControlStateNormal];

    if (!_first) {
        _first = b;
        return;
    }

    NSString *a = [_values objectAtIndex:_first.tag];
    NSString *c = [_values objectAtIndex:b.tag];
    if ([a isEqualToString:c]) {
        _first.enabled = NO;
        b.enabled = NO;
        _first = nil;
        _matches++;
        if (_matches == 4) {
            [_progress addCoins:40];
            [_progress addXP:25];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Tebrikler"
                                                            message:@"40 coin + 25 XP kazandın!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Tamam"
                                                  otherButtonTitles:nil] autorelease];
            [alert show];
        }
    } else {
        _locked = YES;
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:_first,@"a",b,@"b",nil];
        _first = nil;
        [self performSelector:@selector(hidePair:) withObject:info afterDelay:0.65];
    }
}

- (void)hidePair:(NSDictionary *)info {
    UIButton *a = [info objectForKey:@"a"];
    UIButton *b = [info objectForKey:@"b"];
    [a setTitle:@"?" forState:UIControlStateNormal];
    [b setTitle:@"?" forState:UIControlStateNormal];
    _locked = NO;
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_buttons release];
    [_values release];
    [_progress release];
    [super dealloc];
}
@end
