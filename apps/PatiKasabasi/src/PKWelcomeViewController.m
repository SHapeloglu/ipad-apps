#import "PKWelcomeViewController.h"
#import "PKGameState.h"
#import "PKSourceViewController.h"
#import "PKAppDelegate.h"
#import "PKPetAvatarView.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation PKWelcomeViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Pati Kasabası";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    _continueButton.hidden = ![_gameState hasSavedGame];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.83f green:0.94f blue:0.89f alpha:1.0f];

    UIView *sun = [[[UIView alloc] initWithFrame:CGRectMake(770.0f, -90.0f, 280.0f, 280.0f)] autorelease];
    sun.backgroundColor = [UIColor colorWithRed:1.0f green:0.84f blue:0.35f alpha:0.72f];
    sun.layer.cornerRadius = 140.0f;
    [self.view addSubview:sun];

    PKPetAvatarView *cat = [[[PKPetAvatarView alloc] initWithFrame:CGRectMake(80.0f, 250.0f, 255.0f, 325.0f)
                                                   speciesIdentifier:@"cat"] autorelease];
    [self.view addSubview:cat];

    UIView *panel = [[[UIView alloc] initWithFrame:CGRectMake(365.0f, 90.0f, 550.0f, 500.0f)] autorelease];
    [PKTheme stylePanel:panel];
    [self.view addSubview:panel];

    UILabel *title = [self labelWithFrame:CGRectMake(25.0f, 35.0f, 500.0f, 74.0f)
                                     text:@"Pati Kasabası"
                                 fontSize:46.0f
                                     bold:YES];
    title.textColor = [PKTheme darkTealColor];
    [panel addSubview:title];

    UILabel *tagline = [self labelWithFrame:CGRectMake(45.0f, 115.0f, 460.0f, 72.0f)
                                       text:@"Bir yavruya yuva ver, onunla büyü ve kendi hikâyeni oluştur."
                                   fontSize:22.0f
                                       bold:NO];
    [panel addSubview:tagline];

    UIButton *newButton = [self primaryButtonWithFrame:CGRectMake(110.0f, 230.0f, 330.0f, 70.0f)
                                                  title:@"Yeni Oyun"];
    [newButton addTarget:self action:@selector(newGameTapped:) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:newButton];

    _continueButton = [[self secondaryButtonWithFrame:CGRectMake(110.0f, 320.0f, 330.0f, 70.0f)
                                                   title:@"Devam Et"] retain];
    [_continueButton addTarget:self action:@selector(continueTapped:) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:_continueButton];

    UILabel *safe = [self labelWithFrame:CGRectMake(30.0f, 428.0f, 490.0f, 38.0f)
                                    text:@"Çevrimdışı • Reklamsız • Gerçek para yok"
                                fontSize:16.0f
                                    bold:YES];
    safe.textColor = [PKTheme darkTealColor];
    [panel addSubview:safe];

    UILabel *version = [self labelWithFrame:CGRectMake(790.0f, 670.0f, 210.0f, 25.0f)
                                       text:@"0.4.0-alpha4"
                                   fontSize:13.0f
                                       bold:NO];
    version.textAlignment = UITextAlignmentRight;
    [self.view addSubview:version];
}

- (void)beginNewGameFlow {
    PKSourceViewController *source = [[PKSourceViewController alloc] initWithGameState:_gameState];
    [self.navigationController pushViewController:source animated:YES];
    [source release];
}

- (void)newGameTapped:(id)sender {
    (void)sender;
    if ([_gameState hasSavedGame]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Yeni oyun"
                                                       message:@"Mevcut oyun, yeni yavru eve geldiğinde değiştirilecek. Devam edelim mi?"
                                                      delegate:self
                                             cancelButtonTitle:@"Vazgeç"
                                             otherButtonTitles:@"Devam Et", nil];
        [alert show];
        [alert release];
    } else {
        [self beginNewGameFlow];
    }
}

- (void)continueTapped:(id)sender {
    (void)sender;
    if (!_gameState.pet && ![_gameState load]) return;
    PKAppDelegate *delegate = (PKAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showHome];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    (void)alertView;
    if (buttonIndex == 1) [self beginNewGameFlow];
}

- (void)dealloc {
    [_gameState release];
    [_continueButton release];
    [super dealloc];
}

@end
