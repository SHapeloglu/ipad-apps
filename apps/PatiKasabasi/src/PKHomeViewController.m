#import "PKHomeViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKPetAvatarView.h"
#import "PKNeedBarView.h"
#import "PKRoomBackgroundView.h"
#import "PKActionPropView.h"
#import "PKThoughtBubbleView.h"
#import "PKTownMapViewController.h"
#import "PKRoomPlayViewController.h"
#import "PKWardrobeViewController.h"
#import "PKSkillsViewController.h"
#import "PKMiniGamesViewController.h"
#import "PKAlbumViewController.h"
#import "PKSoundManager.h"
#import "PKVoiceRepeatManager.h"
#import "PKAppDelegate.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKHomeViewController ()
- (NSArray *)actionIdentifiers;
- (void)refreshUI;
- (void)performActionIdentifier:(NSString *)identifier;
- (void)performActionIdentifier:(NSString *)identifier usingPropView:(PKActionPropView *)propView;
- (NSString *)compactFeedbackFromMessage:(NSString *)message;
- (void)showDefaultThought;
- (void)showThoughtText:(NSString *)text iconIdentifier:(NSString *)iconIdentifier;
- (void)beginVisualAction:(NSString *)identifier usingPropView:(PKActionPropView *)propView;
- (void)consumeFoodStep;
- (void)rollBallBackStep;
- (void)finishVisualAction;
- (PKActionPropView *)propViewForActionIdentifier:(NSString *)identifier;
- (void)propPanned:(UIPanGestureRecognizer *)recognizer;
- (void)propTapped:(UITapGestureRecognizer *)recognizer;
- (BOOL)isPointOverAvatar:(CGPoint)point;
- (void)returnPropViewHome:(PKActionPropView *)propView;
- (void)setCareInteractionsEnabled:(BOOL)enabled;
- (void)foodChoiceTapped:(UIButton *)sender;
- (void)refreshFoodChoiceButtons;
- (void)performTouchReactionIdentifier:(NSString *)identifier;
- (void)finishTouchReaction;
- (void)runMicroReaction;
- (void)finishMicroReaction;
- (void)voiceTapped:(id)sender;
- (void)finishVoiceRecording;
- (void)finishVoicePlayback;
- (void)runAutonomousMoment;
- (void)finishAutonomousMoment;
- (void)completeAutonomousReturn;
- (void)startAvatarIdleAnimation;
- (void)stopAvatarIdleAnimation;
- (NSInteger)actionIndexAtPoint:(CGPoint)point;
- (void)refreshActionHighlight;
- (void)returnAvatarHome;
- (void)cleanupUnreferencedPhotosInFolder:(NSString *)folder;
@end

