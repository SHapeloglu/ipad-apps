#import "PKDecorViewController.h"
#import "PKGameState.h"
#import "PKCatalog.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>

@interface PKDecorViewController ()
- (void)refreshStatus;
@end

@implementation PKDecorViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Odamı Düzenle";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 15.0f, 540.0f, 45.0f) text:@"Eşyaları al, en fazla 6 tanesini odana yerleştir" fontSize:24.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(700.0f, 15.0f, 290.0f, 45.0f) text:@"" fontSize:20.0f bold:YES] retain];
    [self.view addSubview:_statusLabel];
    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 60.0f, 960.0f, 55.0f) text:@"Eşyalar yalnızca süs değil; bazıları bakım ve derslere bonus verir." fontSize:18.0f bold:NO] retain];
    _feedbackLabel.backgroundColor = [PKTheme panelColor];
    _feedbackLabel.layer.cornerRadius = 12.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(30.0f, 125.0f, 964.0f, 535.0f) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 78.0f;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [self refreshStatus];
}

- (void)refreshStatus {
    _statusLabel.text = [NSString stringWithFormat:@"%ld pati • Odada %lu/6", (long)_gameState.coins, (unsigned long)[_gameState.placedItemIdentifiers count]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView; (void)section;
    return (NSInteger)[[PKCatalog itemIdentifiers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    NSString *identifier = [[PKCatalog itemIdentifiers] objectAtIndex:(NSUInteger)indexPath.row];
    NSDictionary *item = [PKCatalog itemForIdentifier:identifier];
    BOOL owned = [_gameState ownsItemIdentifier:identifier];
    BOOL placed = [_gameState isItemPlaced:identifier];
    cell.textLabel.text = [item objectForKey:@"name"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:21.0f];
    NSString *price = [[item objectForKey:@"price"] integerValue] == 0 ? @"Başlangıç eşyası" : [NSString stringWithFormat:@"%ld pati", (long)[[item objectForKey:@"price"] integerValue]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ • %@", price, [item objectForKey:@"effect"]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
    UIButton *button = [self secondaryButtonWithFrame:CGRectMake(0.0f, 0.0f, 190.0f, 54.0f) title:(owned ? (placed ? @"Envantere Kaldır" : @"Odaya Yerleştir") : @"Satın Al")];
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    return cell;
}

- (void)itemTapped:(UIButton *)sender {
    NSString *identifier = [[PKCatalog itemIdentifiers] objectAtIndex:(NSUInteger)sender.tag];
    NSString *message = [_gameState ownsItemIdentifier:identifier] ? [_gameState togglePlacementOfItemIdentifier:identifier] : [_gameState buyItemIdentifier:identifier];
    _feedbackLabel.text = message;
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshStatus];
    [_tableView reloadData];
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
    [super dealloc];
}

@end
