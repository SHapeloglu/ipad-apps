#import "PKParkViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKActivitySceneView.h"
#import "PKPetAvatarView.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKParkViewController ()
- (void)refreshUI;
- (void)visitNeighborAtIndex:(NSInteger)index;
- (NSInteger)neighborIndexAtPoint:(CGPoint)point;
- (void)refreshTargetHighlight;
- (void)showPetReaction:(NSString *)identifier;
- (void)resetPetReaction;
- (void)startPetIdleAnimation;
- (void)stopPetIdleAnimation;
- (void)movePetTowardButton:(UIButton *)button;
- (void)returnPetHome;
@end

@implementation PKParkViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _dragTargetIndex = -1;
        self.title = @"Dostluk Parkı";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sceneView = [[PKActivitySceneView alloc] initWithFrame:self.view.bounds sceneIdentifier:@"park"];
    _sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_sceneView];

    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Evimiz" style:UIBarButtonItemStyleBordered target:self action:@selector(homeTapped:)];
    self.navigationItem.leftBarButtonItem = homeButton;
    [homeButton release];

    UILabel *title = [self labelWithFrame:CGRectMake(28.0f, 8.0f, 430.0f, 44.0f) text:@"Dostluk Parkı" fontSize:29.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    title.textColor = [PKTheme darkTealColor];
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(620.0f, 8.0f, 374.0f, 44.0f) text:@"" fontSize:18.0f bold:YES] retain];
    _statusLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    _statusLabel.layer.cornerRadius = 14.0f;
    _statusLabel.clipsToBounds = YES;
    [self.view addSubview:_statusLabel];

    UIView *requestPanel = [[[UIView alloc] initWithFrame:CGRectMake(30.0f, 58.0f, 964.0f, 98.0f)] autorelease];
    [PKTheme stylePanel:requestPanel];
    requestPanel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    [self.view addSubview:requestPanel];
    _requestLabel = [[self labelWithFrame:CGRectMake(18.0f, 7.0f, 692.0f, 84.0f) text:@"" fontSize:16.0f bold:YES] retain];
    _requestLabel.textAlignment = UITextAlignmentLeft;
    [requestPanel addSubview:_requestLabel];
    _requestButton = [self secondaryButtonWithFrame:CGRectMake(730.0f, 21.0f, 210.0f, 58.0f) title:@"İsteği Tamamla"];
    [_requestButton addTarget:self action:@selector(requestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [requestPanel addSubview:_requestButton];

    NSArray *frames = [NSArray arrayWithObjects:
        [NSValue valueWithCGRect:CGRectMake(30.0f, 180.0f, 300.0f, 180.0f)],
        [NSValue valueWithCGRect:CGRectMake(694.0f, 180.0f, 300.0f, 180.0f)],
        [NSValue valueWithCGRect:CGRectMake(30.0f, 390.0f, 300.0f, 180.0f)],
        [NSValue valueWithCGRect:CGRectMake(694.0f, 390.0f, 300.0f, 180.0f)], nil];
    NSArray *colors = [NSArray arrayWithObjects:
        [UIColor colorWithRed:0.66f green:0.48f blue:0.82f alpha:0.95f],
        [UIColor colorWithRed:0.35f green:0.68f blue:0.42f alpha:0.95f],
        [UIColor colorWithRed:0.90f green:0.48f blue:0.63f alpha:0.95f],
        [UIColor colorWithRed:0.91f green:0.61f blue:0.29f alpha:0.95f], nil];
    NSArray *neighbors = [PKCatalog neighbors];
    NSMutableArray *neighborButtons = [NSMutableArray array];
    NSUInteger index = 0;
    for (index = 0; index < [neighbors count]; index++) {
        NSDictionary *neighbor = [neighbors objectAtIndex:index];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = [[frames objectAtIndex:index] CGRectValue];
        button.tag = (NSInteger)index;
        button.backgroundColor = [colors objectAtIndex:index];
        button.layer.cornerRadius = 22.0f;
        button.layer.borderWidth = 4.0f;
        button.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.94f].CGColor;
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shadowOpacity = 0.16f;
        button.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        [button addTarget:self action:@selector(neighborTapped:) forControlEvents:UIControlEventTouchUpInside];

        PKPetAvatarView *neighborAvatar = [[[PKPetAvatarView alloc] initWithFrame:CGRectMake(5.0f, 4.0f, 118.0f, 140.0f) speciesIdentifier:[neighbor objectForKey:@"species"]] autorelease];
        neighborAvatar.userInteractionEnabled = NO;
        [button addSubview:neighborAvatar];
        UILabel *name = [self labelWithFrame:CGRectMake(112.0f, 16.0f, 174.0f, 40.0f) text:[neighbor objectForKey:@"name"] fontSize:24.0f bold:YES];
        name.textColor = [UIColor whiteColor];
        [button addSubview:name];
        NSInteger friendship = [_gameState.pet friendshipForNeighborIdentifier:[neighbor objectForKey:@"id"]];
        UILabel *detail = [self labelWithFrame:CGRectMake(104.0f, 57.0f, 184.0f, 82.0f) text:[NSString stringWithFormat:@"%@\nArkadaşlık %ld/100", [neighbor objectForKey:@"detail"], (long)friendship] fontSize:15.0f bold:YES];
        detail.tag = 500;
        detail.textColor = [UIColor whiteColor];
        [button addSubview:detail];
        UILabel *visit = [self labelWithFrame:CGRectMake(52.0f, 142.0f, 196.0f, 29.0f) text:@"Dokun veya yavrunu getir" fontSize:14.0f bold:YES];
        visit.textColor = [UIColor whiteColor];
        [button addSubview:visit];
        [self.view addSubview:button];
        [neighborButtons addObject:button];
    }
    _neighborButtons = [[NSArray alloc] initWithArray:neighborButtons];

    _petMotionView = [[UIView alloc] initWithFrame:CGRectMake(387.0f, 218.0f, 250.0f, 275.0f)];
    _petMotionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.86f];
    _petMotionView.layer.cornerRadius = 34.0f;
    _petMotionView.layer.borderWidth = 4.0f;
    _petMotionView.layer.borderColor = [PKTheme darkTealColor].CGColor;
    _petAvatarView = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 250.0f, 225.0f) speciesIdentifier:_gameState.pet.speciesIdentifier];
    _petAvatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(petTapped:)] autorelease];
    [_petAvatarView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(petPanned:)] autorelease];
    [_petAvatarView addGestureRecognizer:pan];
    [_petMotionView addSubview:_petAvatarView];
    UILabel *dragHint = [self labelWithFrame:CGRectMake(6.0f, 224.0f, 238.0f, 42.0f) text:@"Bir arkadaşın yanına sürükle" fontSize:15.0f bold:YES];
    dragHint.textColor = [PKTheme darkTealColor];
    [_petMotionView addSubview:dragHint];
    [self.view addSubview:_petMotionView];
    _petHomeCenter = _petMotionView.center;

    _feedbackLabel = [[self labelWithFrame:CGRectMake(120.0f, 595.0f, 784.0f, 60.0f) text:@"Yavrunu bir arkadaşının kartına sürükle; birlikte oynasınlar." fontSize:17.0f bold:YES] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    _feedbackLabel.layer.cornerRadius = 14.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];
    [self refreshUI];
}