@implementation PKHomeViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        _dragActionIndex = -1;
        _selectedFoodIdentifier = [@"food_kibble" copy];
        _voiceManager = [[PKVoiceRepeatManager alloc] init];
        self.title = @"Evimiz";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _roomView = [[PKRoomBackgroundView alloc] initWithFrame:self.view.bounds];
    _roomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_roomView];

    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Ana Menü" style:UIBarButtonItemStyleBordered target:self action:@selector(menuTapped:)];
    self.navigationItem.leftBarButtonItem = menuItem;
    [menuItem release];
    _soundButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(soundTapped:)];
    _voiceButton = [[UIBarButtonItem alloc] initWithTitle:@"Konuş" style:UIBarButtonItemStyleBordered target:self action:@selector(voiceTapped:)];
    UIBarButtonItem *photoButton = [[UIBarButtonItem alloc] initWithTitle:@"Fotoğraf" style:UIBarButtonItemStyleBordered target:self action:@selector(photoTapped:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_voiceButton, _soundButton, photoButton, nil];
    [photoButton release];

    UILabel *status = [self labelWithFrame:CGRectMake(350.0f, 8.0f, 330.0f, 38.0f) text:@"" fontSize:17.0f bold:YES];
    status.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.82f];
    status.layer.cornerRadius = 16.0f;
    status.clipsToBounds = YES;
    _statusLabel = [status retain];
    [self.view addSubview:status];

    UIView *profilePanel = [[[UIView alloc] initWithFrame:CGRectMake(25.0f, 20.0f, 280.0f, 130.0f)] autorelease];
    [PKTheme stylePanel:profilePanel];
    [self.view addSubview:profilePanel];
    _nameLabel = [[self labelWithFrame:CGRectMake(15.0f, 12.0f, 250.0f, 42.0f) text:@"" fontSize:28.0f bold:YES] retain];
    _nameLabel.textColor = [PKTheme darkTealColor];
    [profilePanel addSubview:_nameLabel];
    _profileLabel = [[self labelWithFrame:CGRectMake(15.0f, 53.0f, 250.0f, 67.0f) text:@"" fontSize:15.0f bold:NO] retain];
    [profilePanel addSubview:_profileLabel];

    _thoughtBubbleView = [[PKThoughtBubbleView alloc] initWithFrame:CGRectMake(292.0f, 50.0f, 340.0f, 105.0f) text:@"" iconIdentifier:@"happy"];
    [self.view addSubview:_thoughtBubbleView];

    _propPaletteView = [[UIView alloc] initWithFrame:CGRectMake(24.0f, 158.0f, 188.0f, 362.0f)];
    [PKTheme stylePanel:_propPaletteView];
    _propPaletteView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.82f];
    UILabel *propTitle = [self labelWithFrame:CGRectMake(8.0f, 3.0f, 172.0f, 26.0f) text:@"Mama seç ve sürükle" fontSize:15.0f bold:YES];
    propTitle.textColor = [PKTheme darkTealColor];
    [_propPaletteView addSubview:propTitle];
    NSArray *foodTitles = [NSArray arrayWithObjects:@"Mama", @"Balık", @"Havuç", @"Kurabiye", nil];
    NSMutableArray *foodButtons = [NSMutableArray array];
    NSUInteger foodIndex = 0;
    for (foodIndex = 0; foodIndex < [foodTitles count]; foodIndex++) {
        CGFloat foodX = (foodIndex % 2) == 0 ? 8.0f : 96.0f;
        CGFloat foodY = foodIndex < 2 ? 31.0f : 60.0f;
        UIButton *foodButton = [self secondaryButtonWithFrame:CGRectMake(foodX, foodY, 84.0f, 25.0f) title:[foodTitles objectAtIndex:foodIndex]];
        foodButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        foodButton.tag = 700 + (NSInteger)foodIndex;
        [foodButton addTarget:self action:@selector(foodChoiceTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_propPaletteView addSubview:foodButton];
        [foodButtons addObject:foodButton];
    }
    _foodChoiceButtons = [[NSArray alloc] initWithArray:foodButtons];
    NSArray *propIdentifiers = [NSArray arrayWithObjects:@"food_kibble", @"ball", @"brush", nil];
    NSMutableArray *propViews = [NSMutableArray array];
    NSUInteger propIndex = 0;
    for (propIndex = 0; propIndex < [propIdentifiers count]; propIndex++) {
        PKActionPropView *propView = [[[PKActionPropView alloc] initWithFrame:CGRectMake(24.0f, 92.0f + ((CGFloat)propIndex * 84.0f), 140.0f, 72.0f) propIdentifier:[propIdentifiers objectAtIndex:propIndex]] autorelease];
        propView.tag = (NSInteger)propIndex;
        propView.userInteractionEnabled = YES;
        UITapGestureRecognizer *propTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(propTapped:)] autorelease];
        [propView addGestureRecognizer:propTap];
        UIPanGestureRecognizer *propPan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(propPanned:)] autorelease];
        [propView addGestureRecognizer:propPan];
        [_propPaletteView addSubview:propView];
        [propViews addObject:propView];
    }
    _propViews = [[NSArray alloc] initWithArray:propViews];
    [self.view addSubview:_propPaletteView];
    for (propIndex = 0; propIndex < [_propViews count]; propIndex++) {
        PKActionPropView *propView = [_propViews objectAtIndex:propIndex];
        _propHomeCenters[propIndex] = propView.center;
    }
    [self refreshFoodChoiceButtons];

    _avatarMotionView = [[UIView alloc] initWithFrame:CGRectMake(220.0f, 150.0f, 360.0f, 370.0f)];
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

    UIView *needsPanel = [[[UIView alloc] initWithFrame:CGRectMake(650.0f, 25.0f, 350.0f, 365.0f)] autorelease];
    [PKTheme stylePanel:needsPanel];
    [self.view addSubview:needsPanel];
    UILabel *needsTitle = [self labelWithFrame:CGRectMake(20.0f, 10.0f, 310.0f, 38.0f) text:@"İhtiyaçlar" fontSize:24.0f bold:YES];
    needsTitle.textColor = [PKTheme darkTealColor];
    [needsPanel addSubview:needsTitle];
    _satietyBar = [[PKNeedBarView alloc] initWithFrame:CGRectMake(20.0f, 51.0f, 310.0f, 43.0f) title:@"Tokluk" color:[UIColor colorWithRed:0.94f green:0.58f blue:0.32f alpha:1.0f]];
    _energyBar = [[PKNeedBarView alloc] initWithFrame:CGRectMake(20.0f, 98.0f, 310.0f, 43.0f) title:@"Enerji" color:[UIColor colorWithRed:0.43f green:0.66f blue:0.91f alpha:1.0f]];
    _hygieneBar = [[PKNeedBarView alloc] initWithFrame:CGRectMake(20.0f, 145.0f, 310.0f, 43.0f) title:@"Temizlik" color:[UIColor colorWithRed:0.34f green:0.78f blue:0.82f alpha:1.0f]];
    _funBar = [[PKNeedBarView alloc] initWithFrame:CGRectMake(20.0f, 192.0f, 310.0f, 43.0f) title:@"Eğlence" color:[UIColor colorWithRed:0.88f green:0.48f blue:0.72f alpha:1.0f]];
    _socialBar = [[PKNeedBarView alloc] initWithFrame:CGRectMake(20.0f, 239.0f, 310.0f, 43.0f) title:@"Sosyal" color:[UIColor colorWithRed:0.48f green:0.75f blue:0.48f alpha:1.0f]];
    _affectionBar = [[PKNeedBarView alloc] initWithFrame:CGRectMake(20.0f, 286.0f, 310.0f, 43.0f) title:@"Sevgi" color:[PKTheme coralColor]];
    [needsPanel addSubview:_satietyBar]; [needsPanel addSubview:_energyBar]; [needsPanel addSubview:_hygieneBar];
    [needsPanel addSubview:_funBar]; [needsPanel addSubview:_socialBar]; [needsPanel addSubview:_affectionBar];

    UIView *feedbackPanel = [[[UIView alloc] initWithFrame:CGRectMake(650.0f, 405.0f, 350.0f, 115.0f)] autorelease];
    [PKTheme stylePanel:feedbackPanel];
    [self.view addSubview:feedbackPanel];
    NSString *welcomeMessage = _gameState.newHomeBadge ? @"Yeni Bir Yuva rozetini kazandın!\nMama seç; kabı, topu veya fırçayı sürükle." : @"Hediye oyuncağın hazır!\nMama seç; kabı, topu veya fırçayı sürükle.";
    _feedbackLabel = [[self labelWithFrame:CGRectMake(14.0f, 7.0f, 322.0f, 69.0f) text:welcomeMessage fontSize:16.0f bold:NO] retain];
    [feedbackPanel addSubview:_feedbackLabel];
    _questLabel = [[self labelWithFrame:CGRectMake(12.0f, 77.0f, 326.0f, 31.0f) text:@"" fontSize:14.0f bold:YES] retain];
    _questLabel.textColor = [PKTheme darkTealColor];
    [feedbackPanel addSubview:_questLabel];

    NSArray *destinations = [NSArray arrayWithObjects:@"Harita", @"Odam", @"Dolap", @"Okul", @"Oyunlar", @"Albüm", nil];
    NSUInteger index = 0;
    CGFloat buttonWidth = 145.0f;
    CGFloat gap = 20.0f;
    CGFloat startX = 22.0f;
    for (index = 0; index < [destinations count]; index++) {
        UIButton *button = [self secondaryButtonWithFrame:CGRectMake(startX + ((buttonWidth + gap) * index), 540.0f, buttonWidth, 48.0f) title:[destinations objectAtIndex:index]];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        button.tag = index;
        [button addTarget:self action:@selector(destinationTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }

    NSArray *titles = [NSArray arrayWithObjects:@"Besle", @"Oyna", @"Uyut", @"Temizle", @"Sev", nil];
    CGFloat actionWidth = 178.0f;
    CGFloat actionGap = 18.0f;
    CGFloat actionStartX = 31.0f;
    NSMutableArray *actionButtons = [NSMutableArray array];
    for (index = 0; index < [titles count]; index++) {
        UIButton *button = index == 0 ? [self primaryButtonWithFrame:CGRectMake(actionStartX + ((actionWidth + actionGap) * index), 600.0f, actionWidth, 58.0f) title:[titles objectAtIndex:index]] : [self secondaryButtonWithFrame:CGRectMake(actionStartX + ((actionWidth + actionGap) * index), 600.0f, actionWidth, 58.0f) title:[titles objectAtIndex:index]];
        button.tag = index;
        [button addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [actionButtons addObject:button];
    }
    _actionButtons = [[NSArray alloc] initWithArray:actionButtons];
    [self refreshUI];
}

- (NSArray *)actionIdentifiers { return [NSArray arrayWithObjects:@"feed", @"play", @"sleep", @"clean", @"cuddle", nil]; }

- (void)foodChoiceTapped:(UIButton *)sender {
    if ([_activeVisualActionIdentifier length] > 0) return;
    NSArray *identifiers = [NSArray arrayWithObjects:@"food_kibble", @"food_fish", @"food_carrot", @"food_cookie", nil];
    NSArray *titles = [NSArray arrayWithObjects:@"Mama", @"Balık", @"Havuç", @"Kurabiye", nil];
    NSInteger index = sender.tag - 700;
    if (index < 0 || index >= (NSInteger)[identifiers count]) return;
    [_selectedFoodIdentifier release];
    _selectedFoodIdentifier = [[identifiers objectAtIndex:(NSUInteger)index] copy];
    if ([_propViews count] > 0) {
        PKActionPropView *foodView = [_propViews objectAtIndex:0];
        foodView.propIdentifier = _selectedFoodIdentifier;
    }
    [self refreshFoodChoiceButtons];
    NSString *preference = [_gameState.pet foodPreferenceForIdentifier:_selectedFoodIdentifier];
    NSString *thought = [preference isEqualToString:@"favorite"] ? @"En sevdiğim mama!" : ([preference isEqualToString:@"disliked"] ? @"Bunu pek sevmiyorum..." : @"Bunu tadabilirim!");
    [self showThoughtText:thought iconIdentifier:@"food"];
    _feedbackLabel.text = [NSString stringWithFormat:@"%@ seçildi; kabı yavruna sürükle.", [titles objectAtIndex:(NSUInteger)index]];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
}

- (void)refreshFoodChoiceButtons {
    NSArray *identifiers = [NSArray arrayWithObjects:@"food_kibble", @"food_fish", @"food_carrot", @"food_cookie", nil];
    NSUInteger index = 0;
    for (index = 0; index < [_foodChoiceButtons count]; index++) {
        UIButton *button = [_foodChoiceButtons objectAtIndex:index];
        BOOL selected = [[identifiers objectAtIndex:index] isEqualToString:_selectedFoodIdentifier];
        button.alpha = selected ? 1.0f : 0.72f;
        button.transform = selected ? CGAffineTransformMakeScale(1.05f, 1.05f) : CGAffineTransformIdentity;
        button.accessibilityTraits = UIAccessibilityTraitButton;
        button.accessibilityValue = selected ? @"Seçili" : @"Seçili değil";
    }
}

- (void)refreshUI {
    PKPet *pet = _gameState.pet;
    if (!pet) return;
    _nameLabel.text = pet.name;
    NSString *reward = _gameState.newHomeBadge ? @"Yeni Bir Yuva rozeti" : @"Hediye oyuncak";
    _profileLabel.text = [NSString stringWithFormat:@"%@ • %@ • %@\n%@ • %@", [pet speciesDisplayName], [pet lifeStageDisplayName], [pet personalityDisplayName], [_gameState sourceDisplayName], reward];
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], [_gameState seasonDisplayName], (long)_gameState.coins];
    if ([_activeVisualActionIdentifier length] == 0) [self showDefaultThought];
    _questLabel.text = [_gameState questText];
    _satietyBar.value = pet.satiety; _energyBar.value = pet.energy; _hygieneBar.value = pet.hygiene;
    _funBar.value = pet.fun; _socialBar.value = pet.social; _affectionBar.value = pet.affection;
    NSInteger average = (pet.satiety + pet.energy + pet.hygiene + pet.fun + pet.social + pet.affection) / 6;
    _avatarView.happy = (average >= 45);
    _avatarView.lifeStageIdentifier = [pet lifeStageIdentifier];
    _avatarView.equippedAccessories = _gameState.equippedAccessories;
    _roomView.placedItems = _gameState.placedItemIdentifiers;
    _roomView.dayPart = [_gameState dayPartDisplayName];
    _roomView.season = [_gameState seasonDisplayName];
    _soundButton.title = _gameState.soundEnabled ? @"Ses Açık" : @"Ses Kapalı";
    if (![_voiceManager isRecording]) _voiceButton.enabled = _gameState.soundEnabled && ([_activeVisualActionIdentifier length] == 0);
}

