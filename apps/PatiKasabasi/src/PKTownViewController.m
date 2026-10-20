#import "PKTownViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKActivitySceneView.h"
#import "PKPetAvatarView.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKTownViewController ()
- (void)refreshUI;
- (NSInteger)targetIndexAtPoint:(CGPoint)point;
- (void)refreshTargetHighlight;
- (void)performTargetAtIndex:(NSInteger)index;
- (void)showPetReaction:(NSString *)identifier;
- (void)resetPetReaction;
- (void)startPetIdleAnimation;
- (void)stopPetIdleAnimation;
- (void)movePetTowardButton:(UIButton *)button;
- (void)returnPetHome;
@end

@implementation PKTownViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _dragTargetIndex = -1;
        self.title = @"Kasaba Meydanı";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sceneView = [[PKActivitySceneView alloc] initWithFrame:self.view.bounds sceneIdentifier:@"square"];
    _sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_sceneView];

    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Evimiz" style:UIBarButtonItemStyleBordered target:self action:@selector(homeTapped:)];
    self.navigationItem.leftBarButtonItem = homeButton;
    [homeButton release];

    UILabel *title = [self labelWithFrame:CGRectMake(28.0f, 8.0f, 470.0f, 44.0f) text:@"Kasaba Meydanı" fontSize:29.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    title.textColor = [PKTheme darkTealColor];
    [self.view addSubview:title];
    _statusLabel = [[self labelWithFrame:CGRectMake(620.0f, 8.0f, 374.0f, 44.0f) text:@"" fontSize:18.0f bold:YES] retain];
    _statusLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    _statusLabel.layer.cornerRadius = 14.0f;
    _statusLabel.clipsToBounds = YES;
    [self.view addSubview:_statusLabel];

    _eventButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _eventButton.frame = CGRectMake(40.0f, 85.0f, 350.0f, 420.0f);
    _eventButton.backgroundColor = [UIColor colorWithRed:0.91f green:0.39f blue:0.45f alpha:0.92f];
    _eventButton.layer.cornerRadius = 28.0f;
    _eventButton.layer.borderWidth = 5.0f;
    _eventButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.95f].CGColor;
    _eventButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _eventButton.layer.shadowOpacity = 0.18f;
    _eventButton.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    _eventButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    _eventButton.titleLabel.numberOfLines = 6;
    _eventButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [_eventButton addTarget:self action:@selector(eventTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_eventButton];

    _requestButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _requestButton.frame = CGRectMake(634.0f, 85.0f, 350.0f, 420.0f);
    _requestButton.backgroundColor = [UIColor colorWithRed:0.42f green:0.61f blue:0.84f alpha:0.92f];
    _requestButton.layer.cornerRadius = 28.0f;
    _requestButton.layer.borderWidth = 5.0f;
    _requestButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.95f].CGColor;
    _requestButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _requestButton.layer.shadowOpacity = 0.18f;
    _requestButton.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    [_requestButton addTarget:self action:@selector(requestTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_requestButton];
    _requestLabel = [[self labelWithFrame:CGRectMake(18.0f, 18.0f, 314.0f, 360.0f) text:@"" fontSize:19.0f bold:YES] retain];
    _requestLabel.textColor = [UIColor whiteColor];
    [_requestButton addSubview:_requestLabel];
    UILabel *requestHint = [self labelWithFrame:CGRectMake(20.0f, 365.0f, 310.0f, 38.0f) text:@"Dokun veya yavrunu getir" fontSize:15.0f bold:YES];
    requestHint.textColor = [UIColor whiteColor];
    [_requestButton addSubview:requestHint];

    _petMotionView = [[UIView alloc] initWithFrame:CGRectMake(397.0f, 205.0f, 230.0f, 285.0f)];
    _petMotionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    _petMotionView.layer.cornerRadius = 34.0f;
    _petMotionView.layer.borderWidth = 4.0f;
    _petMotionView.layer.borderColor = [PKTheme darkTealColor].CGColor;
    _petAvatarView = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 230.0f, 235.0f) speciesIdentifier:_gameState.pet.speciesIdentifier];
    _petAvatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(petTapped:)] autorelease];
    [_petAvatarView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(petPanned:)] autorelease];
    [_petAvatarView addGestureRecognizer:pan];
    [_petMotionView addSubview:_petAvatarView];
    UILabel *dragHint = [self labelWithFrame:CGRectMake(6.0f, 235.0f, 218.0f, 42.0f) text:@"Sahneye ya da isteğe sürükle" fontSize:14.0f bold:YES];
    dragHint.textColor = [PKTheme darkTealColor];
    [_petMotionView addSubview:dragHint];
    [self.view addSubview:_petMotionView];
    _petHomeCenter = _petMotionView.center;

    _feedbackLabel = [[self labelWithFrame:CGRectMake(100.0f, 550.0f, 824.0f, 92.0f) text:@"Yavrunu şenlik sahnesine sürükle; birlikte dans edip rozet kazan." fontSize:18.0f bold:YES] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    _feedbackLabel.layer.cornerRadius = 16.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];
    [self refreshUI];
}