- (void)refreshUI {
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], (long)_gameState.coins];
    BOOL requestHere = [_gameState isNeighborRequestAtLocation:@"park"];
    _requestButton.hidden = !requestHere;
    _requestButton.enabled = ![_gameState isNeighborRequestCompletedToday];
    [_requestButton setTitle:([_gameState isNeighborRequestCompletedToday] ? @"Tamamlandı ✓" : @"İsteği Tamamla") forState:UIControlStateNormal];
    NSString *location = [[_gameState currentNeighborRequest] objectForKey:@"location"];
    _requestLabel.text = requestHere ? [_gameState neighborRequestText] : [NSString stringWithFormat:@"Bugünkü istek %@ bölgesinde.\nParkta arkadaşlarınla yine de oynayabilirsin.", [PKCatalog locationDisplayName:location]];
    _petAvatarView.speciesIdentifier = _gameState.pet.speciesIdentifier;
    _petAvatarView.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    _petAvatarView.equippedAccessories = _gameState.equippedAccessories;

    NSArray *neighbors = [PKCatalog neighbors];
    NSUInteger index = 0;
    for (index = 0; index < [_neighborButtons count]; index++) {
        UIButton *button = [_neighborButtons objectAtIndex:index];
        NSDictionary *neighbor = [neighbors objectAtIndex:index];
        UILabel *detail = (UILabel *)[button viewWithTag:500];
        if ([detail isKindOfClass:[UILabel class]]) {
            NSInteger friendship = [_gameState.pet friendshipForNeighborIdentifier:[neighbor objectForKey:@"id"]];
            detail.text = [NSString stringWithFormat:@"%@\nArkadaşlık %ld/100", [neighbor objectForKey:@"detail"], (long)friendship];
        }
    }
}

- (void)neighborTapped:(UIButton *)sender {
    [self movePetTowardButton:sender];
    [self visitNeighborAtIndex:sender.tag];
}