- (void)showThoughtText:(NSString *)text iconIdentifier:(NSString *)iconIdentifier {
    _thoughtBubbleView.text = text;
    _thoughtBubbleView.iconIdentifier = iconIdentifier;
}

- (void)showDefaultThought {
    if ([_activeVisualActionIdentifier length] > 0) return;
    PKPet *pet = _gameState.pet;
    if (!pet) return;
    NSString *icon = @"happy";
    NSInteger lowest = pet.satiety;
    if (pet.satiety < 35) icon = @"food";
    if (pet.energy < lowest) { lowest = pet.energy; icon = @"sleep"; }
    if (pet.hygiene < lowest) { lowest = pet.hygiene; icon = @"clean"; }
    if (pet.fun < lowest) { lowest = pet.fun; icon = @"play"; }
    if (pet.social < lowest) { lowest = pet.social; icon = @"social"; }
    if (pet.affection < lowest) { icon = @"cuddle"; }
    [self showThoughtText:[pet moodText] iconIdentifier:icon];
}

- (NSString *)compactFeedbackFromMessage:(NSString *)message {
    if ([message length] == 0) return @"";
    NSRange lineBreak = [message rangeOfString:@"\n"];
    if (lineBreak.location == NSNotFound) return message;
    return [message substringToIndex:lineBreak.location];
}

- (void)actionTapped:(UIButton *)sender {
    NSArray *identifiers = [self actionIdentifiers];
    if (sender.tag < 0 || sender.tag >= (NSInteger)[identifiers count]) return;
    NSString *identifier = [identifiers objectAtIndex:(NSUInteger)sender.tag];
    [self performActionIdentifier:identifier];
}

- (void)performActionIdentifier:(NSString *)identifier {
    [self performActionIdentifier:identifier usingPropView:nil];
}

