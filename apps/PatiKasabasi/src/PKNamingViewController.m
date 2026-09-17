#import "PKNamingViewController.h"
#import "PKGameState.h"
#import "PKPetAvatarView.h"
#import "PKAppDelegate.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation PKNamingViewController

- (id)initWithGameState:(PKGameState *)gameState
                  source:(NSString *)source
                 species:(NSString *)species {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _sourceIdentifier = [source copy];
        _speciesIdentifier = [species copy];
        self.title = @"Tanışma zamanı";
    }
    return self;
}

- (NSString *)speciesName {
    if ([_speciesIdentifier isEqualToString:@"dog"]) return @"köpeğin";
    if ([_speciesIdentifier isEqualToString:@"rabbit"]) return @"tavşanın";
    if ([_speciesIdentifier isEqualToString:@"panda"]) return @"pandanın";
    return @"kedinin";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *leftPanel = [[[UIView alloc] initWithFrame:CGRectMake(80.0f, 65.0f, 330.0f, 520.0f)] autorelease];
    [PKTheme stylePanel:leftPanel];
    [self.view addSubview:leftPanel];

    _avatarView = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(35.0f, 50.0f, 260.0f, 330.0f)
                                        speciesIdentifier:_speciesIdentifier];
    [leftPanel addSubview:_avatarView];

    UILabel *arrival = [self labelWithFrame:CGRectMake(25.0f, 395.0f, 280.0f, 85.0f)
                                       text:[NSString stringWithFormat:@"Yeni %@ seninle tanışmak için çok heyecanlı!", [self speciesName]]
                                   fontSize:20.0f
                                       bold:YES];
    arrival.textColor = [PKTheme darkTealColor];
    [leftPanel addSubview:arrival];

    UIView *rightPanel = [[[UIView alloc] initWithFrame:CGRectMake(455.0f, 65.0f, 490.0f, 520.0f)] autorelease];
    [PKTheme stylePanel:rightPanel];
    [self.view addSubview:rightPanel];

    UILabel *nameTitle = [self labelWithFrame:CGRectMake(35.0f, 30.0f, 420.0f, 45.0f)
                                         text:@"Adı ne olsun?"
                                     fontSize:28.0f
                                         bold:YES];
    nameTitle.textColor = [PKTheme darkTealColor];
    [rightPanel addSubview:nameTitle];

    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(70.0f, 90.0f, 350.0f, 58.0f)];
    _nameField.backgroundColor = [UIColor whiteColor];
    _nameField.borderStyle = UITextBorderStyleRoundedRect;
    _nameField.font = [UIFont boldSystemFontOfSize:25.0f];
    _nameField.textAlignment = UITextAlignmentCenter;
    _nameField.placeholder = @"Yavrunun adı";
    _nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _nameField.returnKeyType = UIReturnKeyDone;
    _nameField.delegate = self;
    [rightPanel addSubview:_nameField];

    UILabel *personalityTitle = [self labelWithFrame:CGRectMake(30.0f, 180.0f, 430.0f, 42.0f)
                                                text:@"İlk kişilik özelliği"
                                            fontSize:24.0f
                                                bold:YES];
    [rightPanel addSubview:personalityTitle];

    _personalityControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                     @"Oyuncu", @"Meraklı", @"Uykucu", @"Sosyal", @"Müzik", nil]];
    _personalityControl.frame = CGRectMake(25.0f, 235.0f, 440.0f, 48.0f);
    _personalityControl.selectedSegmentIndex = 0;
    [_personalityControl addTarget:self action:@selector(personalityChanged:) forControlEvents:UIControlEventValueChanged];
    [rightPanel addSubview:_personalityControl];

    _personalityDescriptionLabel = [[self labelWithFrame:CGRectMake(40.0f, 300.0f, 410.0f, 70.0f)
                                                              text:@"Oyun oynadığında daha fazla eğlenir."
                                                          fontSize:18.0f
                                                              bold:NO] retain];
    [rightPanel addSubview:_personalityDescriptionLabel];

    UIButton *homeButton = [self primaryButtonWithFrame:CGRectMake(105.0f, 405.0f, 280.0f, 66.0f)
                                                   title:@"Yeni Evine Götür"];
    [homeButton addTarget:self action:@selector(homeTapped:) forControlEvents:UIControlEventTouchUpInside];
    [rightPanel addSubview:homeButton];
}

- (NSArray *)personalityIdentifiers {
    return [NSArray arrayWithObjects:@"playful", @"curious", @"sleepy", @"social", @"musical", nil];
}

- (void)personalityChanged:(UISegmentedControl *)sender {
    NSArray *descriptions = [NSArray arrayWithObjects:
                             @"Oyun oynadığında daha fazla eğlenir.",
                             @"Yeni yerleri keşfetmeye bayılır.",
                             @"Uyuduğunda enerjisini daha hızlı toplar.",
                             @"Sevgi ve sosyallik ihtiyacı daha hızlı dolar.",
                             @"Müzik becerisine küçük bir avantajla başlar.",
                             nil];
    NSInteger index = sender.selectedSegmentIndex;
    if (index >= 0 && index < (NSInteger)[descriptions count]) {
        _personalityDescriptionLabel.text = [descriptions objectAtIndex:(NSUInteger)index];
    }
}

- (void)homeTapped:(id)sender {
    (void)sender;
    NSString *trimmed = [_nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bir isim gerekli"
                                                       message:@"Yavrunun adını yazdıktan sonra yeni evine götürebilirsin."
                                                      delegate:nil
                                             cancelButtonTitle:@"Tamam"
                                             otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    if ([trimmed length] > 18) trimmed = [trimmed substringToIndex:18];

    NSInteger selectedIndex = _personalityControl.selectedSegmentIndex;
    if (selectedIndex < 0) selectedIndex = 0;
    NSString *personality = [[self personalityIdentifiers] objectAtIndex:(NSUInteger)selectedIndex];
    [_gameState beginWithSource:_sourceIdentifier
                       species:_speciesIdentifier
                          name:trimmed
                   personality:personality];

    [_nameField resignFirstResponder];
    PKAppDelegate *delegate = (PKAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showHome];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    _nameField.delegate = nil;
    [_gameState release];
    [_sourceIdentifier release];
    [_speciesIdentifier release];
    [_nameField release];
    [_personalityControl release];
    [_personalityDescriptionLabel release];
    [_avatarView release];
    [super dealloc];
}

@end
