#import "PKTownViewController.h"
#import "PKGameState.h"
#import "PKCatalog.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>

@interface PKTownViewController ()
- (void)refreshUI;
@end

@implementation PKTownViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Kasaba Meydanı";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.91f green:0.86f blue:0.72f alpha:1.0f];
    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 12.0f, 500.0f, 44.0f) text:@"Kasaba Meydanı" fontSize:29.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(620.0f, 12.0f, 374.0f, 44.0f) text:@"" fontSize:18.0f bold:YES] retain];
    [self.view addSubview:_statusLabel];

    UIView *eventPanel = [[[UIView alloc] initWithFrame:CGRectMake(55.0f, 78.0f, 914.0f, 220.0f)] autorelease];
    [PKTheme stylePanel:eventPanel];
    [self.view addSubview:eventPanel];
    UILabel *festival = [self labelWithFrame:CGRectMake(30.0f, 25.0f, 550.0f, 80.0f) text:@"" fontSize:26.0f bold:YES];
    festival.tag = 771;
    festival.textColor = [PKTheme darkTealColor];
    [eventPanel addSubview:festival];
    UILabel *detail = [self labelWithFrame:CGRectMake(45.0f, 112.0f, 520.0f, 70.0f) text:@"Günde bir kez katıl: 25 pati ve bir koleksiyon rozeti kazan." fontSize:18.0f bold:NO];
    [eventPanel addSubview:detail];
    UIButton *eventButton = [self primaryButtonWithFrame:CGRectMake(620.0f, 70.0f, 245.0f, 72.0f) title:@"Etkinliğe Katıl"];
    [eventButton addTarget:self action:@selector(eventTapped:) forControlEvents:UIControlEventTouchUpInside];
    [eventPanel addSubview:eventButton];

    UIView *requestPanel = [[[UIView alloc] initWithFrame:CGRectMake(55.0f, 320.0f, 914.0f, 175.0f)] autorelease];
    [PKTheme stylePanel:requestPanel];
    [self.view addSubview:requestPanel];
    _requestLabel = [[self labelWithFrame:CGRectMake(30.0f, 18.0f, 580.0f, 135.0f) text:@"" fontSize:18.0f bold:YES] retain];
    _requestLabel.textAlignment = UITextAlignmentLeft;
    [requestPanel addSubview:_requestLabel];
    _requestButton = [self secondaryButtonWithFrame:CGRectMake(650.0f, 58.0f, 220.0f, 60.0f) title:@"İsteği Tamamla"];
    [_requestButton addTarget:self action:@selector(requestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [requestPanel addSubview:_requestButton];

    _feedbackLabel = [[self labelWithFrame:CGRectMake(85.0f, 525.0f, 854.0f, 105.0f) text:@"Meydandaki etkinliğe katılabilir veya haritada işaretli günlük isteği yapabilirsin." fontSize:18.0f bold:NO] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    _feedbackLabel.layer.cornerRadius = 15.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];
    [self refreshUI];
}

- (void)refreshUI {
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], [_gameState seasonDisplayName], (long)_gameState.coins];
    UILabel *festival = (UILabel *)[self.view viewWithTag:771];
    festival.text = [NSString stringWithFormat:@"Bugünün Etkinliği\n%@", [_gameState townEventDisplayName]];
    BOOL requestHere = [_gameState isNeighborRequestAtLocation:@"square"];
    _requestButton.hidden = !requestHere;
    _requestButton.enabled = ![_gameState isNeighborRequestCompletedToday];
    [_requestButton setTitle:([_gameState isNeighborRequestCompletedToday] ? @"Tamamlandı ✓" : @"İsteği Tamamla") forState:UIControlStateNormal];
    NSString *location = [[_gameState currentNeighborRequest] objectForKey:@"location"];
    _requestLabel.text = requestHere ? [_gameState neighborRequestText] : [NSString stringWithFormat:@"Bugünkü komşu isteği burada değil.\nHaritada %@ bölgesini bul.", [PKCatalog locationDisplayName:location]];
}

- (void)eventTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState attendTownEvent];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)requestTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState completeNeighborRequestAtLocation:@"square"];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_gameState save];
}

- (void)dealloc {
    [_gameState release];
    [_statusLabel release];
    [_feedbackLabel release];
    [_requestLabel release];
    [super dealloc];
}

@end