- (void)performActionIdentifier:(NSString *)identifier usingPropView:(PKActionPropView *)propView {
    if ([_activeVisualActionIdentifier length] > 0) return;
    NSInteger previousActionCount = _gameState.actionCount;
    NSString *preference = nil;
    NSString *message = nil;
    if ([identifier isEqualToString:@"feed"]) {
        preference = [_gameState.pet foodPreferenceForIdentifier:_selectedFoodIdentifier];
        message = [_gameState performFeedWithFoodIdentifier:_selectedFoodIdentifier];
    } else {
        message = [_gameState performActionIdentifier:identifier];
    }
    BOOL completed = (_gameState.actionCount != previousActionCount);
    [_activeFoodPreference release];
    _activeFoodPreference = completed && preference ? [preference copy] : nil;
    _feedbackLabel.text = completed ? [self compactFeedbackFromMessage:message] : message;
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
    if (completed) {
        _pendingAutonomousMoment = ((_gameState.actionCount % 3) == 0);
        [self beginVisualAction:identifier usingPropView:propView];
    } else {
        [self showThoughtText:message iconIdentifier:([identifier isEqualToString:@"feed"] ? @"food" : identifier)];
        [self returnPropViewHome:propView];
        [self performSelector:@selector(startAvatarIdleAnimation) withObject:nil afterDelay:0.27f];
    }
}

- (PKActionPropView *)propViewForActionIdentifier:(NSString *)identifier {
    NSUInteger index = 0;
    for (index = 0; index < [_propViews count]; index++) {
        PKActionPropView *propView = [_propViews objectAtIndex:index];
        if ([[propView actionIdentifier] isEqualToString:identifier]) return propView;
    }
    return nil;
}

- (void)setCareInteractionsEnabled:(BOOL)enabled {
    NSUInteger index = 0;
    for (index = 0; index < [_actionButtons count]; index++) {
        UIButton *button = [_actionButtons objectAtIndex:index];
        button.enabled = enabled;
    }
    for (index = 0; index < [_propViews count]; index++) {
        PKActionPropView *propView = [_propViews objectAtIndex:index];
        propView.userInteractionEnabled = enabled;
    }
    for (index = 0; index < [_foodChoiceButtons count]; index++) {
        UIButton *button = [_foodChoiceButtons objectAtIndex:index];
        button.enabled = enabled;
    }
    _avatarView.userInteractionEnabled = enabled;
    if (![_voiceManager isRecording]) _voiceButton.enabled = enabled && _gameState.soundEnabled;
}

