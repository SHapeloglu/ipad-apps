#import "HomeViewController.h"
#import "PetNeedsManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    _needs = [[PetNeedsManager alloc] init];

    UIImage *bg = [UIImage imageNamed:@"home_bg.jpg"];
    _backgroundView = [[UIImageView alloc] initWithImage:bg];
    _backgroundView.frame = self.view.bounds;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.userInteractionEnabled = YES;
    [self.view addSubview:_backgroundView];

    [self buildStatusOverlay];
    [self buildTouchZones];
    [self refreshUI];

    _baseScale = 1.0f;
    _idleTimer = [[NSTimer scheduledTimerWithTimeInterval:3.2
                                                  target:self
                                                selector:@selector(runIdlePulse)
                                                userInfo:nil
                                                 repeats:YES] retain];
}

- (void)buildStatusOverlay {
    _hungerBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _happinessBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _hygieneBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _energyBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

    NSArray *bars = [NSArray arrayWithObjects:_hungerBar, _happinessBar, _hygieneBar, _energyBar, nil];
    CGFloat x = 96.0f;
    for (NSInteger i = 0; i < [bars count]; i++) {
        UIProgressView *bar = [bars objectAtIndex:i];
        bar.frame = CGRectMake(x + (i * 155.0f), 50.0f, 105.0f, 10.0f);
        [_backgroundView addSubview:bar];
    }

    _coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 118, 145, 38)];
    _coinLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.78];
    _coinLabel.textColor = [UIColor brownColor];
    _coinLabel.textAlignment = UITextAlignmentCenter;
    _coinLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    _coinLabel.layer.cornerRadius = 12.0f;
    [_backgroundView addSubview:_coinLabel];
}

- (UIButton *)invisibleButtonWithFrame:(CGRect)frame tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = tag;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:button];
    return button;
}

- (void)buildTouchZones {
    // Bottom menu hit zones aligned to the approved mockup.
    [self invisibleButtonWithFrame:CGRectMake(25, 830, 125, 180) tag:1];  // Food
    [self invisibleButtonWithFrame:CGRectMake(165, 830, 125, 180) tag:2]; // Bath
    [self invisibleButtonWithFrame:CGRectMake(305, 830, 125, 180) tag:3]; // Sleep
    [self invisibleButtonWithFrame:CGRectMake(445, 830, 125, 180) tag:4]; // Play
    [self invisibleButtonWithFrame:CGRectMake(585, 830, 150, 180) tag:5]; // Wardrobe

    // Character touch zone.
    [self invisibleButtonWithFrame:CGRectMake(225, 190, 330, 610) tag:20];
}

- (void)actionTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            [_needs feed];
            [self showMessage:@"Mmm! Çok lezzetli!"];
            break;
        case 2:
            [_needs bathe];
            [self showMessage:@"Mis gibi oldum!"];
            break;
        case 3:
            [_needs sleep];
            [self showMessage:@"Biraz dinlenelim..."];
            break;
        case 4:
            [_needs play];
            [self showMessage:@"Hadi oynayalım!"];
            break;
        case 5:
            [self showMessage:@"Gardırop v0.2'de açılacak."];
            break;
        case 20:
            [self petReaction];
            break;
        default:
            break;
    }

    [self refreshUI];
}

- (void)refreshUI {
    _hungerBar.progress = ((float)_needs.hunger) / 100.0f;
    _happinessBar.progress = ((float)_needs.happiness) / 100.0f;
    _hygieneBar.progress = ((float)_needs.hygiene) / 100.0f;
    _energyBar.progress = ((float)_needs.energy) / 100.0f;
    _coinLabel.text = [NSString stringWithFormat:@"🪙 %ld", (long)_needs.coins];
}

- (void)showMessage:(NSString *)message {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Pati"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)petReaction {
    [UIView animateWithDuration:0.12
                     animations:^{
                         _backgroundView.transform = CGAffineTransformMakeScale(1.012f, 1.012f);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.12
                                          animations:^{
                                              _backgroundView.transform = CGAffineTransformIdentity;
                                          }];
                     }];
}

- (void)runIdlePulse {
    [UIView animateWithDuration:0.35
                     animations:^{
                         _backgroundView.alpha = 0.985f;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.35
                                          animations:^{
                                              _backgroundView.alpha = 1.0f;
                                          }];
                     }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_idleTimer invalidate];
    [_idleTimer release];

    [_coinLabel release];
    [_hungerBar release];
    [_happinessBar release];
    [_hygieneBar release];
    [_energyBar release];

    [_needs release];
    [_backgroundView release];
    [super dealloc];
}

@end
