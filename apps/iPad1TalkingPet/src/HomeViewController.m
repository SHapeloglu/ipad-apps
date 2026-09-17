#import "HomeViewController.h"
#import "PetNeedsManager.h"
#import "PetProgressManager.h"
#import "WardrobeViewController.h"
#import "MiniGameViewController.h"
#import "FoodViewController.h"
#import "BathViewController.h"
#import "SleepViewController.h"
#import "GameMenuViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    _needs = [[PetNeedsManager alloc] init];
    _progress = [[PetProgressManager alloc] init];
    _audio = [[PetAudioManager alloc] init];
    _audio.delegate = self;

    UIImage *bg = [UIImage imageNamed:@"home_bg.jpg"];
    _backgroundView = [[UIImageView alloc] initWithImage:bg];
    _backgroundView.frame = self.view.bounds;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.userInteractionEnabled = YES;
    [self.view addSubview:_backgroundView];

    [self buildStatusOverlay];
    [self buildTouchZones];
    [self buildTalkButton];
    [self refreshUI];

    if ([_progress claimDailyRewardIfAvailable]) {
        [self showMessage:@"Günlük ödül: 50 coin + 10 XP!"];
    }

    _idleTimer = [[NSTimer scheduledTimerWithTimeInterval:3.2 target:self selector:@selector(runIdlePulse) userInfo:nil repeats:YES] retain];
    _decayTimer = [[NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(runDecay) userInfo:nil repeats:YES] retain];
}

- (void)buildStatusOverlay {
    _hungerBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _happinessBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _hygieneBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _energyBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _xpBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

    NSArray *bars = [NSArray arrayWithObjects:_hungerBar,_happinessBar,_hygieneBar,_energyBar,nil];
    CGFloat x = 96.0f;
    for (NSInteger i=0; i<[bars count]; i++) {
        UIProgressView *bar = [bars objectAtIndex:i];
        bar.frame = CGRectMake(x + i*155.0f, 50.0f, 105.0f, 10.0f);
        [_backgroundView addSubview:bar];
    }

    _coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 112, 155, 38)];
    _coinLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.80];
    _coinLabel.textColor = [UIColor brownColor];
    _coinLabel.textAlignment = UITextAlignmentCenter;
    _coinLabel.font = [UIFont boldSystemFontOfSize:20];
    _coinLabel.layer.cornerRadius = 10;
    [_backgroundView addSubview:_coinLabel];

    _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(205, 112, 145, 38)];
    _levelLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.80];
    _levelLabel.textAlignment = UITextAlignmentCenter;
    _levelLabel.font = [UIFont boldSystemFontOfSize:20];
    _levelLabel.layer.cornerRadius = 10;
    [_backgroundView addSubview:_levelLabel];

    _xpBar.frame = CGRectMake(370, 125, 170, 10);
    [_backgroundView addSubview:_xpBar];

    _speechLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 165, 408, 56)];
    _speechLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.80];
    _speechLabel.textAlignment = UITextAlignmentCenter;
    _speechLabel.font = [UIFont boldSystemFontOfSize:18];
    _speechLabel.layer.cornerRadius = 12;
    _speechLabel.hidden = YES;
    [_backgroundView addSubview:_speechLabel];
}

- (UIButton *)invisibleButtonWithFrame:(CGRect)frame tag:(NSInteger)tag {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = frame;
    b.tag = tag;
    b.backgroundColor = [UIColor clearColor];
    [b addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:b];
    return b;
}

- (void)buildTouchZones {
    [self invisibleButtonWithFrame:CGRectMake(25,830,125,180) tag:1];
    [self invisibleButtonWithFrame:CGRectMake(165,830,125,180) tag:2];
    [self invisibleButtonWithFrame:CGRectMake(305,830,125,180) tag:3];
    [self invisibleButtonWithFrame:CGRectMake(445,830,125,180) tag:4];
    [self invisibleButtonWithFrame:CGRectMake(585,830,150,180) tag:5];

    [self invisibleButtonWithFrame:CGRectMake(270,200,230,190) tag:20]; // head
    [self invisibleButtonWithFrame:CGRectMake(275,390,225,250) tag:21]; // body
    [self invisibleButtonWithFrame:CGRectMake(275,640,225,170) tag:22]; // feet
}

