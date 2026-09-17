#import "PKRoomPlayViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKCatalog.h"
#import "PKRoomBackgroundView.h"
#import "PKPetAvatarView.h"
#import "PKActionPropView.h"
#import "PKThoughtBubbleView.h"
#import "PKDecorViewController.h"
#import "PKTheme.h"
#import "PKSoundManager.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKRoomPlayViewController ()
- (void)refreshUI;
- (void)performRoomInteractionIdentifier:(NSString *)identifier;
- (NSString *)compactFeedbackFromMessage:(NSString *)message;
- (NSString *)iconIdentifierForAction:(NSString *)identifier;
- (NSString *)reactionIdentifierForAction:(NSString *)identifier;
- (void)showThoughtText:(NSString *)text iconIdentifier:(NSString *)iconIdentifier;
- (void)showDefaultThought;
- (void)beginRoomVisualAction:(NSString *)identifier sourceIdentifier:(NSString *)sourceIdentifier;
- (void)roomVisualSecondStep;
- (void)finishRoomVisualAction;
- (void)setRoomInteractionsEnabled:(BOOL)enabled;
- (CGPoint)petTargetForItemIdentifier:(NSString *)identifier fallback:(CGPoint)fallback;
- (void)runAutonomousMoment;
- (void)finishAutonomousMoment;
- (void)completeAutonomousReturn;
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

    _feedbackLabel = [[self labelWithFrame:CGRectMake(30.0f, 14.0f, 560.0f, 58.0f) text:@"Eşyaya dokun veya yavrunu eşyanın üzerine bırak." fontSize:17.0f bold:YES] retain];
    _feedbackLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.90f];
    _feedbackLabel.layer.cornerRadius = 14.0f;
    _feedbackLabel.clipsToBounds = YES;
    [self.view addSubview:_feedbackLabel];

    _thoughtBubbleView = [[PKThoughtBubbleView alloc] initWithFrame:CGRectMake(310.0f, 76.0f, 404.0f, 108.0f) text:@"" iconIdentifier:@"happy"];
    [self.view addSubview:_thoughtBubbleView];

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

    _effectPropView = [[PKActionPropView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 104.0f, 78.0f) propIdentifier:@"ball"];
    _effectPropView.userInteractionEnabled = NO;
    _effectPropView.hidden = YES;
    [self.view addSubview:_effectPropView];
    [self refreshUI];
}

- (void)refreshUI {
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], (long)_gameState.coins];
    _roomView.placedItems = _gameState.placedItemIdentifiers;
    _roomView.dayPart = [_gameState dayPartDisplayName];
    _roomView.season = [_gameState seasonDisplayName];
    _avatarView.lifeStageIdentifier = [_gameState.pet lifeStageIdentifier];
    _avatarView.equippedAccessories = _gameState.equippedAccessories;
    if ([_activeVisualActionIdentifier length] == 0) [self showDefaultThought];
}

- (NSString *)compactFeedbackFromMessage:(NSString *)message {
    if ([message length] == 0) return @"";
    NSRange lineBreak = [message rangeOfString:@"\n"];
    if (lineBreak.location == NSNotFound) return message;
    return [message substringToIndex:lineBreak.location];
}

- (NSString *)iconIdentifierForAction:(NSString *)identifier {
    if ([identifier isEqualToString:@"feed"]) return @"food";
    if ([identifier isEqualToString:@"nature"] || [identifier isEqualToString:@"logic"]) return @"curious";
    if ([identifier isEqualToString:@"art"]) return @"play";
    if ([identifier isEqualToString:@"touch"]) return @"cuddle";
    return identifier;
}

- (NSString *)reactionIdentifierForAction:(NSString *)identifier {
    if ([identifier isEqualToString:@"nature"] || [identifier isEqualToString:@"logic"]) return @"curious";
    if ([identifier isEqualToString:@"art"]) return @"play";
    if ([identifier isEqualToString:@"touch"]) return @"cuddle";
    return identifier;
}

