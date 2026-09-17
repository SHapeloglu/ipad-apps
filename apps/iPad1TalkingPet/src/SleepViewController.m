#import "SleepViewController.h"
#import "PetNeedsManager.h"
#import "PetProgressManager.h"

@implementation SleepViewController

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
    _lightsOff = NO;

    _room = [[UIView alloc] initWithFrame:self.view.bounds];
    _room.backgroundColor = [UIColor colorWithRed:0.62 green:0.55 blue:0.78 alpha:1.0];
    [self.view addSubview:_room];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(40,30,688,55)] autorelease];
    title.text = @"Uyku Odası";
    title.textAlignment = UITextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:34];
    title.backgroundColor = [UIColor clearColor];
    [_room addSubview:title];

    UILabel *bed = [[[UILabel alloc] initWithFrame:CGRectMake(170,250,428,300)] autorelease];
    bed.text = @"PATI\nYATAKTA";
    bed.numberOfLines = 2;
    bed.textAlignment = UITextAlignmentCenter;
    bed.font = [UIFont boldSystemFontOfSize:52];
    bed.textColor = [UIColor whiteColor];
    bed.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.25];
    [_room addSubview:bed];

    _lampButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _lampButton.frame = CGRectMake(274,650,220,80);
    [_lampButton setTitle:@"Işığı Kapat" forState:UIControlStateNormal];
    [_lampButton addTarget:self action:@selector(toggleLamp) forControlEvents:UIControlEventTouchUpInside];
    [_room addSubview:_lampButton];

    _status = [[UILabel alloc] initWithFrame:CGRectMake(100,770,568,70)];
    _status.textAlignment = UITextAlignmentCenter;
    _status.textColor = [UIColor whiteColor];
    _status.backgroundColor = [UIColor clearColor];
    _status.font = [UIFont boldSystemFontOfSize:22];
    [_room addSubview:_status];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_room addSubview:back];

    [self refresh];
}

- (void)toggleLamp {
    _lightsOff = !_lightsOff;
    if (_lightsOff) {
        _room.backgroundColor = [UIColor colorWithRed:0.10 green:0.12 blue:0.24 alpha:1.0];
        [_lampButton setTitle:@"Işığı Aç" forState:UIControlStateNormal];
        [_needs sleep];
        [_progress addXP:4];
        _status.text = [NSString stringWithFormat:@"Zzz... Enerji: %ld/100 (+4 XP)", (long)_needs.energy];
    } else {
        _room.backgroundColor = [UIColor colorWithRed:0.62 green:0.55 blue:0.78 alpha:1.0];
        [_lampButton setTitle:@"Işığı Kapat" forState:UIControlStateNormal];
        [self refresh];
    }
}

- (void)refresh {
    _status.text = [NSString stringWithFormat:@"Enerji: %ld/100", (long)_needs.energy];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_room release];
    [_status release];
    [_lampButton release];
    [_needs release];
    [_progress release];
    [super dealloc];
}
@end