- (void)buildTalkButton {
    _talkButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _talkButton.frame = CGRectMake(565, 105, 170, 58);
    [_talkButton setTitle:@"Konuş" forState:UIControlStateNormal];
    _talkButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [_talkButton addTarget:self action:@selector(toggleTalking) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:_talkButton];
}

- (void)toggleTalking {
    if (!_audio.recording) {
        if ([_audio startRecording]) {
            [_talkButton setTitle:@"Bitir / Tekrarla" forState:UIControlStateNormal];
            [self showSpeech:@"Seni dinliyorum..."];
        } else {
            [self showMessage:@"Mikrofon başlatılamadı."];
        }
    } else {
        [_talkButton setTitle:@"Konuş" forState:UIControlStateNormal];
        [self showSpeech:@"Şimdi seni taklit ediyorum!"];
        [_audio stopAndRepeat];
        [_progress addXP:3];
        [self refreshUI];
    }
}

- (void)petAudioDidFinishRepeat {
    [self showSpeech:@"Bir daha konuşalım mı?"];
}

- (void)actionTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 1: {
            FoodViewController *f = [[[FoodViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
            [self presentModalViewController:f animated:YES];
            break;
        }
        case 2: {
            BathViewController *b = [[[BathViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
            [self presentModalViewController:b animated:YES];
            break;
        }
        case 3: {
            SleepViewController *s = [[[SleepViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
            [self presentModalViewController:s animated:YES];
            break;
        }
        case 4: {
            GameMenuViewController *g = [[[GameMenuViewController alloc] initWithProgressManager:_progress] autorelease];
            [self presentModalViewController:g animated:YES];
            break;
        }
        case 5: {
            WardrobeViewController *w = [[[WardrobeViewController alloc] initWithProgressManager:_progress] autorelease];
            [self presentModalViewController:w animated:YES];
            break;
        }
        case 20:
            [_progress addXP:1];
            [self showSpeech:@"Başımı okşaman hoşuma gitti!"];
            [self petReactionScale:1.025f];
            break;
        case 21:
            [_progress addXP:1];
            [self showSpeech:@"Hihi, gıdıklanıyorum!"];
            [self petReactionScale:0.985f];
            break;
        case 22:
            [self showSpeech:@"Ayaklarım biraz hassas!"];
            [self petReactionScale:1.012f];
            break;
    }
    [self refreshUI];
}

- (void)refreshUI {
    _hungerBar.progress = _needs.hunger / 100.0f;
    _happinessBar.progress = _needs.happiness / 100.0f;
    _hygieneBar.progress = _needs.hygiene / 100.0f;
    _energyBar.progress = _needs.energy / 100.0f;
    _coinLabel.text = [NSString stringWithFormat:@"Coin: %ld",(long)_progress.coins];
    _levelLabel.text = [NSString stringWithFormat:@"Seviye %ld",(long)_progress.level];
    NSInteger needed = [_progress xpNeededForNextLevel];
    _xpBar.progress = needed > 0 ? ((float)_progress.xp / (float)needed) : 0;
}

- (void)showSpeech:(NSString *)text {
    _speechLabel.text = text;
    _speechLabel.hidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSpeech) object:nil];
    [self performSelector:@selector(hideSpeech) withObject:nil afterDelay:2.4];
}

- (void)hideSpeech {
    _speechLabel.hidden = YES;
}

- (void)showMessage:(NSString *)message {
    UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Pati"
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@"Tamam"
                                      otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)petReactionScale:(CGFloat)scale {
    [UIView animateWithDuration:0.12 animations:^{
        _backgroundView.transform = CGAffineTransformMakeScale(scale, scale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.12 animations:^{
            _backgroundView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)runIdlePulse {
    [UIView animateWithDuration:0.30 animations:^{
        _backgroundView.alpha = 0.988f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.30 animations:^{
            _backgroundView.alpha = 1.0f;
        }];
    }];
}

- (void)runDecay {
    [_needs applyMinuteDecay];
    [self refreshUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUI];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_idleTimer invalidate]; [_idleTimer release];
    [_decayTimer invalidate]; [_decayTimer release];

    [_audio stopAll];
    [_audio release];
    [_progress release];
    [_needs release];

    [_talkButton release];
    [_speechLabel release];
    [_coinLabel release];
    [_levelLabel release];
    [_hungerBar release];
    [_happinessBar release];
    [_hygieneBar release];
    [_energyBar release];
    [_xpBar release];
    [_backgroundView release];
    [super dealloc];
}
@end