- (void)showThoughtText:(NSString *)text iconIdentifier:(NSString *)iconIdentifier {
    _thoughtBubbleView.text = text;
    _thoughtBubbleView.iconIdentifier = iconIdentifier;
}

- (void)showDefaultThought {
    if ([_activeVisualActionIdentifier length] > 0 || !_gameState.pet) return;
    PKPet *pet = _gameState.pet;
    NSString *icon = @"happy";
    NSInteger lowest = pet.satiety;
    if (pet.satiety < 35) icon = @"food";
    if (pet.energy < lowest) { lowest = pet.energy; icon = @"sleep"; }
    if (pet.hygiene < lowest) { lowest = pet.hygiene; icon = @"clean"; }
    if (pet.fun < lowest) { lowest = pet.fun; icon = @"play"; }
    if (pet.social < lowest) { lowest = pet.social; icon = @"social"; }
    if (pet.affection < lowest) icon = @"cuddle";
    [self showThoughtText:[pet moodText] iconIdentifier:icon];
}

- (void)roomTapped:(UITapGestureRecognizer *)recognizer {
    if ([_activeVisualActionIdentifier length] > 0) return;
    CGPoint point = [recognizer locationInView:_roomView];
    NSString *identifier = [_roomView itemIdentifierAtPoint:point];
    if (!identifier) {
        _feedbackLabel.text = @"Yavrunu görünür bir eşyanın üzerine bırak.";
        [self showThoughtText:@"Hangi eşyayla oynasak?" iconIdentifier:@"curious"];
        return;
    }
    [self performRoomInteractionIdentifier:identifier];
}

- (void)performRoomInteractionIdentifier:(NSString *)identifier {
    if ([_activeVisualActionIdentifier length] > 0 || [identifier length] == 0) return;
    NSDictionary *item = [PKCatalog itemForIdentifier:identifier];
    NSInteger previousActionCount = _gameState.actionCount;
    NSString *message = [_gameState interactWithPlacedItemIdentifier:identifier];
    BOOL completed = (_gameState.actionCount != previousActionCount);
    _feedbackLabel.text = [self compactFeedbackFromMessage:message];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];

    NSString *action = [item objectForKey:@"action"];
    if ([action length] == 0) action = [item objectForKey:@"skill"];
    if ([action length] == 0 && [identifier isEqualToString:@"rug"]) action = @"cuddle";
    if ([action length] == 0) action = @"play";

    if (completed) {
        _pendingAutonomousMoment = ((_gameState.actionCount % 3) == 0);
        [self beginRoomVisualAction:action sourceIdentifier:identifier];
    } else {
        [self showThoughtText:[self compactFeedbackFromMessage:message] iconIdentifier:[self iconIdentifierForAction:action]];
        [self returnAvatarHome];
    }
}

- (void)setRoomInteractionsEnabled:(BOOL)enabled {
    _roomView.userInteractionEnabled = enabled;
    _avatarView.userInteractionEnabled = enabled;
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (CGPoint)petTargetForItemIdentifier:(NSString *)identifier fallback:(CGPoint)fallback {
    if ([identifier length] == 0 || ![_gameState isItemPlaced:identifier]) return fallback;
    CGRect frame = [_roomView frameForItemIdentifier:identifier];
    if (CGRectIsEmpty(frame)) return fallback;
    CGPoint center = [_roomView convertPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame)) toView:self.view];
    center.y -= 58.0f;
    center.x = MIN(MAX(center.x, 185.0f), self.view.bounds.size.width - 185.0f);
    center.y = MIN(MAX(center.y, 260.0f), 495.0f);
    return center;
}

