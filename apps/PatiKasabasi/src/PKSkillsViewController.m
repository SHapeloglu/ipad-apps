#import "PKSkillsViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>

@interface PKSkillsViewController ()
- (void)refreshStatus;
@end

@implementation PKSkillsViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Pati Okulu";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 12.0f, 500.0f, 42.0f) text:@"Beceriler, Okul ve Meslekler" fontSize:27.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(590.0f, 12.0f, 400.0f, 42.0f) text:@"" fontSize:18.0f bold:YES] retain];
    [self.view addSubview:_statusLabel];
    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 62.0f, 964.0f, 72.0f) text:@"Her ders 10 pati. Odandaki işlevli eşyalar ilgili derse +1 bonus verir." fontSize:18.0f bold:NO] retain];
    _feedbackLabel.backgroundColor = [PKTheme panelColor];
    _feedbackLabel.layer.cornerRadius = 12.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(30.0f, 145.0f, 964.0f, 515.0f) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 72.0f;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    _requestButton = [[UIBarButtonItem alloc] initWithTitle:@"Günlük İstek" style:UIBarButtonItemStyleBordered target:self action:@selector(requestTapped:)];
    [self refreshStatus];
}

- (void)refreshStatus {
    _statusLabel.text = [NSString stringWithFormat:@"%@ • Büyüme %ld • %ld pati", [_gameState.pet lifeStageDisplayName], (long)_gameState.pet.growthPoints, (long)_gameState.coins];
    if ([_gameState isNeighborRequestAtLocation:@"school"]) {
        self.navigationItem.rightBarButtonItem = _requestButton;
        _requestButton.enabled = ![_gameState isNeighborRequestCompletedToday];
        _requestButton.title = [_gameState isNeighborRequestCompletedToday] ? @"İstek ✓" : @"Okul İsteği";
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { (void)tableView; return 3; }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    (void)tableView;
    if (section == 0) return @"Dersler";
    if (section == 1) return @"Meslekler — yetişkinlik ve ilgili beceri 3 gerekir";
    return @"Bugünün İşi";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    if (section == 0) return (NSInteger)[[PKCatalog skillIdentifiers] count];
    if (section == 1) return (NSInteger)[[PKCatalog careerIdentifiers] count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    UIButton *button = nil;
    if (indexPath.section == 0) {
        NSString *skill = [[PKCatalog skillIdentifiers] objectAtIndex:(NSUInteger)indexPath.row];
        NSInteger level = [_gameState.pet skillLevelForIdentifier:skill];
        cell.textLabel.text = [NSString stringWithFormat:@"%@  •  Seviye %ld/10", [PKCatalog skillDisplayName:skill], (long)level];
        cell.detailTextLabel.text = [_gameState hasFunctionalItemForIdentifier:skill] ? @"Odandaki eşya sayesinde bu ders +2 ilerler" : @"Bu ders +1 ilerler";
        button = [self secondaryButtonWithFrame:CGRectMake(0.0f, 0.0f, 170.0f, 52.0f) title:@"Ders Yap"];
        button.tag = indexPath.row;
        [button addTarget:self action:@selector(skillTapped:) forControlEvents:UIControlEventTouchUpInside];
    } else if (indexPath.section == 1) {
        NSString *career = [[PKCatalog careerIdentifiers] objectAtIndex:(NSUInteger)indexPath.row];
        NSString *skill = [PKCatalog careerSkillIdentifier:career];
        BOOL selected = [_gameState.pet.careerIdentifier isEqualToString:career];
        cell.textLabel.text = [PKCatalog careerDisplayName:career];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ becerisi • sende %ld/10", [PKCatalog skillDisplayName:skill], (long)[_gameState.pet skillLevelForIdentifier:skill]];
        button = [self secondaryButtonWithFrame:CGRectMake(0.0f, 0.0f, 170.0f, 52.0f) title:(selected ? @"Seçili ✓" : @"Meslek Seç")];
        button.tag = 100 + indexPath.row;
        [button addTarget:self action:@selector(careerTapped:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Meslek: %@", [PKCatalog careerDisplayName:_gameState.pet.careerIdentifier]];
        cell.detailTextLabel.text = @"Günde bir kez çalış; 45 pati parası kazan";
        button = [self primaryButtonWithFrame:CGRectMake(0.0f, 0.0f, 170.0f, 52.0f) title:@"Çalış"];
        [button addTarget:self action:@selector(workTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.accessoryView = button;
    return cell;
}

- (void)skillTapped:(UIButton *)sender {
    NSString *skill = [[PKCatalog skillIdentifiers] objectAtIndex:(NSUInteger)sender.tag];
    _feedbackLabel.text = [_gameState trainSkillIdentifier:skill];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshStatus];
    [_tableView reloadData];
}

- (void)careerTapped:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    NSString *career = [[PKCatalog careerIdentifiers] objectAtIndex:(NSUInteger)index];
    _feedbackLabel.text = [_gameState chooseCareerIdentifier:career];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshStatus];
    [_tableView reloadData];
}

- (void)workTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState workCareer];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshStatus];
    [_tableView reloadData];
}

- (void)requestTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState completeNeighborRequestAtLocation:@"school"];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshStatus];
    [_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshStatus];
    if ([_gameState isNeighborRequestAtLocation:@"school"]) _feedbackLabel.text = [_gameState neighborRequestText];
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
    [_requestButton release];
    [super dealloc];
}

@end
