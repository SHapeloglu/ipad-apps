#import "FoodViewController.h"
#import "PetNeedsManager.h"
#import "PetProgressManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation FoodViewController

- (id)initWithNeeds:(PetNeedsManager *)needs progress:(PetProgressManager *)progress {
    self = [super init];
    if (self) {
        _needs = [needs retain];
        _progress = [progress retain];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.94 blue:0.86 alpha:1.0];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(40, 30, 688, 55)] autorelease];
    title.text = @"Yemek";
    title.font = [UIFont boldSystemFontOfSize:34];
    title.textAlignment = UITextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    UILabel *cat = [[[UILabel alloc] initWithFrame:CGRectMake(230, 170, 308, 300)] autorelease];
    cat.text = @"PATI";
    cat.font = [UIFont boldSystemFontOfSize:72];
    cat.textAlignment = UITextAlignmentCenter;
    cat.backgroundColor = [UIColor colorWithWhite:1 alpha:0.65];
    cat.layer.cornerRadius = 40;
    [self.view addSubview:cat];

    _mouthTarget = [[UIView alloc] initWithFrame:CGRectMake(335, 365, 100, 70)];
    _mouthTarget.backgroundColor = [UIColor colorWithRed:1 green:0.70 blue:0.70 alpha:0.45];
    _mouthTarget.layer.cornerRadius = 28;
    [self.view addSubview:_mouthTarget];

    UILabel *hint = [[[UILabel alloc] initWithFrame:CGRectMake(120, 500, 528, 55)] autorelease];
    hint.text = @"Yemeği sürükleyip ağız bölgesine bırak.";
    hint.textAlignment = UITextAlignmentCenter;
    hint.backgroundColor = [UIColor clearColor];
    hint.font = [UIFont systemFontOfSize:22];
    [self.view addSubview:hint];

    _foodButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _foodButton.frame = CGRectMake(285, 650, 200, 100);
    [_foodButton setTitle:@"YEMEK" forState:UIControlStateNormal];
    _foodButton.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [_foodButton addTarget:self action:@selector(foodTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [_foodButton addTarget:self action:@selector(foodDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [_foodButton addTarget:self action:@selector(foodDrop:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.view addSubview:_foodButton];
    _foodHome = _foodButton.center;

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 790, 588, 70)];
    _statusLabel.textAlignment = UITextAlignmentCenter;
    _statusLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    _statusLabel.font = [UIFont boldSystemFontOfSize:22];
    [self.view addSubview:_statusLabel];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30, 930, 160, 55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    [self refreshStatus];
}

- (void)foodTouchDown:(UIButton *)sender withEvent:(UIEvent *)event { }

- (void)foodDrag:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    sender.center = [touch locationInView:self.view];
}

- (void)foodDrop:(UIButton *)sender withEvent:(UIEvent *)event {
    if (CGRectIntersectsRect(sender.frame, _mouthTarget.frame)) {
        if ([_progress spendCoins:10]) {
            [_needs feed];
            [_progress addXP:5];
            _statusLabel.text = @"Mmm! Açlık arttı. +5 XP";
        } else {
            _statusLabel.text = @"Yeterli coin yok.";
        }
    } else {
        _statusLabel.text = @"Yemeği ağız bölgesine bırakmalısın.";
    }

    [UIView animateWithDuration:0.25 animations:^{
        sender.center = _foodHome;
    }];
    [self refreshStatus];
}

- (void)refreshStatus {
    _statusLabel.text = [NSString stringWithFormat:@"Açlık: %ld/100   Coin: %ld",
                         (long)_needs.hunger, (long)_progress.coins];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_mouthTarget release];
    [_foodButton release];
    [_statusLabel release];
    [_needs release];
    [_progress release];
    [super dealloc];
}
@end