- (void)beginVisualAction:(NSString *)identifier usingPropView:(PKActionPropView *)propView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(consumeFoodStep) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollBallBackStep) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishVisualAction) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runAutonomousMoment) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
    [self stopAvatarIdleAnimation];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = [identifier copy];
    _activePropView = propView ? propView : [self propViewForActionIdentifier:identifier];
    [self setCareInteractionsEnabled:NO];
    if (!propView) {
        _avatarMotionView.center = _avatarHomeCenter;
        _avatarMotionView.transform = CGAffineTransformIdentity;
    }
    if ([identifier isEqualToString:@"feed"] && [_activeFoodPreference isEqualToString:@"favorite"]) _avatarView.reactionIdentifier = @"feed_favorite";
    else if ([identifier isEqualToString:@"feed"] && [_activeFoodPreference isEqualToString:@"disliked"]) _avatarView.reactionIdentifier = @"feed_disliked";
    else _avatarView.reactionIdentifier = identifier;

    NSString *thought = @"Harika!";
    if ([identifier isEqualToString:@"feed"] && [_activeFoodPreference isEqualToString:@"favorite"]) thought = @"Bayıldım! Bir tane daha?";
    else if ([identifier isEqualToString:@"feed"] && [_activeFoodPreference isEqualToString:@"disliked"]) thought = @"Hmm... başka mama var mı?";
    else if ([identifier isEqualToString:@"feed"]) thought = @"Mmm, güzelmiş!";
    else if ([identifier isEqualToString:@"play"]) thought = @"Topun peşindeyim!";
    else if ([identifier isEqualToString:@"sleep"]) thought = @"Tatlı rüyalar...";
    else if ([identifier isEqualToString:@"clean"]) thought = @"Mis gibi oldum!";
    else if ([identifier isEqualToString:@"cuddle"] || [identifier isEqualToString:@"touch"]) thought = @"Seni seviyorum!";
    NSString *thoughtIcon = [identifier isEqualToString:@"feed"] ? @"food" : identifier;
    [self showThoughtText:thought iconIdentifier:thoughtIcon];

    if ([identifier isEqualToString:@"play"]) [PKSoundManager playEffectNamed:@"ball" enabled:_gameState.soundEnabled];
    else if ([identifier isEqualToString:@"sleep"]) [PKSoundManager playEffectNamed:@"sleep" enabled:_gameState.soundEnabled];
    else if ([identifier isEqualToString:@"clean"]) [PKSoundManager playEffectNamed:@"bubble" enabled:_gameState.soundEnabled];
    else if ([identifier isEqualToString:@"cuddle"]) [PKSoundManager playEffectNamed:@"laugh" enabled:_gameState.soundEnabled];

    if (_activePropView) {
        _activePropView.hidden = NO;
        _activePropView.alpha = 1.0f;
        _activePropView.targeted = NO;
        _activePropView.depleted = NO;
        [_propPaletteView.superview bringSubviewToFront:_propPaletteView];
    }

    if ([identifier isEqualToString:@"feed"]) {
        CGPoint target = [_propPaletteView convertPoint:CGPointMake(_avatarMotionView.center.x + 72.0f, _avatarMotionView.center.y + 65.0f) fromView:self.view];
        [UIView beginAnimations:@"foodToPet" context:nil];
        [UIView setAnimationDuration:0.28f];
        _activePropView.center = target;
        _activePropView.transform = CGAffineTransformMakeScale(0.82f, 0.82f);
        [UIView commitAnimations];
        [UIView beginAnimations:@"petChew" context:nil];
        [UIView setAnimationDuration:0.12f];
        [UIView setAnimationRepeatCount:2.0f];
        [UIView setAnimationRepeatAutoreverses:YES];
        _avatarView.transform = CGAffineTransformMakeTranslation(0.0f, 8.0f);
        [UIView commitAnimations];
        [self performSelector:@selector(consumeFoodStep) withObject:nil afterDelay:0.38f];
        [self performSelector:@selector(finishVisualAction) withObject:nil afterDelay:1.02f];
    } else if ([identifier isEqualToString:@"play"]) {
        CGPoint target = [_propPaletteView convertPoint:CGPointMake(MIN(self.view.bounds.size.width - 80.0f, _avatarMotionView.center.x + 185.0f), _avatarMotionView.center.y + 75.0f) fromView:self.view];
        [UIView beginAnimations:@"ballRollOut" context:nil];
        [UIView setAnimationDuration:0.36f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _activePropView.center = target;
        _activePropView.transform = CGAffineTransformMakeRotation(3.05f);
        _avatarMotionView.center = CGPointMake(_avatarHomeCenter.x + 68.0f, _avatarHomeCenter.y);
        [UIView commitAnimations];
        [self performSelector:@selector(rollBallBackStep) withObject:nil afterDelay:0.39f];
        [self performSelector:@selector(finishVisualAction) withObject:nil afterDelay:1.04f];
    } else if ([identifier isEqualToString:@"clean"]) {
        CGPoint target = [_propPaletteView convertPoint:CGPointMake(_avatarMotionView.center.x + 58.0f, _avatarMotionView.center.y - 20.0f) fromView:self.view];
        [UIView beginAnimations:@"brushToPet" context:nil];
        [UIView setAnimationDuration:0.25f];
        _activePropView.center = target;
        _activePropView.transform = CGAffineTransformMakeRotation(0.34f);
        [UIView commitAnimations];
        [UIView beginAnimations:@"petShakeClean" context:nil];
        [UIView setAnimationDuration:0.11f];
        [UIView setAnimationRepeatCount:3.0f];
        [UIView setAnimationRepeatAutoreverses:YES];
        _avatarView.transform = CGAffineTransformMakeRotation(0.065f);
        [UIView commitAnimations];
        [self performSelector:@selector(finishVisualAction) withObject:nil afterDelay:0.96f];
    } else if ([identifier isEqualToString:@"sleep"]) {
        CGPoint target = CGPointMake(245.0f, 455.0f);
        if ([_gameState isItemPlaced:@"bed"]) {
            CGRect bedFrame = [_roomView frameForItemIdentifier:@"bed"];
            target = CGPointMake(MAX(215.0f, CGRectGetMidX(bedFrame) + 50.0f), MIN(475.0f, CGRectGetMidY(bedFrame) - 5.0f));
        }
        [UIView beginAnimations:@"petToBed" context:nil];
        [UIView setAnimationDuration:0.34f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        _avatarMotionView.center = target;
        _avatarMotionView.transform = CGAffineTransformMakeScale(0.76f, 0.68f);
        [UIView commitAnimations];
        [self performSelector:@selector(finishVisualAction) withObject:nil afterDelay:1.28f];
    } else {
        [UIView beginAnimations:@"petCuddleApproach" context:nil];
        [UIView setAnimationDuration:0.25f];
        [UIView setAnimationRepeatCount:1.0f];
        [UIView setAnimationRepeatAutoreverses:YES];
        _avatarMotionView.center = CGPointMake(_avatarHomeCenter.x + 25.0f, _avatarHomeCenter.y - 24.0f);
        _avatarMotionView.transform = CGAffineTransformMakeScale(1.12f, 1.12f);
        [UIView commitAnimations];
        [self performSelector:@selector(finishVisualAction) withObject:nil afterDelay:0.86f];
    }
}

- (void)consumeFoodStep {
    if (![_activeVisualActionIdentifier isEqualToString:@"feed"] || !_activePropView) return;
    [PKSoundManager playEffectNamed:@"eat" enabled:_gameState.soundEnabled];
    _activePropView.depleted = YES;
    [UIView beginAnimations:@"foodConsumed" context:nil];
    [UIView setAnimationDuration:0.25f];
    _activePropView.alpha = 0.46f;
    _activePropView.transform = CGAffineTransformMakeScale(0.65f, 0.65f);
    [UIView commitAnimations];
}

- (void)rollBallBackStep {
    if (![_activeVisualActionIdentifier isEqualToString:@"play"] || !_activePropView) return;
    CGPoint target = [_propPaletteView convertPoint:CGPointMake(_avatarHomeCenter.x - 80.0f, _avatarHomeCenter.y + 75.0f) fromView:self.view];
    [UIView beginAnimations:@"ballRollBack" context:nil];
    [UIView setAnimationDuration:0.34f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _activePropView.center = target;
    _activePropView.transform = CGAffineTransformMakeRotation(-3.05f);
    _avatarMotionView.center = CGPointMake(_avatarHomeCenter.x - 34.0f, _avatarHomeCenter.y);
    [UIView commitAnimations];
}

- (void)finishVisualAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(consumeFoodStep) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollBallBackStep) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishVisualAction) object:nil];
    PKActionPropView *propView = _activePropView;
    _activePropView = nil;
    [_avatarView.layer removeAllAnimations];
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
    if (propView) {
        [propView.layer removeAllAnimations];
        propView.depleted = NO;
        propView.alpha = 1.0f;
        propView.targeted = NO;
    }
    [UIView beginAnimations:@"careSequenceReturn" context:nil];
    [UIView setAnimationDuration:0.27f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    if (propView && propView.tag >= 0 && propView.tag < 3) {
        propView.center = _propHomeCenters[(NSUInteger)propView.tag];
        propView.transform = CGAffineTransformIdentity;
    }
    [UIView commitAnimations];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [_activeFoodPreference release];
    _activeFoodPreference = nil;
    if (_pendingAutonomousMoment) {
        [self performSelector:@selector(runAutonomousMoment) withObject:nil afterDelay:0.45f];
    } else {
        [self setCareInteractionsEnabled:YES];
        [self performSelector:@selector(startAvatarIdleAnimation) withObject:nil afterDelay:0.31f];
        [self performSelector:@selector(showDefaultThought) withObject:nil afterDelay:0.34f];
        [self performSelector:@selector(runMicroReaction) withObject:nil afterDelay:0.88f];
    }
}

- (BOOL)isPointOverAvatar:(CGPoint)point {
    CGRect target = CGRectMake(_avatarMotionView.center.x - 90.0f,
                               _avatarMotionView.center.y - 90.0f,
                               180.0f,
                               180.0f);
    return CGRectContainsPoint(target, point);
}

