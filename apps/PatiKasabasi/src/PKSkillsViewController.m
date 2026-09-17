#import "PKSkillsViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKActivitySceneView.h"
#import "PKPetAvatarView.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKSkillsViewController ()
- (void)refreshStatus;
- (void)refreshActivityButtons;
- (void)performActivityAtIndex:(NSInteger)index;
- (NSInteger)activityIndexAtPoint:(CGPoint)point;
- (void)refreshTargetHighlight;
- (void)showPetReaction:(NSString *)identifier;
- (void)resetPetReaction;
- (void)startPetIdleAnimation;
- (void)stopPetIdleAnimation;
- (void)movePetTowardButton:(UIButton *)button;
- (void)returnPetHome;
@end

@implementation PKSkillsViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _dragTargetIndex = -1;
        self.title = @"Pati Okulu";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _sceneView = [[PKActivitySceneView alloc] initWithFrame:self.view.bounds sceneIdentifier:@"school"];
    _sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_sceneView];

    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:@"Evimiz" style:UIBarButtonItemStyleBordered target:self action:@selector(homeTapped:)];
    self.navigationItem.leftBarButtonItem = homeButton;
    [homeButton release];
    _requestButton = [[UIBarButtonItem alloc] initWithTitle:@"Okul İsteği" style:UIBarButtonItemStyleBordered target:self action:@selector(requestTapped:)];

    UILabel *title = [self labelWithFrame:CGRectMake(28.0f, 8.0f, 510.0f, 44.0f) text:@"Beceriler, Okul ve Meslekler" fontSize:27.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    title.textColor = [PKTheme darkTealColor];
    [self.view addSubview:title];

    _statusLabel = [[self labelWithFrame:CGRectMake(590.0f, 8.0f, 404.0f, 44.0f) text:@"" fontSize:18.0f bold:YES] retain];
    _statusLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
    _statusLabel.layer.cornerRadius = 14.0f;
    _statusLabel.clipsToBounds = YES;
    [self.view addSubview:_statusLabel];

    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 60.0f, 964.0f, 70.0f) text:@"Bir ders kartına dokun veya yavrunu seçtiğin kartın üzerine sürükle." fontSize:17.0f bold:YES] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    _feedbackLabel.layer.cornerRadius = 14.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];

    _modeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Dersler", @"Meslekler", nil]];
    _modeControl.frame = CGRectMake(32.0f, 148.0f, 350.0f, 46.0f);
    _modeControl.selectedSegmentIndex = 0;
    [_modeControl addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_modeControl];

    _workButton = [[self primaryButtonWithFrame:CGRectMake(792.0f, 145.0f, 202.0f, 55.0f) title:@"İşe Git • 45 pati"] retain];
    [_workButton addTarget:self action:@selector(workTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_workButton];

    _petMotionView = [[UIView alloc] initWithFrame:CGRectMake(412.0f, 130.0f, 200.0f, 205.0f)];
    _petMotionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.82f];
    _petMotionView.layer.cornerRadius = 28.0f;
    _petMotionView.layer.borderWidth = 3.0f;
    _petMotionView.layer.borderColor = [PKTheme darkTealColor].CGColor;
    _petAvatarView = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 170.0f) speciesIdentifier:_gameState.pet.speciesIdentifier];
    _petAvatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(petTapped:)] autorelease];
    [_petAvatarView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(petPanned:)] autorelease];
    [_petAvatarView addGestureRecognizer:pan];
    [_petMotionView addSubview:_petAvatarView];
    UILabel *dragHint = [self labelWithFrame:CGRectMake(5.0f, 169.0f, 190.0f, 28.0f) text:@"Beni bir karta sürükle" fontSize:14.0f bold:YES];
    dragHint.textColor = [PKTheme darkTealColor];
    [_petMotionView addSubview:dragHint];
    [self.view addSubview:_petMotionView];
    _petHomeCenter = _petMotionView.center;

    NSArray *colors = [NSArray arrayWithObjects:
        [UIColor colorWithRed:0.36f green:0.63f blue:0.86f alpha:0.96f],
        [UIColor colorWithRed:0.88f green:0.45f blue:0.62f alpha:0.96f],
        [UIColor colorWithRed:0.35f green:0.69f blue:0.42f alpha:0.96f],
        [UIColor colorWithRed:0.72f green:0.52f blue:0.82f alpha:0.96f],
        [UIColor colorWithRed:0.91f green:0.61f blue:0.28f alpha:0.96f], nil];
    NSMutableArray *buttons = [NSMutableArray array];
    NSUInteger index = 0;
    for (index = 0; index < 5; index++) {
        UIButton *button = [self secondaryButtonWithFrame:CGRectMake(32.0f + ((CGFloat)index * 195.0f), 350.0f, 180.0f, 155.0f) title:@""];
        button.tag = (NSInteger)index;
        button.backgroundColor = [colors objectAtIndex:index];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        button.titleLabel.numberOfLines = 4;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        button.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.94f].CGColor;
        button.layer.borderWidth = 4.0f;
        [button addTarget:self action:@selector(activityTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [buttons addObject:button];
    }
    _activityButtons = [[NSArray alloc] initWithArray:buttons];
    [self refreshStatus];
}

