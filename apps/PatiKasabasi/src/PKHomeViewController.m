#import "PKHomeViewController.h"
#import "PKGameState.h"
#import "PKPet.h"
#import "PKPetAvatarView.h"
#import "PKNeedBarView.h"
#import "PKRoomBackgroundView.h"
#import "PKTownMapViewController.h"
#import "PKRoomPlayViewController.h"
#import "PKWardrobeViewController.h"
#import "PKSkillsViewController.h"
#import "PKMiniGamesViewController.h"
#import "PKAlbumViewController.h"
#import "PKSoundManager.h"
#import "PKAppDelegate.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>
#include <float.h>

@interface PKHomeViewController ()
- (NSArray *)actionIdentifiers;
- (void)refreshUI;
- (void)showReactionForIdentifier:(NSString *)identifier;
- (void)resetAvatarReaction;
- (void)startAvatarIdleAnimation;
- (void)stopAvatarIdleAnimation;
- (void)cleanupUnreferencedPhotosInFolder:(NSString *)folder;
@end

@implementation PKHomeViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
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
    UIBarButtonItem *photoButton = [[UIBarButtonItem alloc] initWithTitle:@"Fotoğraf" style:UIBarButtonItemStyleBordered target:self action:@selector(photoTapped:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_soundButton, photoButton, nil];
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

    UIView *speech = [[[UIView alloc] initWithFrame:CGRectMake(292.0f, 62.0f, 335.0f, 88.0f)] autorelease];
    [PKTheme stylePanel:speech];
    [self.view addSubview:speech];
    _moodLabel = [[self labelWithFrame:CGRectMake(15.0f, 10.0f, 305.0f, 68.0f) text:@"" fontSize:19.0f bold:YES] retain];
    [speech addSubview:_moodLabel];

    _avatarMotionView = [[UIView alloc] initWithFrame:CGRectMake(220.0f, 150.0f, 360.0f, 370.0f)];
    _avatarMotionView.backgroundColor = [UIColor clearColor];
    _avatarView = [[PKPetAvatarView alloc] initWithFrame:_avatarMotionView.bounds speciesIdentifier:_gameState.pet.speciesIdentifier];
    _avatarView.userInteractionEnabled = YES;
    UITapGestureRecognizer *petTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)] autorelease];
    [_avatarView addGestureRecognizer:petTap];
    [_avatarMotionView addSubview:_avatarView];
    [self.view addSubview:_avatarMotionView];

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
    NSString *welcomeMessage = _gameState.newHomeBadge ? @"Yeni Bir Yuva rozetini kazandın!" : @"Hediye oyuncağın hazır!";
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
    for (index = 0; index < [titles count]; index++) {
        UIButton *button = index == 0 ? [self primaryButtonWithFrame:CGRectMake(actionStartX + ((actionWidth + actionGap) * index), 600.0f, actionWidth, 58.0f) title:[titles objectAtIndex:index]] : [self secondaryButtonWithFrame:CGRectMake(actionStartX + ((actionWidth + actionGap) * index), 600.0f, actionWidth, 58.0f) title:[titles objectAtIndex:index]];
        button.tag = index;
        [button addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    [self refreshUI];
}

- (NSArray *)actionIdentifiers { return [NSArray arrayWithObjects:@"feed", @"play", @"sleep", @"clean", @"cuddle", nil]; }

- (void)refreshUI {
    PKPet *pet = _gameState.pet;
    if (!pet) return;
    _nameLabel.text = pet.name;
    NSString *reward = _gameState.newHomeBadge ? @"Yeni Bir Yuva rozeti" : @"Hediye oyuncak";
    _profileLabel.text = [NSString stringWithFormat:@"%@ • %@ • %@\n%@ • %@", [pet speciesDisplayName], [pet lifeStageDisplayName], [pet personalityDisplayName], [_gameState sourceDisplayName], reward];
    _statusLabel.text = [NSString stringWithFormat:@"Gün %ld • %@ • %@ • %ld pati", (long)_gameState.day, [_gameState dayPartDisplayName], [_gameState seasonDisplayName], (long)_gameState.coins];
    _moodLabel.text = [NSString stringWithFormat:@"“%@”", [pet moodText]];
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
}

- (void)showReactionForIdentifier:(NSString *)identifier {
    _avatarView.reactionIdentifier = identifier;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0f, -14.0f);
    if ([identifier isEqualToString:@"sleep"]) transform = CGAffineTransformMakeScale(1.0f, 0.92f);
    if ([identifier isEqualToString:@"clean"]) transform = CGAffineTransformMakeRotation(0.055f);
    if ([identifier isEqualToString:@"cuddle"] || [identifier isEqualToString:@"touch"]) transform = CGAffineTransformMakeScale(1.06f, 1.06f);
    [UIView beginAnimations:@"petReaction" context:nil];
    [UIView setAnimationDuration:0.18f];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:1.0f];
    _avatarView.transform = transform;
    [UIView commitAnimations];
    [self performSelector:@selector(resetAvatarReaction) withObject:nil afterDelay:0.40f];
}

- (void)actionTapped:(UIButton *)sender {
    NSArray *identifiers = [self actionIdentifiers];
    if (sender.tag < 0 || sender.tag >= (NSInteger)[identifiers count]) return;
    NSString *identifier = [identifiers objectAtIndex:(NSUInteger)sender.tag];
    _feedbackLabel.text = [_gameState performActionIdentifier:identifier];
    [PKSoundManager playEffectNamed:@"tap" enabled:_gameState.soundEnabled];
    [self refreshUI];
    [self showReactionForIdentifier:identifier];
}

- (void)avatarTapped:(UITapGestureRecognizer *)recognizer {
    (void)recognizer;
    _feedbackLabel.text = [NSString stringWithFormat:@"Dokunuşuna hemen karşılık verdi.\n%@", [_gameState performActionIdentifier:@"cuddle"]];
    [PKSoundManager playEffectNamed:@"success" enabled:_gameState.soundEnabled];
    [self refreshUI];
    [self showReactionForIdentifier:@"touch"];
}

- (void)resetAvatarReaction {
    _avatarView.transform = CGAffineTransformIdentity;
    _avatarView.reactionIdentifier = @"";
}

- (void)startAvatarIdleAnimation {
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
    [self refreshUI];
    [self startAvatarIdleAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAvatarIdleAnimation];
    [_gameState save];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_gameState release]; [_roomView release]; [_avatarMotionView release]; [_avatarView release]; [_nameLabel release]; [_profileLabel release];
    [_statusLabel release]; [_moodLabel release]; [_feedbackLabel release]; [_questLabel release]; [_soundButton release];
    [_satietyBar release]; [_energyBar release]; [_hygieneBar release]; [_funBar release]; [_socialBar release]; [_affectionBar release];
    [super dealloc];
}

@end
