#import "HomeViewController.h"
#import "PetNeedsManager.h"
#import "PetProgressManager.h"
#import "PetAnimator.h"
#import "PetAccessoryView.h"
#import "WardrobeViewController.h"
#import "FoodViewController.h"
#import "BathViewController.h"
#import "SleepViewController.h"
#import "GameMenuViewController.h"
#import "RoomDecorViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];

    _needs=[[PetNeedsManager alloc] init];
    _progress=[[PetProgressManager alloc] init];
    _audio=[[PetAudioManager alloc] init];
    _audio.delegate=self;

    UIImage *bg=[UIImage imageNamed:@"home_bg.jpg"];
    _backgroundView=[[UIImageView alloc] initWithImage:bg];
    _backgroundView.frame=self.view.bounds;
    _backgroundView.contentMode=UIViewContentModeScaleAspectFill;
    _backgroundView.userInteractionEnabled=YES;
    [self.view addSubview:_backgroundView];

    _themeOverlay=[[UIView alloc] initWithFrame:_backgroundView.bounds];
    _themeOverlay.userInteractionEnabled=NO;
    [_backgroundView addSubview:_themeOverlay];

    // Visual accessory layer on top of the character in the approved home art.
    _accessoryView=[[PetAccessoryView alloc] initWithFrame:CGRectMake(274,205,320,320)];
    [_backgroundView addSubview:_accessoryView];

    [self buildStatusOverlay];
    [self buildTouchZones];
    [self buildTalkButton];
    [self buildDecorButton];
    [self applyRoomTheme];
    [self refreshUI];

    _animator=[[PetAnimator alloc] initWithHostView:_backgroundView];
    [_animator startIdle];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outfitChanged)
                                                 name:@"WardrobeChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyRoomTheme)
                                                 name:@"RoomThemeChanged" object:nil];

    if([_progress claimDailyRewardIfAvailable])
        [self showMessage:@"Günlük ödül: 50 coin + 10 XP!"];

    _decayTimer=[[NSTimer scheduledTimerWithTimeInterval:60.0 target:self
                                                selector:@selector(runDecay)
                                                userInfo:nil repeats:YES] retain];
}

- (void)buildStatusOverlay {
    _hungerBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _happinessBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _hygieneBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _energyBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _xpBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

    NSArray *bars=[NSArray arrayWithObjects:_hungerBar,_happinessBar,_hygieneBar,_energyBar,nil];
    CGFloat x=96;
    for(NSInteger i=0;i<[bars count];i++){
        UIProgressView *bar=[bars objectAtIndex:i];
        bar.frame=CGRectMake(x+i*155,50,105,10);
        [_backgroundView addSubview:bar];
    }

    _coinLabel=[[UILabel alloc] initWithFrame:CGRectMake(35,112,155,38)];
    _coinLabel.backgroundColor=[UIColor colorWithWhite:1 alpha:0.82];
    _coinLabel.textColor=[UIColor brownColor];
    _coinLabel.textAlignment=UITextAlignmentCenter;
    _coinLabel.font=[UIFont boldSystemFontOfSize:20];
    _coinLabel.layer.cornerRadius=10;
    [_backgroundView addSubview:_coinLabel];

    _levelLabel=[[UILabel alloc] initWithFrame:CGRectMake(205,112,145,38)];
    _levelLabel.backgroundColor=[UIColor colorWithWhite:1 alpha:0.82];
    _levelLabel.textAlignment=UITextAlignmentCenter;
    _levelLabel.font=[UIFont boldSystemFontOfSize:20];
    _levelLabel.layer.cornerRadius=10;
    [_backgroundView addSubview:_levelLabel];

    _xpBar.frame=CGRectMake(370,125,170,10);
    [_backgroundView addSubview:_xpBar];

    _speechLabel=[[UILabel alloc] initWithFrame:CGRectMake(180,165,408,56)];
    _speechLabel.backgroundColor=[UIColor colorWithWhite:1 alpha:0.82];
    _speechLabel.textAlignment=UITextAlignmentCenter;
    _speechLabel.font=[UIFont boldSystemFontOfSize:18];
    _speechLabel.layer.cornerRadius=12;
    _speechLabel.hidden=YES;
    [_backgroundView addSubview:_speechLabel];
}

- (UIButton *)invisibleButtonWithFrame:(CGRect)frame tag:(NSInteger)tag {
    UIButton *b=[UIButton buttonWithType:UIButtonTypeCustom];
    b.frame=frame; b.tag=tag; b.backgroundColor=[UIColor clearColor];
    [b addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:b]; return b;
}

- (void)buildTouchZones {
    [self invisibleButtonWithFrame:CGRectMake(25,830,125,180) tag:1];
    [self invisibleButtonWithFrame:CGRectMake(165,830,125,180) tag:2];
    [self invisibleButtonWithFrame:CGRectMake(305,830,125,180) tag:3];
    [self invisibleButtonWithFrame:CGRectMake(445,830,125,180) tag:4];
    [self invisibleButtonWithFrame:CGRectMake(585,830,150,180) tag:5];
    [self invisibleButtonWithFrame:CGRectMake(270,200,230,190) tag:20];
    [self invisibleButtonWithFrame:CGRectMake(275,390,225,250) tag:21];
    [self invisibleButtonWithFrame:CGRectMake(275,640,225,170) tag:22];
}