- (void)refreshUI {
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], [_gameState seasonDisplayName], (long)_gameState.coins];
    [_eventButton setTitle:[NSString stringWithFormat:@"★  BUGÜNÜN ŞENLİĞİ  ★\n\n%@\n\nDans et • 25 pati\nKoleksiyon rozeti\n\nDokun veya yavrunu getir", [_gameState townEventDisplayName]] forState:UIControlStateNormal];
    BOOL requestHere = [_gameState isNeighborRequestAtLocation:@"square"];
    BOOL requestDone = [_gameState isNeighborRequestCompletedToday];
    _requestButton.enabled = requestHere && !requestDone;
    _requestButton.alpha = requestHere ? (requestDone ? 0.70f : 1.0f) : 0.58f;
    NSString *location = [[_gameState currentNeighborRequest] objectForKey:@"location"];
    if (requestHere) {
        _requestLabel.text = requestDone ? @"GÜNLÜK İSTEK\n\nTamamlandı ✓\n\nYarın yeni bir komşu isteği gelecek." : [NSString stringWithFormat:@"GÜNLÜK İSTEK\n\n%@\n\n%@", [[_gameState currentNeighborRequest] objectForKey:@"title"], [[_gameState currentNeighborRequest] objectForKey:@"detail"]];
    } else {
        _requestLabel.text = [NSString stringWithFormat:@"GÜNLÜK İSTEK\n\nBugünkü görev burada değil.\n\n%@ bölgesine git.", [PKCatalog locationDisplayName:location]];
    }
    _petAvatarView.speciesIdentifier = _gameState.pet.speciesIdentifier;
    _petAvatarView.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    _petAvatarView.equippedAccessories = _gameState.equippedAccessories;
}

- (NSInteger)targetIndexAtPoint:(CGPoint)point {
    if (CGRectContainsPoint(_eventButton.frame, point)) return 0;
    if (_requestButton.enabled && CGRectContainsPoint(_requestButton.frame, point)) return 1;
    return -1;
}

- (void)refreshTargetHighlight {
    BOOL eventTarget = (_dragTargetIndex == 0);
    BOOL requestTarget = (_dragTargetIndex == 1);
    _eventButton.transform = eventTarget ? CGAffineTransformMakeScale(1.04f, 1.04f) : CGAffineTransformIdentity;
    _requestButton.transform = requestTarget ? CGAffineTransformMakeScale(1.04f, 1.04f) : CGAffineTransformIdentity;
    _eventButton.layer.borderWidth = eventTarget ? 10.0f : 5.0f;
    _requestButton.layer.borderWidth = requestTarget ? 10.0f : 5.0f;
}

- (void)petPanned:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
        [self stopPetIdleAnimation];
        _petMotionView.transform = CGAffineTransformMakeScale(1.07f, 1.07f);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        _petMotionView.center = CGPointMake(MIN(MAX(point.x, 65.0f), 959.0f), MIN(MAX(point.y, 105.0f), 610.0f));
        NSInteger target = [self targetIndexAtPoint:point];
        if (_dragTargetIndex != target) {
            _dragTargetIndex = target;
            [self refreshTargetHighlight];
        }
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        NSInteger target = [self targetIndexAtPoint:point];
        _dragTargetIndex = -1;
        [self refreshTargetHighlight];
        [self returnPetHome];
        if (target >= 0) [self performTargetAtIndex:target];
        else _feedbackLabel.text = @"Yavrunu soldaki şenlik sahnesine veya etkin günlük istek kartına bırak.";
    }
}

- (void)performTargetAtIndex:(NSInteger)index {
    if (index == 0) {
        _feedbackLabel.text = [_gameState attendTownEvent];
        [self showPetReaction:@"play"];
    } else if (index == 1 && _requestButton.enabled) {
        _feedbackLabel.text = [_gameState completeNeighborRequestAtLocation:@"square"];
        [self showPetReaction:@"cuddle"];
    }
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshUI];
}

- (void)eventTapped:(id)sender {
    (void)sender;
    [self movePetTowardButton:_eventButton];
    [self performTargetAtIndex:0];
}

- (void)requestTapped:(id)sender {
    (void)sender;
    if (!_requestButton.enabled) return;
    [self movePetTowardButton:_requestButton];
    [self performTargetAtIndex:1];
}

- (void)movePetTowardButton:(UIButton *)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnPetHome) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
    [self stopPetIdleAnimation];
    [UIView beginAnimations:@"squarePetTravel" context:nil];
    [UIView setAnimationDuration:0.27f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _petMotionView.center = button.center;
    _petMotionView.transform = CGAffineTransformMakeScale(0.80f, 0.80f);
    [UIView commitAnimations];
    [self performSelector:@selector(returnPetHome) withObject:nil afterDelay:0.33f];
}

- (void)returnPetHome {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
    [UIView beginAnimations:@"squarePetReturn" context:nil];
    [UIView setAnimationDuration:0.27f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _petMotionView.center = _petHomeCenter;
    _petMotionView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [self performSelector:@selector(startPetIdleAnimation) withObject:nil afterDelay:0.30f];
}

- (void)showPetReaction:(NSString *)identifier {
    _petAvatarView.reactionIdentifier = identifier;
    [UIView beginAnimations:@"squarePetReaction" context:nil];
    [UIView setAnimationDuration:0.18f];
    [UIView setAnimationRepeatCount:2.0f];
    [UIView setAnimationRepeatAutoreverses:YES];
    _petAvatarView.transform = CGAffineTransformMakeRotation(0.07f);
    [UIView commitAnimations];
    [self performSelector:@selector(resetPetReaction) withObject:nil afterDelay:0.72f];
}

- (void)resetPetReaction {
    _petAvatarView.transform = CGAffineTransformIdentity;
    _petAvatarView.reactionIdentifier = @"";
}

- (void)startPetIdleAnimation {
    [self stopPetIdleAnimation];
    [UIView beginAnimations:@"squarePetIdle" context:nil];
    [UIView setAnimationDuration:1.60f];
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
    [_statusLabel release];
    [_feedbackLabel release];
    [_requestLabel release];
    [_eventButton release];
    [_requestButton release];
    [super dealloc];
}

@end