- (void)refreshStatus {
    _statusLabel.text = [NSString stringWithFormat:@"%@ • Büyüme %ld • %ld pati", [_gameState.pet lifeStageDisplayName], (long)_gameState.pet.growthPoints, (long)_gameState.coins];
    BOOL requestHere = [_gameState isNeighborRequestAtLocation:@"school"];
    self.navigationItem.rightBarButtonItem = requestHere ? _requestButton : nil;
    _requestButton.enabled = ![_gameState isNeighborRequestCompletedToday];
    _requestButton.title = [_gameState isNeighborRequestCompletedToday] ? @"İstek ✓" : @"Okul İsteği";
    _petAvatarView.speciesIdentifier = _gameState.pet.speciesIdentifier;
    _petAvatarView.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    _petAvatarView.equippedAccessories = _gameState.equippedAccessories;
    _workButton.enabled = ([_gameState.pet.careerIdentifier length] > 0);
    _workButton.alpha = _workButton.enabled ? 1.0f : 0.55f;
    [self refreshActivityButtons];
}

- (void)refreshActivityButtons {
    NSArray *symbols = [NSArray arrayWithObjects:@"♪", @"✦", @"♣", @"◆", @"♥", nil];
    NSUInteger index = 0;
    BOOL careerMode = (_modeControl.selectedSegmentIndex == 1);
    for (index = 0; index < [_activityButtons count]; index++) {
        UIButton *button = [_activityButtons objectAtIndex:index];
        NSString *title = nil;
        if (!careerMode) {
            NSString *skill = [[PKCatalog skillIdentifiers] objectAtIndex:index];
            NSInteger level = [_gameState.pet skillLevelForIdentifier:skill];
            NSString *bonus = [_gameState hasFunctionalItemForIdentifier:skill] ? @"Eşya bonusu +2" : @"Ders +1";
            title = [NSString stringWithFormat:@"%@  %@\nSeviye %ld/10\n%@", [symbols objectAtIndex:index], [PKCatalog skillDisplayName:skill], (long)level, bonus];
        } else {
            NSString *career = [[PKCatalog careerIdentifiers] objectAtIndex:index];
            NSString *skill = [PKCatalog careerSkillIdentifier:career];
            BOOL selected = [_gameState.pet.careerIdentifier isEqualToString:career];
            title = [NSString stringWithFormat:@"%@  %@\n%@ %ld/10\n%@", [symbols objectAtIndex:index], [PKCatalog careerDisplayName:career], [PKCatalog skillDisplayName:skill], (long)[_gameState.pet skillLevelForIdentifier:skill], selected ? @"Seçili ✓" : @"Meslek seç"];
        }
        [button setTitle:title forState:UIControlStateNormal];
    }
}

- (void)modeChanged:(id)sender {
    (void)sender;
    _feedbackLabel.text = (_modeControl.selectedSegmentIndex == 0) ? @"Bir ders seç veya yavrunu ders kartına sürükle." : @"Yetişkin yavrunu istediğin meslek kartına sürükle.";
    [self refreshActivityButtons];
}

- (void)activityTapped:(UIButton *)sender {
    [self movePetTowardButton:sender];
    [self performActivityAtIndex:sender.tag];
}

