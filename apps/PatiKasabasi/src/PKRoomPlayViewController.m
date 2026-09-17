#import "PKRoomPlayViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKRoomBackgroundView.h"
#import "PKPetAvatarView.h"
#import "PKDecorViewController.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>

@interface PKRoomPlayViewController ()
- (void)refreshUI;
- (void)showReaction:(NSString *)identifier;
- (void)resetReaction;
@end

@implementation PKRoomPlayViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Odam";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _roomView = [[PKRoomBackgroundView alloc] initWithFrame:self.view.bounds];
    _roomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _roomView.userInteractionEnabled = YES;
    UITapGestureRecognizer *roomTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(roomTapped:)] autorelease];
    [_roomView addGestureRecognizer:roomTap];
    [self.view addSubview:_roomView];

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Düzenle" style:UIBarButtonItemStyleBordered target:self action:@selector(editTapped:)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];

    _statusLabel = [[self labelWithFrame:CGRectMake(620.0f, 14.0f, 374.0f, 42.0f) text:@"" fontSize:18.0f bold:YES] retain];
    _statusLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.86f];
    _statusLabel.layer.cornerRadius = 14.0f;
    _statusLabel.clipsToBounds = YES;
    [self.view addSubview:_statusLabel];

    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 14.0f, 560.0f, 66.0f) text:@"Odadaki bir eşyaya dokun; yavrun onu doğrudan kullansın." fontSize:17.0f bold:YES] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    _feedbackLabel.layer.cornerRadius = 14.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];

    _avatarView = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(345.0f, 235.0f, 315.0f, 390.0f) speciesIdentifier:_gameState.pet.speciesIdentifier];
    _avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *petTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)] autorelease];
    [_avatarView addGestureRecognizer:petTap];
    [self.view addSubview:_avatarView];
    [self refreshUI];
}

- (void)refreshUI {
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], (long)_gameState.coins];
    _roomView.placedItems = _gameState.placedItemIdentifiers;
    _roomView.dayPart = [_gameState dayPartDisplayName];
    _roomView.season = [_gameState seasonDisplayName];
    _avatarView.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    _avatarView.equippedAccessories = _gameState.equippedAccessories;
}

- (void)roomTapped:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:_roomView];
    NSString *identifier = [_roomView itemIdentifierAtPoint:point];
    if (!identifier) {
        _feedbackLabel.text = @"Bir eşyaya dokunmayı dene. Ortadaki yavruya dokunursan onu seversin.";
        return;
    }
    NSDictionary *item = [PKCatalog itemForIdentifier:identifier];
    _feedbackLabel.text = [_gameState interactWithPlacedItemIdentifier:identifier];
    NSString *reaction = [item objectForKey:@"action"];
    if ([reaction length] == 0) reaction = [identifier isEqualToString:@"rug"] ? @"cuddle" : @"play";
    [self showReaction:reaction];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)avatarTapped:(UITapGestureRecognizer *)recognizer {
    (void)recognizer;
    _feedbackLabel.text = [_gameState performActionIdentifier:@"cuddle"];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self showReaction:@"touch"];
    [self refreshUI];
}

- (void)showReaction:(NSString *)identifier {
    _avatarView.reactionIdentifier = identifier;
    [UIView beginAnimations:@"roomPetReaction" context:nil];
    [UIView setAnimationDuration:0.18f];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:1.0f];
    _avatarView.transform = [identifier isEqualToString:@"sleep"] ? CGAffineTransformMakeScale(1.0f, 0.92f) : CGAffineTransformMakeTranslation(0.0f, -13.0f);
    [UIView commitAnimations];
    [self performSelector:@selector(resetReaction) withObject:nil afterDelay:0.42f];
}

- (void)resetReaction {
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
}

- (void)editTapped:(id)sender {
    (void)sender;
    PKDecorViewController *controller = [[PKDecorViewController alloc] initWithGameState:_gameState];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_gameState release];
    [_roomView release];
    [_avatarView release];
    [_statusLabel release];
    [_feedbackLabel release];
    [super dealloc];
}

@end