- (void)returnPropViewHome:(PKActionPropView *)propView {
    if (!propView || propView.tag < 0 || propView.tag >= 3) return;
    propView.targeted = NO;
    [UIView beginAnimations:@"propReturn" context:nil];
    [UIView setAnimationDuration:0.24f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    propView.center = _propHomeCenters[(NSUInteger)propView.tag];
    propView.transform = CGAffineTransformIdentity;
    propView.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void)propTapped:(UITapGestureRecognizer *)recognizer {
    PKActionPropView *propView = (PKActionPropView *)recognizer.view;
    if (![propView isKindOfClass:[PKActionPropView class]]) return;
    [self performActionIdentifier:[propView actionIdentifier] usingPropView:propView];
}

- (void)propPanned:(UIPanGestureRecognizer *)recognizer {
    PKActionPropView *propView = (PKActionPropView *)recognizer.view;
    if (![propView isKindOfClass:[PKActionPropView class]] || [_activeVisualActionIdentifier length] > 0) return;
    CGPoint point = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runMicroReaction) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
        [self stopAvatarIdleAnimation];
        [self.view bringSubviewToFront:_propPaletteView];
        propView.transform = CGAffineTransformMakeScale(1.08f, 1.08f);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat x = MIN(MAX(point.x, 55.0f), self.view.bounds.size.width - 55.0f);
        CGFloat y = MIN(MAX(point.y, 105.0f), 625.0f);
        point = CGPointMake(x, y);
        propView.center = [_propPaletteView convertPoint:point fromView:self.view];
        BOOL target = [self isPointOverAvatar:point];
        propView.targeted = target;
        _avatarMotionView.transform = target ? CGAffineTransformMakeScale(1.07f, 1.07f) : CGAffineTransformIdentity;
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        BOOL target = [self isPointOverAvatar:point];
        propView.targeted = NO;
        _avatarMotionView.transform = CGAffineTransformIdentity;
        if (target) {
            [self performActionIdentifier:[propView actionIdentifier] usingPropView:propView];
        } else {
            [self returnPropViewHome:propView];
            [self showThoughtText:@"Mama, top veya fırçayı bana getir." iconIdentifier:[propView actionIdentifier]];
            [self performSelector:@selector(startAvatarIdleAnimation) withObject:nil afterDelay:0.27f];
        }
    }
}

- (void)runAutonomousMoment {
    if (!_pendingAutonomousMoment || [_activeVisualActionIdentifier length] > 0) return;
    _pendingAutonomousMoment = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
    [self stopAvatarIdleAnimation];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = [@"autonomous" copy];
    [self setCareInteractionsEnabled:NO];

    NSString *personality = _gameState.pet.personalityIdentifier;
    NSString *reaction = @"play";
    NSString *icon = @"play";
    NSString *thought = @"Topumla biraz oynadım!";
    CGPoint target = CGPointMake(535.0f, 430.0f);
    if ([personality isEqualToString:@"curious"]) {
        reaction = @"curious"; icon = @"curious"; thought = @"Şu kuşu gördün mü?"; target = CGPointMake(275.0f, 220.0f);
    } else if ([personality isEqualToString:@"sleepy"]) {
        reaction = @"sleep"; icon = @"sleep"; thought = @"Yatağım çok rahat."; target = CGPointMake(250.0f, 460.0f);
    } else if ([personality isEqualToString:@"social"]) {
        reaction = @"cuddle"; icon = @"social"; thought = @"Arkadaşlarıma el salladım!"; target = CGPointMake(535.0f, 260.0f);
    } else if ([personality isEqualToString:@"musical"]) {
        reaction = @"music"; icon = @"music"; thought = @"Kendi şarkımı buldum!"; target = CGPointMake(285.0f, 410.0f);
    }
    _avatarView.reactionIdentifier = reaction;
    [self showThoughtText:thought iconIdentifier:icon];
    [UIView beginAnimations:@"autonomousPetMoment" context:nil];
    [UIView setAnimationDuration:0.38f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = target;
    _avatarMotionView.transform = CGAffineTransformMakeScale(0.86f, 0.86f);
    [UIView commitAnimations];
    [self performSelector:@selector(finishAutonomousMoment) withObject:nil afterDelay:1.08f];
}

- (void)finishAutonomousMoment {
    [UIView beginAnimations:@"autonomousPetReturn" context:nil];
    [UIView setAnimationDuration:0.29f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
    [self performSelector:@selector(completeAutonomousReturn) withObject:nil afterDelay:0.31f];
}

- (void)completeAutonomousReturn {
    _avatarView.reactionIdentifier = @"";
    _avatarView.transform = CGAffineTransformIdentity;
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [self setCareInteractionsEnabled:YES];
    [self showDefaultThought];
    [self startAvatarIdleAnimation];
}

- (NSInteger)actionIndexAtPoint:(CGPoint)point {
    NSUInteger index = 0;
    for (index = 0; index < [_actionButtons count]; index++) {
        UIButton *button = [_actionButtons objectAtIndex:index];
        if (CGRectContainsPoint(button.frame, point)) return (NSInteger)index;
    }
    return -1;
}

- (void)refreshActionHighlight {
    NSUInteger index = 0;
    for (index = 0; index < [_actionButtons count]; index++) {
        UIButton *button = [_actionButtons objectAtIndex:index];
        BOOL highlighted = ((NSInteger)index == _dragActionIndex);
        button.transform = highlighted ? CGAffineTransformMakeScale(1.07f, 1.07f) : CGAffineTransformIdentity;
        button.alpha = (_dragActionIndex < 0 || highlighted) ? 1.0f : 0.78f;
    }
}

- (void)avatarPanned:(UIPanGestureRecognizer *)recognizer {
    if ([_activeVisualActionIdentifier length] > 0) return;
    CGPoint point = [recognizer locationInView:self.view];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runMicroReaction) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
        [self stopAvatarIdleAnimation];
        _avatarMotionView.transform = CGAffineTransformMakeScale(1.08f, 1.08f);
    }
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat x = MIN(MAX(point.x, 60.0f), self.view.bounds.size.width - 60.0f);
        CGFloat y = MIN(MAX(point.y, 105.0f), 635.0f);
        _avatarMotionView.center = CGPointMake(x, y);
        NSInteger targetIndex = [self actionIndexAtPoint:point];
        if (_dragActionIndex != targetIndex) {
            _dragActionIndex = targetIndex;
            [self refreshActionHighlight];
        }
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        NSInteger targetIndex = [self actionIndexAtPoint:point];
        _dragActionIndex = -1;
        [self refreshActionHighlight];
        NSArray *identifiers = [self actionIdentifiers];
        if (targetIndex >= 0 && targetIndex < (NSInteger)[identifiers count]) {
            [self performActionIdentifier:[identifiers objectAtIndex:(NSUInteger)targetIndex]];
        } else {
            [self returnAvatarHome];
            _feedbackLabel.text = @"Yavrunu Besle, Oyna, Uyut, Temizle veya Sev düğmesinin üzerine bırak.";
        }
    }
}

