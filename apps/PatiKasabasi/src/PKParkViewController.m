#import "PKParkViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKPetAvatarView.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>

@interface PKParkViewController ()
- (void)refreshUI;
@end

@implementation PKParkViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Dostluk Parkı";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.82f green:0.92f blue:0.75f alpha:1.0f];
    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 10.0f, 500.0f, 44.0f) text:@"Dostluk Parkı" fontSize:29.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(620.0f, 10.0f, 374.0f, 44.0f) text:@"" fontSize:18.0f bold:YES] retain];
    [self.view addSubview:_statusLabel];

    UIView *requestPanel = [[[UIView alloc] initWithFrame:CGRectMake(30.0f, 62.0f, 964.0f, 118.0f)] autorelease];
    [PKTheme stylePanel:requestPanel];
    [self.view addSubview:requestPanel];
    _requestLabel = [[self labelWithFrame:CGRectMake(22.0f, 10.0f, 675.0f, 98.0f) text:@"" fontSize:17.0f bold:YES] retain];
    _requestLabel.textAlignment = UITextAlignmentLeft;
    [requestPanel addSubview:_requestLabel];
    _requestButton = [self secondaryButtonWithFrame:CGRectMake(728.0f, 30.0f, 208.0f, 58.0f) title:@"İsteği Tamamla"];
    [_requestButton addTarget:self action:@selector(requestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [requestPanel addSubview:_requestButton];

    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 191.0f, 964.0f, 64.0f) text:@"Bir komşuyu ziyaret etmek arkadaşlığı ve sevdiği beceriyi geliştirir." fontSize:17.0f bold:NO] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    _feedbackLabel.layer.cornerRadius = 13.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(30.0f, 267.0f, 964.0f, 393.0f) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 96.0f;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [self refreshUI];
}

- (void)refreshUI {
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], (long)_gameState.coins];
    BOOL requestHere = [_gameState isNeighborRequestAtLocation:@"park"];
    _requestButton.hidden = !requestHere;
    _requestButton.enabled = ![_gameState isNeighborRequestCompletedToday];
    [_requestButton setTitle:([_gameState isNeighborRequestCompletedToday] ? @"Tamamlandı ✓" : @"İsteği Tamamla") forState:UIControlStateNormal];
    NSString *location = [[_gameState currentNeighborRequest] objectForKey:@"location"];
    _requestLabel.text = requestHere ? [_gameState neighborRequestText] : [NSString stringWithFormat:@"Bugünkü istek %@ bölgesinde.\nDilersen burada komşularını ziyaret edebilirsin.", [PKCatalog locationDisplayName:location]];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { (void)tableView; (void)section; return (NSInteger)[[PKCatalog neighbors] count]; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    NSDictionary *neighbor = [[PKCatalog neighbors] objectAtIndex:(NSUInteger)indexPath.row];
    PKPetAvatarView *avatar = [[[PKPetAvatarView alloc] initWithFrame:CGRectMake(8.0f, 5.0f, 86.0f, 84.0f) speciesIdentifier:[neighbor objectForKey:@"species"]] autorelease];
    [cell.contentView addSubview:avatar];
    UILabel *name = [self labelWithFrame:CGRectMake(108.0f, 8.0f, 210.0f, 34.0f) text:[neighbor objectForKey:@"name"] fontSize:21.0f bold:YES];
    name.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:name];
    NSInteger friendship = [_gameState.pet friendshipForNeighborIdentifier:[neighbor objectForKey:@"id"]];
    UILabel *detail = [self labelWithFrame:CGRectMake(108.0f, 40.0f, 585.0f, 45.0f) text:[NSString stringWithFormat:@"%@ • %@ • Arkadaşlık %ld/100", [neighbor objectForKey:@"detail"], [PKCatalog skillDisplayName:[neighbor objectForKey:@"skill"]], (long)friendship] fontSize:15.0f bold:NO];
    detail.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:detail];
    UIButton *button = [self secondaryButtonWithFrame:CGRectMake(0.0f, 0.0f, 180.0f, 54.0f) title:@"Ziyaret Et"];
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(neighborTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    return cell;
}

- (void)neighborTapped:(UIButton *)sender {
    NSDictionary *neighbor = [[PKCatalog neighbors] objectAtIndex:(NSUInteger)sender.tag];
    _feedbackLabel.text = [_gameState visitNeighborIdentifier:[neighbor objectForKey:@"id"]];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)requestTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState completeNeighborRequestAtLocation:@"park"];
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
    [_tableView release];
    [_statusLabel release];
    [_feedbackLabel release];
    [_requestLabel release];
    [super dealloc];
}

@end
