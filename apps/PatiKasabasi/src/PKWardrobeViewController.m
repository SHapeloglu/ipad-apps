#import "PKWardrobeViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKPetAvatarView.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKWardrobeViewController ()
- (void)refreshUI;
- (NSString *)identifierForIndexPath:(NSIndexPath *)indexPath;
- (void)startAvatarIdleAnimation;
- (void)stopAvatarIdleAnimation;
@end

@implementation PKWardrobeViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Pati Dolabı";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 10.0f, 540.0f, 42.0f) text:@"Kıyafet ve Aksesuar Dolabı" fontSize:27.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(660.0f, 10.0f, 330.0f, 42.0f) text:@"" fontSize:19.0f bold:YES] retain];
    [self.view addSubview:_statusLabel];

    UIView *previewPanel = [[[UIView alloc] initWithFrame:CGRectMake(30.0f, 62.0f, 330.0f, 586.0f)] autorelease];
    [PKTheme stylePanel:previewPanel];
    [self.view addSubview:previewPanel];
    UILabel *previewTitle = [self labelWithFrame:CGRectMake(15.0f, 15.0f, 300.0f, 38.0f) text:_gameState.pet.name fontSize:25.0f bold:YES];
    previewTitle.textColor = [PKTheme darkTealColor];
    [previewPanel addSubview:previewTitle];
    _avatarView = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(35.0f, 65.0f, 260.0f, 350.0f) speciesIdentifier:_gameState.pet.speciesIdentifier];
    _avatarView.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    [previewPanel addSubview:_avatarView];
    UILabel *hint = [self labelWithFrame:CGRectMake(25.0f, 425.0f, 280.0f, 55.0f) text:@"Her bölümden bir parça takabilirsin." fontSize:17.0f bold:YES];
    [previewPanel addSubview:hint];
    _feedbackLabel = [[self labelWithFrame:CGRectMake(20.0f, 486.0f, 290.0f, 80.0f) text:@"Bir parçayı seç; satın al, giy veya çıkar." fontSize:16.0f bold:NO] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithRed:0.91f green:0.97f blue:0.94f alpha:1.0f];
    _feedbackLabel.layer.cornerRadius = 12.0f;
    _feedbackLabel.clipsToBounds = YES;
    [previewPanel addSubview:_feedbackLabel];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(390.0f, 62.0f, 604.0f, 586.0f) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 82.0f;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [self refreshUI];
}

- (NSString *)identifierForIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = (indexPath.section * 2) + indexPath.row;
    NSArray *identifiers = [PKCatalog accessoryIdentifiers];
    if (index < 0 || index >= (NSInteger)[identifiers count]) return nil;
    return [identifiers objectAtIndex:(NSUInteger)index];
}

- (void)refreshUI {
    _statusLabel.text = [NSString stringWithFormat:@"%ld pati • %lu/8 parça", (long)_gameState.coins, (unsigned long)[_gameState.ownedAccessoryIdentifiers count]];
    _avatarView.equippedAccessories = _gameState.equippedAccessories;
    _avatarView.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { (void)tableView; return (NSInteger)[[PKCatalog accessorySlots] count]; }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    (void)tableView;
    NSString *slot = [[PKCatalog accessorySlots] objectAtIndex:(NSUInteger)section];
    return [PKCatalog accessorySlotDisplayName:slot];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { (void)tableView; (void)section; return 2; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    NSString *identifier = [self identifierForIndexPath:indexPath];
    NSDictionary *accessory = [PKCatalog accessoryForIdentifier:identifier];
    BOOL owned = [_gameState ownsAccessoryIdentifier:identifier];
    BOOL equipped = [_gameState isAccessoryEquipped:identifier];
    NSInteger price = [[accessory objectForKey:@"price"] integerValue];
    cell.textLabel.text = [accessory objectForKey:@"name"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ • %@", (price == 0 ? @"Hediye" : [NSString stringWithFormat:@"%ld pati", (long)price]), [accessory objectForKey:@"detail"]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0f];
    NSString *buttonTitle = owned ? (equipped ? @"Çıkar" : @"Giy") : @"Satın Al";
    UIButton *button = [self secondaryButtonWithFrame:CGRectMake(0.0f, 0.0f, 145.0f, 52.0f) title:buttonTitle];
    button.tag = (indexPath.section * 100) + indexPath.row;
    [button addTarget:self action:@selector(accessoryTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    return cell;
}

- (void)accessoryTapped:(UIButton *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(sender.tag % 100) inSection:(sender.tag / 100)];
    NSString *identifier = [self identifierForIndexPath:indexPath];
    _feedbackLabel.text = [_gameState ownsAccessoryIdentifier:identifier] ? [_gameState toggleAccessoryIdentifier:identifier] : [_gameState buyAccessoryIdentifier:identifier];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)startAvatarIdleAnimation {
    [self stopAvatarIdleAnimation];
    [UIView beginAnimations:@"wardrobePetIdle" context:nil];
    [UIView setAnimationDuration:1.65f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    _avatarView.transform = CGAffineTransformMakeTranslation(0.0f, -5.0f);
    [UIView commitAnimations];
}

- (void)stopAvatarIdleAnimation {
    [_avatarView.layer removeAllAnimations];
    _avatarView.transform = CGAffineTransformIdentity;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUI];
    [self startAvatarIdleAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAvatarIdleAnimation];
    [_gameState save];
}

- (void)dealloc {
    [_gameState release];
    [_avatarView release];
    [_tableView release];
    [_statusLabel release];
    [_feedbackLabel release];
    [super dealloc];
}

@end
