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
#include <float.h>

@interface PKRoomPlayViewController ()
- (void)refreshUI;
- (void)performRoomInteractionIdentifier:(NSString *)identifier;
- (void)showReaction:(NSString *)identifier;
- (void)resetReaction;
- (void)startAvatarIdleAnimation;
- (void)stopAvatarIdleAnimation;
- (void)returnAvatarHome;
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

    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 14.0f, 560.0f, 66.0f) text:@"Eşyaya dokun veya yavrunu yatağa, mama kabına ya da oyuncağa sürükle." fontSize:17.0f bold:YES] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    _feedbackLabel.layer.cornerRadius = 14.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];

    _avatarMotionView = [[UIView alloc] initWithFrame:CGRectMake(345.0f, 235.0f, 315.0f, 390.0f)];
    _avatarMotionView.backgroundColor = [UIColor clearColor];
    _avatarView = [[PKPetAvatarView alloc] initWithFrame:_avatarMotionView.bounds speciesIdentifier:_gameState.pet.speciesIdentifier];
    _avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *petTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)] autorelease];
    [_avatarView addGestureRecognizer:petTap];
    UIPanGestureRecognizer *petPan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(avatarPanned:)] autorelease];
    [_avatarView addGestureRecognizer:petPan];
    [_avatarMotionView addSubview:_avatarView];
    [self.view addSubview:_avatarMotionView];
    _avatarHomeCenter = _avatarMotionView.center;
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
        _feedbackLabel.text = @"Bir eşyaya dokun veya yavrunu görünür eşyanın üzerine bırak.";
        return;
    }
    [self performRoomInteractionIdentifier:identifier];
}

- (void)performRoomInteractionIdentifier:(NSString *)identifier {
    NSDictionary *item = [PKCatalog itemForIdentifier:identifier];
    _feedbackLabel.text = [_gameState interactWithPlacedItemIdentifier:identifier];
    NSString *reaction = [item objectForKey:@"action"];
    if ([reaction length] == 0) reaction = [identifier isEqualToString:@"rug"] ? @"cuddle" : @"play";
    [self showReaction:reaction];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)avatarPanned:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    CGPoint roomPoint = [_roomView convertPoint:point fromView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
        [self stopAvatarIdleAnimation];
        _avatarMotionView.transform = CGAffineTransformMakeScale(1.08f, 1.08f);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat x = MIN(MAX(point.x, 65.0f), self.view.bounds.size.width - 65.0f);
        CGFloat y = MIN(MAX(point.y, 110.0f), 650.0f);
        _avatarMotionView.center = CGPointMake(x, y);
        NSString *identifier = [_roomView itemIdentifierAtPoint:roomPoint];
        if ((_dragItemIdentifier != identifier) && ![_dragItemIdentifier isEqualToString:identifier]) {
            [_dragItemIdentifier release];
            _dragItemIdentifier = [identifier copy];
            _roomView.highlightedItemIdentifier = identifier;
        }
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        NSString *identifier = [[_roomView itemIdentifierAtPoint:roomPoint] retain];
        [_dragItemIdentifier release];
        _dragItemIdentifier = nil;
        _roomView.highlightedItemIdentifier = nil;
        [self returnAvatarHome];
        if ([identifier length] > 0) [self performRoomInteractionIdentifier:identifier];
        else _feedbackLabel.text = @"Yavrunu yatağın, mama kabının, topun veya başka bir eşyanın üzerine bırak.";
        [identifier release];
    }
}

- (void)returnAvatarHome {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
    [UIView beginAnimations:@"roomPetReturn" context:nil];
    [UIView setAnimationDuration:0.24f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [self performSelector:@selector(startAvatarIdleAnimation) withObject:nil afterDelay:0.27f];
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

- (void)startAvatarIdleAnimation {
    [self stopAvatarIdleAnimation];
    [UIView beginAnimations:@"roomPetIdle" context:nil];
    [UIView setAnimationDuration:1.80f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    _avatarMotionView.transform = CGAffineTransformMakeTranslation(0.0f, -5.0f);
    [UIView commitAnimations];
}

- (void)stopAvatarIdleAnimation {
    [_avatarMotionView.layer removeAllAnimations];
    _avatarMotionView.transform = CGAffineTransformIdentity;
}

- (void)editTapped:(id)sender {
    (void)sender;
    PKDecorViewController *controller = [[PKDecorViewController alloc] initWithGameState:_gameState];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
    _roomView.highlightedItemIdentifier = nil;
    [self refreshUI];
    [self startAvatarIdleAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopAvatarIdleAnimation];
    [_gameState save];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_gameState release];
    [_roomView release];
    [_avatarMotionView release];
    [_avatarView release];
    [_dragItemIdentifier release];
    [_statusLabel release];
    [_feedbackLabel release];
    [super dealloc];
}

@end