- (void)visitNeighborAtIndex:(NSInteger)index {
    NSArray *neighbors = [PKCatalog neighbors];
    if (index < 0 || index >= (NSInteger)[neighbors count]) return;
    NSDictionary *neighbor = [neighbors objectAtIndex:(NSUInteger)index];
    _feedbackLabel.text = [_gameState visitNeighborIdentifier:[neighbor objectForKey:@"id"]];
    [self showPetReaction:@"play"];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (NSInteger)neighborIndexAtPoint:(CGPoint)point {
    NSUInteger index = 0;
    for (index = 0; index < [_neighborButtons count]; index++) {
        UIButton *button = [_neighborButtons objectAtIndex:index];
        if (CGRectContainsPoint(button.frame, point)) return (NSInteger)index;
    }
    return -1;
}

- (void)refreshTargetHighlight {
    NSUInteger index = 0;
    for (index = 0; index < [_neighborButtons count]; index++) {
        UIButton *button = [_neighborButtons objectAtIndex:index];
        BOOL target = ((NSInteger)index == _dragTargetIndex);
        button.transform = target ? CGAffineTransformMakeScale(1.05f, 1.05f) : CGAffineTransformIdentity;
        button.alpha = (_dragTargetIndex < 0 || target) ? 1.0f : 0.76f;
        button.layer.borderWidth = target ? 9.0f : 4.0f;
    }
}

- (void)petPanned:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
        [self stopPetIdleAnimation];
        _petMotionView.transform = CGAffineTransformMakeScale(1.06f, 1.06f);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        _petMotionView.center = CGPointMake(MIN(MAX(point.x, 65.0f), 959.0f), MIN(MAX(point.y, 105.0f), 610.0f));
        NSInteger target = [self neighborIndexAtPoint:point];
        if (_dragTargetIndex != target) {
            _dragTargetIndex = target;
            [self refreshTargetHighlight];
        }
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        NSInteger target = [self neighborIndexAtPoint:point];
        _dragTargetIndex = -1;
        [self refreshTargetHighlight];
        [self returnPetHome];
        if (target >= 0) [self visitNeighborAtIndex:target];
        else _feedbackLabel.text = @"Yavrunu Luna, Zeytin, Mira veya Fındık kartının üzerine bırak.";
    }
}

- (void)movePetTowardButton:(UIButton *)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnPetHome) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
    [self stopPetIdleAnimation];
    [UIView beginAnimations:@"parkPetTravel" context:nil];
    [UIView setAnimationDuration:0.26f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _petMotionView.center = button.center;
    _petMotionView.transform = CGAffineTransformMakeScale(0.80f, 0.80f);
    [UIView commitAnimations];
    [self performSelector:@selector(returnPetHome) withObject:nil afterDelay:0.32f];
}

- (void)returnPetHome {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
    [UIView beginAnimations:@"parkPetReturn" context:nil];
    [UIView setAnimationDuration:0.26f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _petMotionView.center = _petHomeCenter;
    _petMotionView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [self performSelector:@selector(startPetIdleAnimation) withObject:nil afterDelay:0.29f];
}

- (void)showPetReaction:(NSString *)identifier {
    _petAvatarView.reactionIdentifier = identifier;
    [UIView beginAnimations:@"parkPetReaction" context:nil];
    [UIView setAnimationDuration:0.18f];
    [UIView setAnimationRepeatCount:1.0f];
    [UIView setAnimationRepeatAutoreverses:YES];
    _petAvatarView.transform = CGAffineTransformMakeTranslation(0.0f, -13.0f);
    [UIView commitAnimations];
    [self performSelector:@selector(resetPetReaction) withObject:nil afterDelay:0.42f];
}

- (void)resetPetReaction {
    _petAvatarView.transform = CGAffineTransformIdentity;
    _petAvatarView.reactionIdentifier = @"";
}

- (void)startPetIdleAnimation {
    [self stopPetIdleAnimation];
    [UIView beginAnimations:@"parkPetIdle" context:nil];
    [UIView setAnimationDuration:1.65f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    _petMotionView.transform = CGAffineTransformMakeTranslation(0.0f, -5.0f);
    [UIView commitAnimations];
}

- (void)stopPetIdleAnimation {
    [_petMotionView.layer removeAllAnimations];
    _petMotionView.transform = CGAffineTransformIdentity;
}

- (void)petTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState performActionIdentifier:@"cuddle"];
    [self showPetReaction:@"touch"];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)requestTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState completeNeighborRequestAtLocation:@"park"];
    [self showPetReaction:@"cuddle"];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)homeTapped:(id)sender {
    (void)sender;
    [_gameState save];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _petMotionView.center = _petHomeCenter;
    _petAvatarView.transform = CGAffineTransformIdentity;
    _petAvatarView.reactionIdentifier = @"";
    _dragTargetIndex = -1;
    [self refreshTargetHighlight];
    [self refreshUI];
    [self startPetIdleAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopPetIdleAnimation];
    [_gameState save];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_gameState release];
    [_sceneView release];
    [_petMotionView release];
    [_petAvatarView release];
    [_neighborButtons release];
    [_statusLabel release];
    [_feedbackLabel release];
    [_requestLabel release];
    [super dealloc];
}

@end