- (void)returnAvatarHome {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
    [UIView beginAnimations:@"homePetReturn" context:nil];
    [UIView setAnimationDuration:0.24f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    _avatarMotionView.alpha = 1.0f;
    [UIView commitAnimations];
    [self performSelector:@selector(startAvatarIdleAnimation) withObject:nil afterDelay:0.27f];
}

- (void)avatarTapped:(UITapGestureRecognizer *)recognizer {
    if ([_activeVisualActionIdentifier length] > 0) return;
    CGPoint point = [recognizer locationInView:_avatarView];
    NSString *zone = [_avatarView interactionZoneAtPoint:point];
    [self performTouchReactionIdentifier:(zone ? zone : @"belly")];
}

- (void)performTouchReactionIdentifier:(NSString *)identifier {
    if ([_activeVisualActionIdentifier length] > 0) return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runMicroReaction) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
    [self stopAvatarIdleAnimation];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = [@"touch_zone" copy];
    [self setCareInteractionsEnabled:NO];

    NSString *reaction = @"tickle";
    NSString *thought = @"Gıdıklanıyorum!";
    NSString *feedback = @"Karnına dokundun; kahkahayla kıpırdandı.";
    NSString *sound = @"laugh";
    CGAffineTransform target = CGAffineTransformMakeRotation(0.055f);
    if ([identifier isEqualToString:@"head"]) {
        reaction = @"head";
        thought = @"Başımı okşaman çok güzel!";
        feedback = @"Başını okşadın; gözlerini mutlulukla kıstı.";
        target = CGAffineTransformMakeTranslation(0.0f, 7.0f);
    } else if ([identifier isEqualToString:@"paw"]) {
        reaction = @"wave";
        thought = @"Çak bir pati!";
        feedback = @"Patisine dokundun; sana el salladı.";
        target = CGAffineTransformMakeScale(1.08f, 1.08f);
    } else if ([identifier isEqualToString:@"tail"]) {
        reaction = @"tail";
        thought = @"Kuyruğum orada!";
        feedback = @"Kuyruğuna dokundun; şaşkınlıkla arkaya baktı.";
        sound = @"surprise";
        target = CGAffineTransformMakeRotation(-0.07f);
    }
    _avatarView.reactionIdentifier = reaction;
    _feedbackLabel.text = feedback;
    [self showThoughtText:thought iconIdentifier:([identifier isEqualToString:@"tail"] ? @"curious" : @"cuddle")];
    [PKSoundManager playEffectNamed:sound enabled:_gameState.soundEnabled];
    [UIView beginAnimations:@"petTouchReaction" context:nil];
    [UIView setAnimationDuration:0.13f];
    [UIView setAnimationRepeatCount:2.0f];
    [UIView setAnimationRepeatAutoreverses:YES];
    _avatarView.transform = target;
    [UIView commitAnimations];
    [self performSelector:@selector(finishTouchReaction) withObject:nil afterDelay:0.68f];
}

- (void)finishTouchReaction {
    if (![_activeVisualActionIdentifier isEqualToString:@"touch_zone"]) return;
    [_avatarView.layer removeAllAnimations];
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [self setCareInteractionsEnabled:YES];
    [self showDefaultThought];
    [self startAvatarIdleAnimation];
}

- (void)runMicroReaction {
    if ([_activeVisualActionIdentifier length] > 0 || !_avatarView.window) return;
    [self stopAvatarIdleAnimation];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = [@"micro" copy];
    [self setCareInteractionsEnabled:NO];
    NSArray *reactions = [NSArray arrayWithObjects:@"blink", @"look", @"yawn", @"ear", @"wave", nil];
    NSString *reaction = [reactions objectAtIndex:(NSUInteger)(_gameState.actionCount % (NSInteger)[reactions count])];
    _avatarView.reactionIdentifier = reaction;
    CGAffineTransform target = CGAffineTransformIdentity;
    CGFloat duration = 0.18f;
    if ([reaction isEqualToString:@"blink"]) target = CGAffineTransformMakeScale(1.0f, 0.96f);
    else if ([reaction isEqualToString:@"look"]) { target = CGAffineTransformMakeTranslation(5.0f, 0.0f); duration = 0.34f; }
    else if ([reaction isEqualToString:@"yawn"]) { target = CGAffineTransformMakeScale(0.97f, 0.97f); duration = 0.48f; [self showThoughtText:@"Hıımm... biraz esnedim." iconIdentifier:@"sleep"]; }
    else if ([reaction isEqualToString:@"ear"]) { target = CGAffineTransformMakeRotation(0.035f); duration = 0.27f; }
    else { target = CGAffineTransformMakeTranslation(0.0f, -5.0f); duration = 0.38f; [self showThoughtText:@"Merhaba!" iconIdentifier:@"social"]; }
    [UIView beginAnimations:@"petMicroReaction" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationRepeatCount:1.0f];
    [UIView setAnimationRepeatAutoreverses:YES];
    _avatarView.transform = target;
    [UIView commitAnimations];
    [self performSelector:@selector(finishMicroReaction) withObject:nil afterDelay:(duration * 2.0f) + 0.08f];
}

- (void)finishMicroReaction {
    if (![_activeVisualActionIdentifier isEqualToString:@"micro"]) return;
    [_avatarView.layer removeAllAnimations];
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [self setCareInteractionsEnabled:YES];
    [self showDefaultThought];
    [self startAvatarIdleAnimation];
}

- (void)voiceTapped:(id)sender {
    (void)sender;
    if ([_voiceManager isRecording]) {
        [self finishVoiceRecording];
        return;
    }
    if ([_activeVisualActionIdentifier isEqualToString:@"voice"]) {
        _feedbackLabel.text = @"Ses kaydı kesildi; yeniden deneyebilirsin.";
        [self finishVoicePlayback];
        return;
    }
    if (!_gameState.soundEnabled || [_activeVisualActionIdentifier length] > 0) return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runMicroReaction) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAvatarIdleAnimation) object:nil];
    [self stopAvatarIdleAnimation];
    if (![_voiceManager startRecording]) {
        _feedbackLabel.text = @"Mikrofon başlatılamadı; iPad ayarlarını kontrol et.";
        [self setCareInteractionsEnabled:YES];
        [self showDefaultThought];
        [self startAvatarIdleAnimation];
        return;
    }
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = [@"voice" copy];
    [self setCareInteractionsEnabled:NO];
    _voiceButton.enabled = YES;
    _voiceButton.title = @"Durdur";
    _avatarView.reactionIdentifier = @"look";
    [self showThoughtText:@"Seni dinliyorum..." iconIdentifier:@"music"];
    _feedbackLabel.text = @"3 saniye konuş; kayıt yalnızca bu iPad içinde tutulur.";
    [self performSelector:@selector(finishVoiceRecording) withObject:nil afterDelay:3.0f];
}

- (void)finishVoiceRecording {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishVoiceRecording) object:nil];
    if (![_activeVisualActionIdentifier isEqualToString:@"voice"]) return;
    if (![_voiceManager isRecording]) {
        _feedbackLabel.text = @"Ses kaydı kesildi; yeniden deneyebilirsin.";
        [self finishVoicePlayback];
        return;
    }
    BOOL playing = [_voiceManager stopRecordingAndPlay];
    _voiceButton.enabled = NO;
    _voiceButton.title = @"Konuş";
    _avatarView.reactionIdentifier = playing ? @"surprise" : @"";
    [self showThoughtText:(playing ? @"Sesini sana geri söylüyorum!" : @"Ses kaydı oynatılamadı.") iconIdentifier:@"music"];
    _feedbackLabel.text = playing ? @"Çevrimdışı ses tekrar oynatılıyor; hiçbir sunucuya gönderilmedi." : @"Ses kaydı oynatılamadı.";
    [self performSelector:@selector(finishVoicePlayback) withObject:nil afterDelay:(playing ? 3.15f : 0.20f)];
}

