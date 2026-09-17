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
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.88 blue:0.93 alpha:1.0];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(30, 28, 708, 55)] autorelease];
    title.text = @"Gardırop";
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:34];
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    _coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(520, 88, 190, 40)];
    _coinLabel.textAlignment = UITextAlignmentCenter;
    _coinLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.72];
    [self.view addSubview:_coinLabel];

    NSArray *sections = [NSArray arrayWithObjects:@"Tişört", @"Pantolon", @"Crop", @"Etek", nil];
    for (NSInteger row = 0; row < 4; row++) {
        UILabel *section = [[[UILabel alloc] initWithFrame:CGRectMake(70, 155 + row * 175, 150, 40)] autorelease];
        section.text = [sections objectAtIndex:row];
        section.font = [UIFont boldSystemFontOfSize:23];
        section.backgroundColor = [UIColor clearColor];
        [self.view addSubview:section];

        for (NSInteger style = 1; style <= 2; style++) {
            UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            b.frame = CGRectMake(240 + (style-1) * 230, 145 + row * 175, 200, 120);
            b.tag = 2000 + row * 10 + style;
            [b setTitle:[NSString stringWithFormat:@"Stil %ld", (long)style] forState:UIControlStateNormal];
            b.titleLabel.font = [UIFont boldSystemFontOfSize:22];
            [b addTarget:self action:@selector(selectStyle:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:b];
        }
    }

    UIButton *remove = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    remove.frame = CGRectMake(260, 860, 250, 55);
    [remove setTitle:@"Alt / Üst Kıyafeti Çıkar" forState:UIControlStateNormal];
    [remove addTarget:self action:@selector(removeClothes) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:remove];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30, 930, 160, 55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    [self refresh];
}

- (void)selectStyle:(UIButton *)sender {
    NSInteger raw = sender.tag - 2000;
    NSInteger category = raw / 10;
    NSInteger style = raw % 10;

    NSInteger cost = 120 + (category * 25) + ((style - 1) * 20);
    NSString *ownedKey = [NSString stringWithFormat:@"wardrobe.v08.owned.%ld.%ld",
                          (long)category, (long)style];

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (![d boolForKey:ownedKey]) {
        if (![_progress spendCoins:cost]) {
            UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Gardırop"
                                                        message:@"Yeterli coin yok."
                                                       delegate:nil
                                              cancelButtonTitle:@"Tamam"
                                              otherButtonTitles:nil] autorelease];
            [a show];
            return;
        }
        [d setBool:YES forKey:ownedKey];
    }

    if (category == 0) {
        [d setInteger:1 forKey:@"outfit.topType"]; // tshirt
        [d setInteger:style forKey:@"outfit.topStyle"];
    } else if (category == 1) {
        [d setInteger:1 forKey:@"outfit.bottomType"]; // pants
        [d setInteger:style forKey:@"outfit.bottomStyle"];
    } else if (category == 2) {
        [d setInteger:2 forKey:@"outfit.topType"]; // crop
        [d setInteger:style forKey:@"outfit.topStyle"];
    } else if (category == 3) {
        [d setInteger:2 forKey:@"outfit.bottomType"]; // skirt
        [d setInteger:style forKey:@"outfit.bottomStyle"];
    }

    [d synchronize];
    [_progress addXP:4];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WardrobeChanged" object:nil];
    [self refresh];
}

- (void)removeClothes {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setInteger:0 forKey:@"outfit.topType"];
    [d setInteger:0 forKey:@"outfit.bottomType"];
    [d synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WardrobeChanged" object:nil];
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
    [super dealloc];
}
@end
