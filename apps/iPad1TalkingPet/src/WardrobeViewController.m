#import "WardrobeViewController.h"
#import "PetProgressManager.h"

@implementation WardrobeViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self = [super init];
    if (self) _progress = [progress retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.91 blue:0.95 alpha:1.0];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(30, 35, 708, 50)] autorelease];
    title.text = @"Gardırop";
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:32];
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    _coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(500, 90, 220, 40)];
    _coinLabel.textAlignment = UITextAlignmentCenter;
    _coinLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [self.view addSubview:_coinLabel];

    _selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 170, 568, 80)];
    _selectedLabel.textAlignment = UITextAlignmentCenter;
    _selectedLabel.numberOfLines = 2;
    _selectedLabel.backgroundColor = [UIColor clearColor];
    _selectedLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:_selectedLabel];

    NSArray *names = [NSArray arrayWithObjects:@"Pembe Kalp Tişört", @"Mavi Şapka", @"Yıldız Gözlük", nil];
    NSArray *prices = [NSArray arrayWithObjects:
                       [NSNumber numberWithInt:0],
                       [NSNumber numberWithInt:120],
                       [NSNumber numberWithInt:180], nil];

    for (NSInteger i=0; i<3; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.frame = CGRectMake(115, 300 + i*125, 538, 85);
        b.tag = 100 + i;
        NSString *t = [NSString stringWithFormat:@"%@   -   %ld coin",
                       [names objectAtIndex:i], (long)[[prices objectAtIndex:i] integerValue]];
        [b setTitle:t forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [b addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30, 920, 160, 60);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    [self refresh];
}

- (void)selectItem:(UIButton *)sender {
    NSInteger idx = sender.tag - 100;
    NSInteger cost = (idx == 0) ? 0 : (idx == 1 ? 120 : 180);
    NSString *key = [NSString stringWithFormat:@"wardrobe.owned.%ld", (long)idx];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    BOOL owned = (idx == 0) || [d boolForKey:key];

    if (!owned) {
        if (![_progress spendCoins:cost]) {
            _selectedLabel.text = @"Yeterli coin yok.";
            return;
        }
        [d setBool:YES forKey:key];
    }

    [d setInteger:idx forKey:@"wardrobe.selected"];
    [d synchronize];
    NSArray *names = [NSArray arrayWithObjects:@"Pembe Kalp Tişört", @"Mavi Şapka", @"Yıldız Gözlük", nil];
    _selectedLabel.text = [NSString stringWithFormat:@"Seçildi:\n%@", [names objectAtIndex:idx]];
    [_progress addXP:5];
    [self refresh];
}

- (void)refresh {
    _coinLabel.text = [NSString stringWithFormat:@"Coin: %ld", (long)_progress.coins];
}

- (void)goBack {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_progress release];
    [_coinLabel release];
    [_selectedLabel release];
    [super dealloc];
}
@end
