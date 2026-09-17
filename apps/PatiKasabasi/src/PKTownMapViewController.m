#import "PKTownMapViewController.h"
#import "PKTownMapView.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKPetAvatarView.h"
#import "PKAmbientObjectView.h"
#import "PKCatalog.h"
#import "PKTownViewController.h"
#import "PKParkViewController.h"
#import "PKSkillsViewController.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKTownMapViewController ()
- (UIButton *)mapButtonWithFrame:(CGRect)frame title:(NSString *)title tag:(NSInteger)tag color:(UIColor *)color;
- (void)refreshUI;
- (void)refreshLocationButtons;
- (NSInteger)locationTagAtPoint:(CGPoint)point;
- (UIButton *)buttonForLocationTag:(NSInteger)tag;
- (void)openLocationTag:(NSInteger)tag;
- (void)openPendingLocation;
- (void)startAmbientAnimations;
- (void)stopAmbientAnimations;
- (void)startPetIdleAnimation;
- (void)stopPetIdleAnimation;
- (void)returnPetTokenHome;
@end

@implementation PKTownMapViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _dragTargetTag = -1;
        _pendingDestinationTag = -1;
        _openingDestination = NO;
        self.title = @"Kasaba Haritası";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView = [[PKTownMapView alloc] initWithFrame:self.view.bounds];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mapView];

    PKAmbientObjectView *flag = [[[PKAmbientObjectView alloc] initWithFrame:CGRectMake(338.0f, 128.0f, 58.0f, 82.0f) objectIdentifier:@"flag"] autorelease];
    PKAmbientObjectView *tree = [[[PKAmbientObjectView alloc] initWithFrame:CGRectMake(594.0f, 116.0f, 82.0f, 112.0f) objectIdentifier:@"tree"] autorelease];
    PKAmbientObjectView *lantern = [[[PKAmbientObjectView alloc] initWithFrame:CGRectMake(706.0f, 382.0f, 68.0f, 88.0f) objectIdentifier:@"lantern"] autorelease];
    [self.view addSubview:flag];
    [self.view addSubview:tree];
    [self.view addSubview:lantern];
    _ambientViews = [[NSArray alloc] initWithObjects:flag, tree, lantern, nil];

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

    _petTokenView = [[UIView alloc] initWithFrame:CGRectMake(458.0f, 244.0f, 112.0f, 118.0f)];
    _petTokenView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    _petTokenView.layer.cornerRadius = 25.0f;
    _petTokenView.layer.borderWidth = 3.0f;
    _petTokenView.layer.borderColor = [PKTheme darkTealColor].CGColor;
    _petTokenView.layer.shadowColor = [UIColor blackColor].CGColor;
    _petTokenView.layer.shadowOpacity = 0.18f;
    _petTokenView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    _petTokenView.isAccessibilityElement = YES;
    _petTokenView.accessibilityLabel = @"Haritadaki yavru";
    _petTokenView.accessibilityHint = @"Bir bölgeye sürükle veya bölge düğmesine dokun";
    _petTokenAvatar = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(18.0f, 0.0f, 76.0f, 91.0f) speciesIdentifier:_gameState.pet.speciesIdentifier];
    _petTokenAvatar.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    _petTokenAvatar.equippedAccessories = _gameState.equippedAccessories;
    [_petTokenView addSubview:_petTokenAvatar];
    UILabel *dragLabel = [self labelWithFrame:CGRectMake(4.0f, 90.0f, 104.0f, 23.0f) text:@"Sürükle" fontSize:14.0f bold:YES];
    dragLabel.textColor = [PKTheme darkTealColor];
    [_petTokenView addSubview:dragLabel];
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(petTokenPanned:)] autorelease];
    [_petTokenView addGestureRecognizer:pan];
    [self.view addSubview:_petTokenView];
    _petHomeCenter = _petTokenView.center;
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
    _petTokenAvatar.speciesIdentifier = _gameState.pet.speciesIdentifier;
    _petTokenAvatar.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    _petTokenAvatar.equippedAccessories = _gameState.equippedAccessories;
    [self refreshLocationButtons];
}