- (void)finishVoicePlayback {
    if (![_activeVisualActionIdentifier isEqualToString:@"voice"]) return;
    [_voiceManager cancel];
    _avatarView.reactionIdentifier = @"";
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [self setCareInteractionsEnabled:YES];
    [self showDefaultThought];
    [self startAvatarIdleAnimation];
}

- (void)startAvatarIdleAnimation {
    if ([_activeVisualActionIdentifier length] > 0) return;
    [self stopAvatarIdleAnimation];
    [UIView beginAnimations:@"homePetIdle" context:nil];
    [UIView setAnimationDuration:1.70f];
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

- (void)destinationTapped:(UIButton *)sender {
    UIViewController *controller = nil;
    if (sender.tag == 0) controller = [[[PKTownMapViewController alloc] initWithGameState:_gameState] autorelease];
    else if (sender.tag == 1) controller = [[[PKRoomPlayViewController alloc] initWithGameState:_gameState] autorelease];
    else if (sender.tag == 2) controller = [[[PKWardrobeViewController alloc] initWithGameState:_gameState] autorelease];
    else if (sender.tag == 3) controller = [[[PKSkillsViewController alloc] initWithGameState:_gameState] autorelease];
    else if (sender.tag == 4) controller = [[[PKMiniGamesViewController alloc] initWithGameState:_gameState] autorelease];
    else controller = [[[PKAlbumViewController alloc] initWithGameState:_gameState] autorelease];
    if (controller) [self.navigationController pushViewController:controller animated:YES];
}

- (void)soundTapped:(id)sender {
    (void)sender;
    _gameState.soundEnabled = !_gameState.soundEnabled;
    [_gameState save];
    [self refreshUI];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
}

- (void)photoTapped:(id)sender {
    (void)sender;
    CGSize outputSize = CGSizeMake(512.0f, 352.0f);
    UIGraphicsBeginImageContextWithOptions(outputSize, YES, 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, outputSize.width / self.view.bounds.size.width, outputSize.height / self.view.bounds.size.height);
    [self.view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    NSData *data = UIImageJPEGRepresentation(image, 0.68f);
    UIGraphicsEndImageContext();
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0 || !data) { _feedbackLabel.text = @"Fotoğraf şu anda kaydedilemedi."; return; }
    NSString *folder = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PatiMemories"];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    long long stamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *filename = [NSString stringWithFormat:@"ani-%lld.jpg", stamp];
    NSString *path = [folder stringByAppendingPathComponent:filename];
    if ([data writeToFile:path atomically:YES]) {
        [_gameState addMemoryWithTitle:[NSString stringWithFormat:@"%@ ile evde bir an", _gameState.pet.name] filename:filename];
        [_gameState save];
        [self cleanupUnreferencedPhotosInFolder:folder];
        _feedbackLabel.text = @"Fotoğraf Anı Albümüne eklendi.";
        [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    } else {
        _feedbackLabel.text = @"Fotoğraf şu anda kaydedilemedi.";
    }
}

- (void)cleanupUnreferencedPhotosInFolder:(NSString *)folder {
    NSMutableSet *kept = [NSMutableSet set];
    NSUInteger index = 0;
    for (index = 0; index < [_gameState.memories count]; index++) {
        NSString *filename = [[_gameState.memories objectAtIndex:index] objectForKey:@"filename"];
        if ([filename length] > 0) [kept addObject:filename];
    }
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    for (index = 0; index < [files count]; index++) {
        NSString *filename = [files objectAtIndex:index];
        if (![kept containsObject:filename]) [[NSFileManager defaultManager] removeItemAtPath:[folder stringByAppendingPathComponent:filename] error:nil];
    }
}

- (void)menuTapped:(id)sender {
    (void)sender;
    [_gameState save];
    PKAppDelegate *delegate = (PKAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showWelcome];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_activeVisualActionIdentifier release];
    _activeVisualActionIdentifier = nil;
    [_activeFoodPreference release];
    _activeFoodPreference = nil;
    [_voiceManager cancel];
    _voiceButton.title = @"Konuş";
    _activePropView = nil;
    _pendingAutonomousMoment = NO;
    _avatarMotionView.center = _avatarHomeCenter;
    _avatarMotionView.transform = CGAffineTransformIdentity;
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
    NSUInteger propIndex = 0;
    for (propIndex = 0; propIndex < [_propViews count]; propIndex++) {
        PKActionPropView *propView = [_propViews objectAtIndex:propIndex];
        [propView.layer removeAllAnimations];
        propView.center = _propHomeCenters[propIndex];
        propView.transform = CGAffineTransformIdentity;
        propView.alpha = 1.0f;
        propView.depleted = NO;
        propView.targeted = NO;
    }
    if ([_propViews count] > 0) ((PKActionPropView *)[_propViews objectAtIndex:0]).propIdentifier = _selectedFoodIdentifier;
    [self refreshFoodChoiceButtons];
    [self setCareInteractionsEnabled:YES];
    _dragActionIndex = -1;
    [self refreshActionHighlight];
    [self refreshUI];
    [self startAvatarIdleAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopAvatarIdleAnimation];
    [_voiceManager cancel];
    _voiceButton.title = @"Konuş";
    [_avatarView.layer removeAllAnimations];
    NSUInteger propIndex = 0;
    for (propIndex = 0; propIndex < [_propViews count]; propIndex++) {
        PKActionPropView *propView = [_propViews objectAtIndex:propIndex];
        [propView.layer removeAllAnimations];
    }
    [_gameState save];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_gameState release]; [_roomView release]; [_avatarMotionView release]; [_avatarView release]; [_actionButtons release]; [_propPaletteView release]; [_propViews release]; [_foodChoiceButtons release]; [_selectedFoodIdentifier release]; [_activeFoodPreference release]; [_thoughtBubbleView release]; [_activeVisualActionIdentifier release]; [_nameLabel release]; [_profileLabel release];
    [_statusLabel release]; [_feedbackLabel release]; [_questLabel release]; [_soundButton release]; [_voiceButton release]; [_voiceManager release];
    [_satietyBar release]; [_energyBar release]; [_hygieneBar release]; [_funBar release]; [_socialBar release]; [_affectionBar release];
    [super dealloc];
}

@end