- (void)beginRoomVisualAction:(NSString *)identifier sourceIdentifier:(NSString *)sourceIdentifier {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(roomVisualSecondStep) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRoomVisualAction) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runAutonomousMoment) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
    [self stopAvatarIdleAnimation];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = [identifier copy];
    [_activeRoomItemIdentifier release];
    _activeRoomItemIdentifier = [sourceIdentifier copy];
    [self setRoomInteractionsEnabled:NO];

    NSString *reaction = [self reactionIdentifierForAction:identifier];
    _avatarView.reactionIdentifier = reaction;
    _effectPropView.hidden = YES;
    _effectPropView.alpha = 1.0f;
    _effectPropView.depleted = NO;
    _effectPropView.transform = CGAffineTransformIdentity;

    NSString *thought = @"Bunu keşfedelim!";
    if ([identifier isEqualToString:@"feed"]) thought = @"Mmm, mama zamanı!";
    else if ([identifier isEqualToString:@"play"]) thought = @"Topu yakalıyorum!";
    else if ([identifier isEqualToString:@"sleep"]) thought = @"Yatağım çok rahat...";
    else if ([identifier isEqualToString:@"clean"]) thought = @"Fırçalanmak güzel!";
    else if ([identifier isEqualToString:@"cuddle"]) thought = @"Birlikte dinlenelim!";
    else if ([identifier isEqualToString:@"music"]) thought = @"Bir melodi buldum!";
    else if ([identifier isEqualToString:@"art"]) thought = @"Renkleri karıştırıyorum!";
    else if ([identifier isEqualToString:@"nature"]) thought = @"Yaprakları inceliyorum!";
    else if ([identifier isEqualToString:@"logic"]) thought = @"Bunu çözebilirim!";
    [self showThoughtText:thought iconIdentifier:[self iconIdentifierForAction:identifier]];

    if ([identifier isEqualToString:@"play"]) [PKSoundManager playEffectNamed:@"ball" enabled:_gameState.soundEnabled];
    else if ([identifier isEqualToString:@"sleep"]) [PKSoundManager playEffectNamed:@"sleep" enabled:_gameState.soundEnabled];
    else if ([identifier isEqualToString:@"clean"]) [PKSoundManager playEffectNamed:@"bubble" enabled:_gameState.soundEnabled];
    else if ([identifier isEqualToString:@"cuddle"]) [PKSoundManager playEffectNamed:@"laugh" enabled:_gameState.soundEnabled];

    CGRect itemFrame = [_roomView frameForItemIdentifier:sourceIdentifier];
    CGPoint itemCenter = [_roomView convertPoint:CGPointMake(CGRectGetMidX(itemFrame), CGRectGetMidY(itemFrame)) toView:self.view];
    CGPoint petTarget = [self petTargetForItemIdentifier:sourceIdentifier fallback:_avatarHomeCenter];

    if ([identifier isEqualToString:@"feed"]) {
        _effectPropView.propIdentifier = @"food_kibble";
        _effectPropView.center = itemCenter;
        _effectPropView.hidden = NO;
        [self.view bringSubviewToFront:_effectPropView];
        [UIView beginAnimations:@"roomPetToBowl" context:nil];
        [UIView setAnimationDuration:0.36f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _avatarMotionView.center = petTarget;
        _avatarMotionView.transform = CGAffineTransformMakeScale(0.78f, 0.74f);
        _effectPropView.center = CGPointMake(petTarget.x + 48.0f, petTarget.y + 48.0f);
        _effectPropView.transform = CGAffineTransformMakeScale(0.78f, 0.78f);
        [UIView commitAnimations];
        [self performSelector:@selector(roomVisualSecondStep) withObject:nil afterDelay:0.40f];
        [self performSelector:@selector(finishRoomVisualAction) withObject:nil afterDelay:1.24f];
    } else if ([identifier isEqualToString:@"play"]) {
        _effectPropView.propIdentifier = @"ball";
        _effectPropView.center = itemCenter;
        _effectPropView.hidden = NO;
        [self.view bringSubviewToFront:_effectPropView];
        CGFloat direction = itemCenter.x > (self.view.bounds.size.width * 0.5f) ? -1.0f : 1.0f;
        CGPoint ballTarget = CGPointMake(MIN(MAX(itemCenter.x + (direction * 190.0f), 85.0f), self.view.bounds.size.width - 85.0f), MIN(itemCenter.y, 585.0f));
        [UIView beginAnimations:@"roomBallRollOut" context:nil];
        [UIView setAnimationDuration:0.38f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _effectPropView.center = ballTarget;
        _effectPropView.transform = CGAffineTransformMakeRotation(direction * 3.1f);
        _avatarMotionView.center = CGPointMake(MIN(MAX(ballTarget.x - (direction * 55.0f), 185.0f), self.view.bounds.size.width - 185.0f), petTarget.y);
        _avatarMotionView.transform = CGAffineTransformMakeScale(0.84f, 0.84f);
        [UIView commitAnimations];
        [self performSelector:@selector(roomVisualSecondStep) withObject:nil afterDelay:0.42f];
        [self performSelector:@selector(finishRoomVisualAction) withObject:nil afterDelay:1.18f];
    } else if ([identifier isEqualToString:@"sleep"]) {
        [UIView beginAnimations:@"roomPetIntoBed" context:nil];
        [UIView setAnimationDuration:0.40f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _avatarMotionView.center = petTarget;
        _avatarMotionView.transform = CGAffineTransformMakeScale(0.72f, 0.62f);
        [UIView commitAnimations];
        [self performSelector:@selector(finishRoomVisualAction) withObject:nil afterDelay:1.42f];
    } else if ([identifier isEqualToString:@"clean"]) {
        _effectPropView.propIdentifier = @"brush";
        _effectPropView.center = CGPointMake(_avatarHomeCenter.x + 155.0f, _avatarHomeCenter.y - 75.0f);
        _effectPropView.hidden = NO;
        [self.view bringSubviewToFront:_effectPropView];
        [UIView beginAnimations:@"roomBrushPet" context:nil];
        [UIView setAnimationDuration:0.24f];
        _effectPropView.center = CGPointMake(_avatarMotionView.center.x + 52.0f, _avatarMotionView.center.y - 26.0f);
        _effectPropView.transform = CGAffineTransformMakeRotation(0.38f);
        [UIView commitAnimations];
        [UIView beginAnimations:@"roomPetCleanShake" context:nil];
        [UIView setAnimationDuration:0.11f];
        [UIView setAnimationRepeatCount:3.0f];
        [UIView setAnimationRepeatAutoreverses:YES];
        _avatarView.transform = CGAffineTransformMakeRotation(0.065f);
        [UIView commitAnimations];
        [self performSelector:@selector(finishRoomVisualAction) withObject:nil afterDelay:1.02f];
    } else if ([identifier isEqualToString:@"cuddle"]) {
        [UIView beginAnimations:@"roomPetCuddleRug" context:nil];
        [UIView setAnimationDuration:0.32f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _avatarMotionView.center = petTarget;
        _avatarMotionView.transform = CGAffineTransformMakeScale(1.10f, 1.10f);
        [UIView commitAnimations];
        [self performSelector:@selector(finishRoomVisualAction) withObject:nil afterDelay:1.08f];
    } else {
        [UIView beginAnimations:@"roomPetUsesSkillObject" context:nil];
        [UIView setAnimationDuration:0.37f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _avatarMotionView.center = petTarget;
        _avatarMotionView.transform = CGAffineTransformMakeScale(0.84f, 0.84f);
        [UIView commitAnimations];
        [UIView beginAnimations:@"roomPetSkillBounce" context:nil];
        [UIView setAnimationDelay:0.39f];
        [UIView setAnimationDuration:0.17f];
        [UIView setAnimationRepeatCount:2.0f];
        [UIView setAnimationRepeatAutoreverses:YES];
        _avatarView.transform = CGAffineTransformMakeTranslation(0.0f, -12.0f);
        [UIView commitAnimations];
        [self performSelector:@selector(finishRoomVisualAction) withObject:nil afterDelay:1.24f];
    }
}

- (void)roomVisualSecondStep {
    if ([_activeVisualActionIdentifier isEqualToString:@"feed"]) {
        [PKSoundManager playEffectNamed:@"eat" enabled:_gameState.soundEnabled];
        _effectPropView.depleted = YES;
        [UIView beginAnimations:@"roomFoodEaten" context:nil];
        [UIView setAnimationDuration:0.25f];
        _effectPropView.alpha = 0.35f;
        _effectPropView.transform = CGAffineTransformMakeScale(0.58f, 0.58f);
        _avatarView.transform = CGAffineTransformMakeTranslation(0.0f, 7.0f);
        [UIView commitAnimations];
    } else if ([_activeVisualActionIdentifier isEqualToString:@"play"]) {
        CGRect itemFrame = [_roomView frameForItemIdentifier:_activeRoomItemIdentifier];
        CGPoint itemCenter = [_roomView convertPoint:CGPointMake(CGRectGetMidX(itemFrame), CGRectGetMidY(itemFrame)) toView:self.view];
        CGPoint petTarget = [self petTargetForItemIdentifier:_activeRoomItemIdentifier fallback:_avatarHomeCenter];
        [UIView beginAnimations:@"roomBallRollHome" context:nil];
        [UIView setAnimationDuration:0.38f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _effectPropView.center = itemCenter;
        _effectPropView.transform = CGAffineTransformMakeRotation(-3.1f);
        _avatarMotionView.center = petTarget;
        [UIView commitAnimations];
    }
}

- (void)finishRoomVisualAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(roomVisualSecondStep) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishRoomVisualAction) object:nil];
    [_avatarView.layer removeAllAnimations];
    [_effectPropView.layer removeAllAnimations];
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
    _effectPropView.hidden = YES;
    _effectPropView.alpha = 1.0f;
    _effectPropView.depleted = NO;
    _effectPropView.transform = CGAffineTransformIdentity;
    [UIView beginAnimations:@"roomCareReturn" context:nil];
    [UIView setAnimationDuration:0.29f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [_activeRoomItemIdentifier release];
    _activeRoomItemIdentifier = nil;
    if (_pendingAutonomousMoment) {
        [self performSelector:@selector(runAutonomousMoment) withObject:nil afterDelay:0.43f];
    } else {
        [self setRoomInteractionsEnabled:YES];
        [self performSelector:@selector(showDefaultThought) withObject:nil afterDelay:0.31f];
        [self performSelector:@selector(startAvatarIdleAnimation) withObject:nil afterDelay:0.32f];
    }
}

- (void)avatarPanned:(UIPanGestureRecognizer *)recognizer {
    if ([_activeVisualActionIdentifier length] > 0) return;
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
        if ([identifier length] > 0) {
            [self performRoomInteractionIdentifier:identifier];
        } else {
            [self returnAvatarHome];
            _feedbackLabel.text = @"Yavrunu yatağın, mama kabının, topun veya başka bir eşyanın üzerine bırak.";
            [self showThoughtText:@"Beni bir eşyaya götür." iconIdentifier:@"curious"];
        }
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
    if ([_activeVisualActionIdentifier length] > 0) return;
    NSInteger previousActionCount = _gameState.actionCount;
    NSString *message = [_gameState performActionIdentifier:@"cuddle"];
    BOOL completed = (_gameState.actionCount != previousActionCount);
    _feedbackLabel.text = [self compactFeedbackFromMessage:message];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
    if (completed) {
        _pendingAutonomousMoment = ((_gameState.actionCount % 3) == 0);
        NSString *source = [_gameState isItemPlaced:@"rug"] ? @"rug" : nil;
        [self beginRoomVisualAction:@"cuddle" sourceIdentifier:source];
    } else {
        [self showThoughtText:[self compactFeedbackFromMessage:message] iconIdentifier:@"cuddle"];
    }
}

- (void)runAutonomousMoment {
    if (!_pendingAutonomousMoment || [_activeVisualActionIdentifier length] > 0) return;
    _pendingAutonomousMoment = NO;
    [self stopAvatarIdleAnimation];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = [@"autonomous" copy];
    [self setRoomInteractionsEnabled:NO];

    NSString *personality = _gameState.pet.personalityIdentifier;
    NSString *reaction = @"play";
    NSString *icon = @"play";
    NSString *thought = @"Topumla biraz oynadım!";
    NSString *targetItem = [_gameState isItemPlaced:@"ball"] ? @"ball" : nil;
    CGPoint fallback = CGPointMake(650.0f, 455.0f);
    if ([personality isEqualToString:@"curious"]) {
        reaction = @"curious"; icon = @"curious"; thought = @"Pencerede bir kuş var!"; targetItem = nil; fallback = CGPointMake(260.0f, 280.0f);
    } else if ([personality isEqualToString:@"sleepy"]) {
        reaction = @"sleep"; icon = @"sleep"; thought = @"Biraz kestireceğim."; targetItem = [_gameState isItemPlaced:@"bed"] ? @"bed" : nil; fallback = CGPointMake(250.0f, 470.0f);
    } else if ([personality isEqualToString:@"social"]) {
        reaction = @"cuddle"; icon = @"social"; thought = @"Yanında olmak güzel!"; targetItem = [_gameState isItemPlaced:@"rug"] ? @"rug" : nil; fallback = CGPointMake(505.0f, 470.0f);
    } else if ([personality isEqualToString:@"musical"]) {
        reaction = @"music"; icon = @"music"; thought = @"Kendi şarkımı söylüyorum!"; targetItem = [_gameState isItemPlaced:@"piano"] ? @"piano" : nil; fallback = CGPointMake(280.0f, 390.0f);
    }
    _avatarView.reactionIdentifier = reaction;
    [self showThoughtText:thought iconIdentifier:icon];
    CGPoint target = [self petTargetForItemIdentifier:targetItem fallback:fallback];
    [UIView beginAnimations:@"roomAutonomousMoment" context:nil];
    [UIView setAnimationDuration:0.40f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = target;
    _avatarMotionView.transform = [reaction isEqualToString:@"sleep"] ? CGAffineTransformMakeScale(0.74f, 0.64f) : CGAffineTransformMakeScale(0.86f, 0.86f);
    [UIView commitAnimations];
    [self performSelector:@selector(finishAutonomousMoment) withObject:nil afterDelay:1.12f];
}

- (void)finishAutonomousMoment {
    [UIView beginAnimations:@"roomAutonomousReturn" context:nil];
    [UIView setAnimationDuration:0.30f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [self performSelector:@selector(completeAutonomousReturn) withObject:nil afterDelay:0.32f];
}

- (void)completeAutonomousReturn {
    _avatarView.reactionIdentifier = @"";
    _avatarView.transform = CGAffineTransformIdentity;
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [self setRoomInteractionsEnabled:YES];
    [self showDefaultThought];
    [self startAvatarIdleAnimation];
}

- (void)startAvatarIdleAnimation {
    if ([_activeVisualActionIdentifier length] > 0) return;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [_activeRoomItemIdentifier release];
    _activeRoomItemIdentifier = nil;
    _pendingAutonomousMoment = NO;
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
    _effectPropView.hidden = YES;
    _effectPropView.alpha = 1.0f;
    _effectPropView.depleted = NO;
    _effectPropView.transform = CGAffineTransformIdentity;
    _roomView.highlightedItemIdentifier = nil;
    [self setRoomInteractionsEnabled:YES];
    [self refreshUI];
    [self startAvatarIdleAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopAvatarIdleAnimation];
    [_avatarView.layer removeAllAnimations];
    [_effectPropView.layer removeAllAnimations];
    [_gameState save];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_gameState release];
    [_roomView release];
    [_avatarMotionView release];
    [_avatarView release];
    [_effectPropView release];
    [_thoughtBubbleView release];
    [_dragItemIdentifier release];
    [_activeVisualActionIdentifier release];
    [_activeRoomItemIdentifier release];
    [_statusLabel release];
    [_feedbackLabel release];
    [super dealloc];
}

@end