- (void)performActivityAtIndex:(NSInteger)index {
    if (index < 0 || index >= 5) return;
    if (_modeControl.selectedSegmentIndex == 0) {
        NSString *skill = [[PKCatalog skillIdentifiers] objectAtIndex:(NSUInteger)index];
        _feedbackLabel.text = [_gameState trainSkillIdentifier:skill];
        [self showPetReaction:@"play"];
        [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    } else {
        NSString *career = [[PKCatalog careerIdentifiers] objectAtIndex:(NSUInteger)index];
        _feedbackLabel.text = [_gameState chooseCareerIdentifier:career];
        [self showPetReaction:@"cuddle"];
        [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    }
    [self refreshStatus];
}

- (NSInteger)activityIndexAtPoint:(CGPoint)point {
    NSUInteger index = 0;
    for (index = 0; index < [_activityButtons count]; index++) {
        UIButton *button = [_activityButtons objectAtIndex:index];
        if (CGRectContainsPoint(button.frame, point)) return (NSInteger)index;
    }
    return -1;
}

- (void)refreshTargetHighlight {
    NSUInteger index = 0;
    for (index = 0; index < [_activityButtons count]; index++) {
        UIButton *button = [_activityButtons objectAtIndex:index];
        BOOL target = ((NSInteger)index == _dragTargetIndex);
        button.transform = target ? CGAffineTransformMakeScale(1.06f, 1.06f) : CGAffineTransformIdentity;
        button.alpha = (_dragTargetIndex < 0 || target) ? 1.0f : 0.78f;
        button.layer.borderWidth = target ? 9.0f : 4.0f;
    }
}

- (void)petPanned:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
        [self stopPetIdleAnimation];
        _petMotionView.transform = CGAffineTransformMakeScale(1.07f, 1.07f);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        _petMotionView.center = CGPointMake(MIN(MAX(point.x, 70.0f), 954.0f), MIN(MAX(point.y, 105.0f), 600.0f));
        NSInteger target = [self activityIndexAtPoint:point];
        if (_dragTargetIndex != target) {
            _dragTargetIndex = target;
            [self refreshTargetHighlight];
        }
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        NSInteger target = [self activityIndexAtPoint:point];
        _dragTargetIndex = -1;
        [self refreshTargetHighlight];
        [self returnPetHome];
        if (target >= 0) [self performActivityAtIndex:target];
        else _feedbackLabel.text = @"Yavrunu renkli ders veya meslek kartlarından birinin üzerine bırak.";
    }
}

- (void)movePetTowardButton:(UIButton *)button {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(returnPetHome) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
    [self stopPetIdleAnimation];
    [UIView beginAnimations:@"schoolPetTravel" context:nil];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _petMotionView.center = button.center;
    _petMotionView.transform = CGAffineTransformMakeScale(0.82f, 0.82f);
    [UIView commitAnimations];
    [self performSelector:@selector(returnPetHome) withObject:nil afterDelay:0.30f];
}

- (void)returnPetHome {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startPetIdleAnimation) object:nil];
    [UIView beginAnimations:@"schoolPetReturn" context:nil];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _petMotionView.center = _petHomeCenter;
    _petMotionView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [self performSelector:@selector(startPetIdleAnimation) withObject:nil afterDelay:0.28f];
}

- (void)showPetReaction:(NSString *)identifier {
    _petAvatarView.reactionIdentifier = identifier;
    [UIView beginAnimations:@"schoolPetReaction" context:nil];
    [UIView setAnimationDuration:0.18f];
    [UIView setAnimationRepeatCount:1.0f];
    [UIView setAnimationRepeatAutoreverses:YES];
    _petAvatarView.transform = CGAffineTransformMakeTranslation(0.0f, -12.0f);
    [UIView commitAnimations];
    [self performSelector:@selector(resetPetReaction) withObject:nil afterDelay:0.42f];
}

- (void)resetPetReaction {
    _petAvatarView.transform = CGAffineTransformIdentity;
    _petAvatarView.reactionIdentifier = @"";
}

- (void)startPetIdleAnimation {
    [self stopPetIdleAnimation];
    [UIView beginAnimations:@"schoolPetIdle" context:nil];
    [UIView setAnimationDuration:1.70f];
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
    [self refreshStatus];
}

- (void)workTapped:(id)sender {
    (void)sender;
    [self movePetTowardButton:_workButton];
    _feedbackLabel.text = [_gameState workCareer];
    [self showPetReaction:@"play"];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshStatus];
}

- (void)requestTapped:(id)sender {
    (void)sender;
    _feedbackLabel.text = [_gameState completeNeighborRequestAtLocation:@"school"];
    [self showPetReaction:@"play"];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshStatus];
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
    [self refreshStatus];
    if ([_gameState isNeighborRequestAtLocation:@"school"]) _feedbackLabel.text = [_gameState neighborRequestText];
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
    [_activityButtons release];
    [_modeControl release];
    [_workButton release];
    [_statusLabel release];
    [_feedbackLabel release];
    [_requestButton release];
    [super dealloc];
}

@end
