#import "PKTownMapViewController.h"
#import "PKTownMapView.h"
#import "PKGameState.h"
#import "PKCatalog.h"
#import "PKTownViewController.h"
#import "PKParkViewController.h"
#import "PKSkillsViewController.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>

@interface PKTownMapViewController ()
- (UIButton *)mapButtonWithFrame:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag color:(UIColor *)color;
- (void)refreshUI;
@end

@implementation PKTownMapViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Kasaba Haritası";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView = [[PKTownMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mapView];

    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 12.0f, 430.0f, 44.0f) text:@"Bugün nereye gidelim?" fontSize:28.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(610.0f, 12.0f, 384.0f, 44.0f) text:@"" fontSize:18.0f bold:YES] retain];
    _statusLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.84f];
    _statusLabel.layer.cornerRadius = 14.0f;
    _statusLabel.clipsToBounds = YES;
    [self.view addSubview:_statusLabel];

    UIButton *school = [self mapButtonWithFrame:CGRectMake(85.0f, 95.0f, 255.0f, 128.0f) title:@"Pati Okulu\nDersler ve meslekler" tag:1 color:[UIColor colorWithRed:0.43f green:0.61f blue:0.87f alpha:0.96f]];
    UIButton *park = [self mapButtonWithFrame:CGRectMake(670.0f, 82.0f, 275.0f, 145.0f) title:@"Dostluk Parkı\nKomşularla buluş" tag:2 color:[UIColor colorWithRed:0.31f green:0.67f blue:0.38f alpha:0.96f]];
    UIButton *home = [self mapButtonWithFrame:CGRectMake(75.0f, 370.0f, 235.0f, 135.0f) title:@"Evimiz\nBakım ve oda" tag:0 color:[UIColor colorWithRed:0.86f green:0.52f blue:0.40f alpha:0.96f]];
    UIButton *square = [self mapButtonWithFrame:CGRectMake(415.0f, 365.0f, 285.0f, 145.0f) title:@"Kasaba Meydanı\nGünün etkinliği" tag:3 color:[UIColor colorWithRed:0.66f green:0.43f blue:0.76f alpha:0.96f]];
    _locationButtons = [[NSArray alloc] initWithObjects:home, school, park, square, nil];

    _requestLabel = [[self labelWithFrame:CGRectMake(125.0f, 552.0f, 774.0f, 92.0f) text:@"" fontSize:18.0f bold:YES] retain];
    _requestLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.92f];
    _requestLabel.layer.cornerRadius = 16.0f;
    _requestLabel.clipsToBounds = YES;
    [self.view addSubview:_requestLabel];
    [self refreshUI];
}

- (UIButton *)mapButtonWithFrame:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag color:(UIColor *)color {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = tag;
    button.backgroundColor = color;
    button.layer.cornerRadius = 22.0f;
    button.layer.borderWidth = 4.0f;
    button.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.94f].CGColor;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.18f;
    button.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    button.titleLabel.numberOfLines = 3;
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(locationTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)refreshUI {
    NSDictionary *request = [_gameState currentNeighborRequest];
    NSString *location = [request objectForKey:@"location"];
    _mapView.dayPart = [_gameState dayPartDisplayName];
    _mapView.season = [_gameState seasonDisplayName];
    _mapView.requestLocation = location;
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], [_gameState seasonDisplayName], (long)_gameState.coins];
    NSString *requestState = [_gameState isNeighborRequestCompletedToday] ? @"Tamamlandı ✓" : [request objectForKey:@"title"];
    _requestLabel.text = [NSString stringWithFormat:@"Günün komşu isteği: %@\nHaritada işaretli yer: %@", requestState, [PKCatalog locationDisplayName:location]];
    NSArray *locations = [NSArray arrayWithObjects:@"home", @"school", @"park", @"square", nil];
    NSUInteger index = 0;
    for (index = 0; index < [_locationButtons count]; index++) {
        UIButton *button = [_locationButtons objectAtIndex:index];
        NSArray *titleParts = [[button titleForState:UIControlStateNormal] componentsSeparatedByString:@"\n★ İstek burada!"];
        NSString *baseTitle = [titleParts objectAtIndex:0];
        BOOL marked = [[locations objectAtIndex:index] isEqualToString:location];
        UIColor *borderColor = marked ? [UIColor colorWithRed:1.0f green:0.80f blue:0.18f alpha:1.0f] : [UIColor colorWithWhite:1.0f alpha:0.94f];
        button.layer.borderColor = borderColor.CGColor;
        button.layer.borderWidth = marked ? 7.0f : 4.0f;
        if (marked) [button setTitle:[baseTitle stringByAppendingString:@"\n★ İstek burada!"] forState:UIControlStateNormal];
        else [button setTitle:baseTitle forState:UIControlStateNormal];
    }
}

- (void)locationTapped:(UIButton *)sender {
    UIViewController *controller = nil;
    if (sender.tag == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    if (sender.tag == 1) controller = [[[PKSkillsViewController alloc] initWithGameState:_gameState] autorelease];
    else if (sender.tag == 2) controller = [[[PKParkViewController alloc] initWithGameState:_gameState] autorelease];
    else controller = [[[PKTownViewController alloc] initWithGameState:_gameState] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUI];
}

- (void)dealloc {
    [_gameState release];
    [_mapView release];
    [_statusLabel release];
    [_requestLabel release];
    [_locationButtons release];
    [super dealloc];
}

@end
