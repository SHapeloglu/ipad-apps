#import "PKPetSelectionViewController.h"
#import "PKGameState.h"
#import "PKPetCardControl.h"
#import "PKNamingViewController.h"
#import "PKTheme.h"

@implementation PKPetSelectionViewController

- (id)initWithGameState:(PKGameState *)gameState source:(NSString *)source {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _sourceIdentifier = [source copy];
        _cards = [[NSMutableArray alloc] init];
        self.title = @"Yavrunu seç";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *heading = [self labelWithFrame:CGRectMake(100.0f, 20.0f, 824.0f, 52.0f)
                                       text:@"Hangisi senin yeni arkadaşın olsun?"
                                   fontSize:31.0f
                                       bold:YES];
    heading.textColor = [PKTheme darkTealColor];
    [self.view addSubview:heading];

    NSArray *species = [NSArray arrayWithObjects:@"cat", @"dog", @"rabbit", @"panda", nil];
    NSArray *names = [NSArray arrayWithObjects:@"Kedi", @"Köpek", @"Tavşan", @"Panda", nil];
    NSArray *details = [NSArray arrayWithObjects:
                        @"Meraklı ve çevik",
                        @"Sadık ve neşeli",
                        @"Nazik ve hareketli",
                        @"Sakin ve sevecen",
                        nil];

    CGFloat startX = 42.0f;
    CGFloat gap = 20.0f;
    CGFloat cardWidth = 220.0f;
    NSUInteger index = 0;
    for (index = 0; index < [species count]; index++) {
        CGRect frame = CGRectMake(startX + ((cardWidth + gap) * index), 105.0f, cardWidth, 290.0f);
        PKPetCardControl *card = [[PKPetCardControl alloc] initWithFrame:frame
                                                      speciesIdentifier:[species objectAtIndex:index]
                                                                    name:[names objectAtIndex:index]
                                                                  detail:[details objectAtIndex:index]];
        card.tag = (NSInteger)index;
        [card addTarget:self action:@selector(cardTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:card];
        [_cards addObject:card];
        [card release];
    }

    UIView *infoPanel = [[[UIView alloc] initWithFrame:CGRectMake(185.0f, 430.0f, 654.0f, 105.0f)] autorelease];
    [PKTheme stylePanel:infoPanel];
    [self.view addSubview:infoPanel];

    NSString *sourceText = [_sourceIdentifier isEqualToString:@"shop"]
        ? @"Pet shop başlangıcı: 300 pati parası ve bir oyuncak hediyesi."
        : @"Barınak başlangıcı: 500 pati parası ve Yeni Bir Yuva rozeti.";
    UILabel *info = [self labelWithFrame:CGRectMake(25.0f, 18.0f, 604.0f, 68.0f)
                                    text:sourceText
                                fontSize:20.0f
                                    bold:NO];
    [infoPanel addSubview:info];

    _continueButton = [[self primaryButtonWithFrame:CGRectMake(352.0f, 570.0f, 320.0f, 66.0f)
                                                title:@"İsim ve Kişilik Seç"] retain];
    _continueButton.enabled = NO;
    _continueButton.alpha = 0.45f;
    [_continueButton addTarget:self action:@selector(continueTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_continueButton];
}

- (void)cardTapped:(PKPetCardControl *)sender {
    NSUInteger index = 0;
    for (index = 0; index < [_cards count]; index++) {
        PKPetCardControl *card = [_cards objectAtIndex:index];
        card.selected = (card == sender);
    }
    [_selectedSpeciesIdentifier release];
    _selectedSpeciesIdentifier = [sender.speciesIdentifier copy];
    _continueButton.enabled = YES;
    _continueButton.alpha = 1.0f;
}

- (void)continueTapped:(id)sender {
    (void)sender;
    if (!_selectedSpeciesIdentifier) return;
    PKNamingViewController *naming = [[PKNamingViewController alloc] initWithGameState:_gameState
                                                                                source:_sourceIdentifier
                                                                               species:_selectedSpeciesIdentifier];
    [self.navigationController pushViewController:naming animated:YES];
    [naming release];
}

- (void)dealloc {
    [_gameState release];
    [_sourceIdentifier release];
    [_cards release];
    [_selectedSpeciesIdentifier release];
    [_continueButton release];
    [super dealloc];
}

@end