- (void)buildTalkButton {
    _talkButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _talkButton.frame=CGRectMake(565,105,170,58);
    [_talkButton setTitle:@"Konuş" forState:UIControlStateNormal];
    _talkButton.titleLabel.font=[UIFont boldSystemFontOfSize:22];
    [_talkButton addTarget:self action:@selector(toggleTalking) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:_talkButton];
}

- (void)buildDecorButton {
    _decorButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _decorButton.frame=CGRectMake(565,175,170,50);
    [_decorButton setTitle:@"Oda" forState:UIControlStateNormal];
    [_decorButton addTarget:self action:@selector(openDecor) forControlEvents:UIControlEventTouchUpInside];
    [_backgroundView addSubview:_decorButton];
}

- (void)openDecor {
    RoomDecorViewController *d=[[[RoomDecorViewController alloc] init] autorelease];
    [self presentModalViewController:d animated:YES];
}

- (void)outfitChanged { [_accessoryView reloadSelectedOutfit]; }

- (void)applyRoomTheme {
    NSInteger t=[[NSUserDefaults standardUserDefaults] integerForKey:@"room.theme"];
    if(t==0) _themeOverlay.backgroundColor=[UIColor clearColor];
    else if(t==1) _themeOverlay.backgroundColor=[UIColor colorWithRed:1 green:0.35 blue:0.65 alpha:0.07];
    else if(t==2) _themeOverlay.backgroundColor=[UIColor colorWithRed:0.08 green:0.12 blue:0.30 alpha:0.14];
    else _themeOverlay.backgroundColor=[UIColor colorWithRed:1.0 green:0.65 blue:0.15 alpha:0.08];
}

- (void)toggleTalking {
    if(!_audio.recording) {
        if([_audio startRecording]) {
            [_talkButton setTitle:@"Bitir / Tekrarla" forState:UIControlStateNormal];
            [self showSpeech:@"Seni dinliyorum..."];
        } else [self showMessage:@"Mikrofon başlatılamadı."];
    } else {
        [_talkButton setTitle:@"Konuş" forState:UIControlStateNormal];
        [self showSpeech:@"Şimdi seni taklit ediyorum!"];
        [_animator setTalking:YES];
        [_audio stopAndRepeat];
        [_progress addXP:3];
        [self refreshUI];
    }
}

- (void)petAudioDidFinishRepeat {
    [_animator setTalking:NO];
    [self showSpeech:@"Bir daha konuşalım mı?"];
}

- (void)actionTapped:(UIButton *)sender {
    switch(sender.tag) {
        case 1: {
            FoodViewController *f=[[[FoodViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
            [self presentModalViewController:f animated:YES]; break;
        }
        case 2: {
            BathViewController *b=[[[BathViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
            [self presentModalViewController:b animated:YES]; break;
        }
        case 3: {
            SleepViewController *s=[[[SleepViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
            [self presentModalViewController:s animated:YES]; break;
        }
        case 4: {
            GameMenuViewController *g=[[[GameMenuViewController alloc] initWithProgressManager:_progress] autorelease];
            [self presentModalViewController:g animated:YES]; break;
        }
        case 5: {
            WardrobeViewController *w=[[[WardrobeViewController alloc] initWithProgressManager:_progress] autorelease];
            [self presentModalViewController:w animated:YES]; break;
        }
        case 20:
            [_progress addXP:1]; [self showSpeech:@"Başımı okşaman hoşuma gitti!"];
            [_animator happy]; break;
        case 21:
            [_progress addXP:1]; [self showSpeech:@"Hihi, gıdıklanıyorum!"];
            [_animator touchReaction]; break;
        case 22:
            [self showSpeech:@"Ayaklarım biraz hassas!"];
            [_animator touchReaction]; break;
    }
    [self refreshUI];
}

- (void)refreshUI {
    _hungerBar.progress=_needs.hunger/100.0f;
    _happinessBar.progress=_needs.happiness/100.0f;
    _hygieneBar.progress=_needs.hygiene/100.0f;
    _energyBar.progress=_needs.energy/100.0f;
    _coinLabel.text=[NSString stringWithFormat:@"Coin: %ld",(long)_progress.coins];
    _levelLabel.text=[NSString stringWithFormat:@"Seviye %ld",(long)_progress.level];
    NSInteger needed=[_progress xpNeededForNextLevel];
    _xpBar.progress=needed>0?((float)_progress.xp/(float)needed):0;
}

- (void)showSpeech:(NSString *)text {
    _speechLabel.text=text; _speechLabel.hidden=NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSpeech) object:nil];
    [self performSelector:@selector(hideSpeech) withObject:nil afterDelay:2.4];
}
- (void)hideSpeech { _speechLabel.hidden=YES; }

- (void)showMessage:(NSString *)message {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Pati" message:message delegate:nil
                                       cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)runDecay { [_needs applyMinuteDecay]; [self refreshUI]; }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUI]; [_accessoryView reloadSelectedOutfit]; [self applyRoomTheme];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o==UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_decayTimer invalidate]; [_decayTimer release];
    [_animator stop]; [_animator release];
    [_audio stopAll]; [_audio release];
    [_progress release]; [_needs release];
    [_talkButton release]; [_decorButton release];
    [_speechLabel release]; [_coinLabel release]; [_levelLabel release];
    [_hungerBar release]; [_happinessBar release]; [_hygieneBar release]; [_energyBar release]; [_xpBar release];
    [_accessoryView release]; [_themeOverlay release]; [_backgroundView release];
    [super dealloc];
}
@end