- (void)refreshLocationButtons {
    NSString *location = [[_gameState currentNeighborRequest] objectForKey:@"location"];
    NSArray *locations = [NSArray arrayWithObjects:@"home", @"school", @"park", @"square", nil];
    NSUInteger index = 0;
    for (index = 0; index < [_locationButtons count]; index++) {
        UIButton *button = [_locationButtons objectAtIndex:index];
        NSArray *titleParts = [[button titleForState:UIControlStateNormal] componentsSeparatedByString:@"\n★ İstek burada!"];
        NSString *baseTitle = [titleParts objectAtIndex:0];
        BOOL marked = [[locations objectAtIndex:index] isEqualToString:location];
        BOOL dragOver = button.tag == _dragTargetTag;
        UIColor *borderColor = dragOver ? [UIColor whiteColor] : (marked ? [UIColor colorWithRed:1.0f green:0.80f blue:0.18f alpha:1.0f] : [UIColor colorWithWhite:1.0f alpha:0.94f]);
        button.layer.borderColor = borderColor.CGColor;
        button.layer.borderWidth = dragOver ? 9.0f : (marked ? 7.0f : 4.0f);
        button.transform = dragOver ? CGAffineTransformMakeScale(1.04f, 1.04f) : CGAffineTransformIdentity;
        if (marked) [button setTitle:[baseTitle stringByAppendingString:@"\n★ İstek burada!"] forState:UIControlStateNormal];
        else [button setTitle:baseTitle forState:UIControlStateNormal];
    }
}

- (void)locationTapped:(UIButton *)sender {
    if (_openingDestination) return;
    [self openLocationTag:sender.tag];
}

- (UIButton *)buttonForLocationTag:(NSInteger)tag {
    NSUInteger index = 0;
    for (index = 0; index < [_locationButtons count]; index++) {
        UIButton *button = [_locationButtons objectAtIndex:index];
        if (button.tag == tag) return button;
    }
    return nil;
}

- (NSInteger)locationTagAtPoint:(CGPoint)point {
    NSUInteger index = 0;
    for (index = 0; index < [_locationButtons count]; index++) {
        UIButton *button = [_locationButtons objectAtIndex:index];
        if (CGRectContainsPoint(button.frame, point)) return button.tag;
    }
    return -1;
}

- (void)petTokenPanned:(UIPanGestureRecognizer *)recognizer {
    if (_openingDestination) return;
    CGPoint point = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self stopPetIdleAnimation];
        _petTokenView.transform = CGAffineTransformMakeScale(1.07f, 1.07f);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat x = MIN(MAX(point.x, 58.0f), self.view.bounds.size.width - 58.0f);
        CGFloat y = MIN(MAX(point.y, 78.0f), 526.0f);
        _petTokenView.center = CGPointMake(x, y);
        NSInteger targetTag = [self locationTagAtPoint:point];
        if (_dragTargetTag != targetTag) {
            _dragTargetTag = targetTag;
            [self refreshLocationButtons];
        }
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        NSInteger destinationTag = [self locationTagAtPoint:point];
        _dragTargetTag = -1;
        [self refreshLocationButtons];
        if (destinationTag < 0) {
            [self returnPetTokenHome];
            return;
        }
        UIButton *button = [self buttonForLocationTag:destinationTag];
        _pendingDestinationTag = destinationTag;
        _openingDestination = YES;
        [UIView beginAnimations:@"mapPetDrop" context:nil];
        [UIView setAnimationDuration:0.24f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _petTokenView.center = button.center;
        _petTokenView.transform = CGAffineTransformMakeScale(0.78f, 0.78f);
        _petTokenView.alpha = 0.82f;
        [UIView commitAnimations];
        [self performSelector:@selector(openPendingLocation) withObject:nil afterDelay:0.26f];
    }
}

