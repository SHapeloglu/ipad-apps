#import "HomeViewController.h"
#import "TerminalViewController.h"

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"iPad1Terminal";
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *localButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    localButton.frame = CGRectMake(184.0f, 180.0f, 400.0f, 60.0f);
    [localButton setTitle:@"Local Terminal" forState:UIControlStateNormal];
    localButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [localButton addTarget:self
                    action:@selector(openLocalTerminal:)
          forControlEvents:UIControlEventTouchUpInside];
    localButton.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:localButton];

    UILabel *subtitle = [[[UILabel alloc] initWithFrame:CGRectMake(100.0f, 255.0f, 568.0f, 40.0f)] autorelease];
    subtitle.text = @"Local shell first. SSH will be added after PTY validation.";
    subtitle.textAlignment = UITextAlignmentCenter;
    subtitle.textColor = [UIColor darkGrayColor];
    subtitle.backgroundColor = [UIColor clearColor];
    subtitle.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:subtitle];
}

- (void)openLocalTerminal:(id)sender
{
    (void)sender;
    TerminalViewController *controller =
        [[[TerminalViewController alloc] initWithLocalShell] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation) ||
           UIInterfaceOrientationIsLandscape(orientation);
}

@end