- (void)returnPetTokenHome {
    [UIView beginAnimations:@"mapPetReturn" context:nil];
    [UIView setAnimationDuration:0.26f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _petTokenView.center = _petHomeCenter;
    _petTokenView.transform = CGAffineTransformIdentity;
    _petTokenView.alpha = 1.0f;
    [UIView commitAnimations];
    [self performSelector:@selector(startPetIdleAnimation) withObject:nil afterDelay:0.28f];
}

- (void)openPendingLocation {
    NSInteger tag = _pendingDestinationTag;
    _pendingDestinationTag = -1;
    _openingDestination = NO;
    _petTokenView.center = _petHomeCenter;
    _petTokenView.transform = CGAffineTransformIdentity;
    _petTokenView.alpha = 1.0f;
    [self openLocationTag:tag];
}

- (void)openLocationTag:(NSInteger)tag {
    UIViewController *controller = nil;
    if (tag == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    if (tag == 1) controller = [[[PKSkillsViewController alloc] initWithGameState:_gameState] autorelease];
    else if (tag == 2) controller = [[[PKParkViewController alloc] initWithGameState:_gameState] autorelease];
    else controller = [[[PKTownViewController alloc] initWithGameState:_gameState] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)startAmbientAnimations {
    if ([_ambientViews count] < 3) return;
    [self stopAmbientAnimations];
    UIView *flag = [_ambientViews objectAtIndex:0];
    UIView *tree = [_ambientViews objectAtIndex:1];
    UIView *lantern = [_ambientViews objectAtIndex:2];
    [UIView beginAnimations:@"mapFlagSway" context:nil];
    [UIView setAnimationDuration:1.35f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    flag.transform = CGAffineTransformMakeRotation(0.065f);
    [UIView commitAnimations];
    [UIView beginAnimations:@"mapTreeSway" context:nil];
    [UIView setAnimationDuration:1.90f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    tree.transform = CGAffineTransformMakeRotation(-0.035f);
    [UIView commitAnimations];
    [UIView beginAnimations:@"mapLanternGlow" context:nil];
    [UIView setAnimationDuration:1.20f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    lantern.alpha = 0.52f;
    lantern.transform = CGAffineTransformMakeScale(0.92f, 0.92f);
    [UIView commitAnimations];
}

- (void)stopAmbientAnimations {
    NSUInteger index = 0;
    for (index = 0; index < [_ambientViews count]; index++) {
        UIView *view = [_ambientViews objectAtIndex:index];
        [view.layer removeAllAnimations];
        view.transform = CGAffineTransformIdentity;
        view.alpha = 1.0f;
    }
}

- (void)startPetIdleAnimation {
    if (_openingDestination) return;
    [self stopPetIdleAnimation];
    [UIView beginAnimations:@"mapPetIdle" context:nil];
    [UIView setAnimationDuration:1.55f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationRepeatCount:FLT_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    _petTokenView.transform = CGAffineTransformMakeTranslation(0.0f, -5.0f);
    [UIView commitAnimations];
}

- (void)stopPetIdleAnimation {
    [_petTokenView.layer removeAllAnimations];
    _petTokenView.transform = CGAffineTransformIdentity;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _openingDestination = NO;
    _pendingDestinationTag = -1;
    _dragTargetTag = -1;
    _petTokenView.center = _petHomeCenter;
    _petTokenView.alpha = 1.0f;
    [self refreshUI];
    [self startAmbientAnimations];
    [self startPetIdleAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopAmbientAnimations];
    [self stopPetIdleAnimation];
}

- (void)dealloc {
    [_gameState release];
    [_mapView release];
    [_statusLabel release];
    [_requestLabel release];
    [_locationButtons release];
    [_ambientViews release];
    [_petTokenAvatar release];
    [_petTokenView release];
    [super dealloc];
}

@end
