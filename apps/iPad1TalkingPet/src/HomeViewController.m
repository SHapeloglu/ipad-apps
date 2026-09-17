#import "HomeViewController.h"
#import "PetNeedsManager.h"
#import "PetProgressManager.h"
#import "RoomBackgroundView.h"
#import "PetCharacterView.h"
#import "WardrobeViewController.h"
#import "RoomDecorViewController.h"
#import "FoodViewController.h"
#import "BathViewController.h"
#import "SleepViewController.h"
#import "GameMenuViewController.h"
#import "PhotoAlbumViewController.h"
#import "TravelViewController.h"
#import "AchievementsViewController.h"
#import "AchievementManager.h"
#import "SoundManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];

    _needs=[[PetNeedsManager alloc] init];
    _progress=[[PetProgressManager alloc] init];
    _audio=[[PetAudioManager alloc] init];
    _audio.delegate=self;

    _roomView=[[RoomBackgroundView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_roomView];

    // Real separated transparent character layer.
    _petView=[[PetCharacterView alloc] initWithFrame:CGRectMake(185,205,400,610)];
    [_roomView addSubview:_petView];
    [_petView startIdle];

    [self buildStatus];
    [self buildTopActions];
    [self buildBottomMenu];
    [self buildPetTouchZones];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outfitChanged)
                                                 name:@"WardrobeChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomChanged)
                                                 name:@"RoomThemeChanged" object:nil];

    [[AchievementManager sharedManager] resetDailyIfNeeded];
    [[SoundManager sharedManager] startMusic];

    if([_progress claimDailyRewardIfAvailable])
        [self showMessage:@"Günlük ödül: 50 coin + 10 XP!"];

    [self refreshUI];
    _decayTimer=[[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(runDecay)
                                                userInfo:nil repeats:YES] retain];
}

- (UILabel *)panelLabel:(CGRect)frame {
    UILabel *l=[[[UILabel alloc] initWithFrame:frame] autorelease];
    l.backgroundColor=[UIColor colorWithWhite:1 alpha:0.82];
    l.textAlignment=UITextAlignmentCenter;
    l.layer.cornerRadius=10;
    return l;
}

- (void)buildStatus {
    _hungerBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _happinessBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _hygieneBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _energyBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _xpBar=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];

    NSArray *names=[NSArray arrayWithObjects:@"Açlık",@"Mutluluk",@"Hijyen",@"Enerji",nil];
    NSArray *bars=[NSArray arrayWithObjects:_hungerBar,_happinessBar,_hygieneBar,_energyBar,nil];
    for(NSInteger i=0;i<4;i++){
        UILabel *n=[self panelLabel:CGRectMake(25+i*185,25,175,32)];
        n.text=[names objectAtIndex:i];
        n.font=[UIFont boldSystemFontOfSize:15];
        [_roomView addSubview:n];
        UIProgressView *b=[bars objectAtIndex:i];
        b.frame=CGRectMake(40+i*185,62,145,10);
        [_roomView addSubview:b];
    }

    _coinLabel=[[self panelLabel:CGRectMake(25,90,150,38)] retain];
    _levelLabel=[[self panelLabel:CGRectMake(185,90,150,38)] retain];
    _coinLabel.font=[UIFont boldSystemFontOfSize:18];
    _levelLabel.font=[UIFont boldSystemFontOfSize:18];
    [_roomView addSubview:_coinLabel]; [_roomView addSubview:_levelLabel];

    _xpBar.frame=CGRectMake(350,105,180,10);
    [_roomView addSubview:_xpBar];

    _speechLabel=[[self panelLabel:CGRectMake(235,145,300,50)] retain];
    _speechLabel.hidden=YES;
    _speechLabel.font=[UIFont boldSystemFontOfSize:17];
    [_roomView addSubview:_speechLabel];
}

- (UIButton *)button:(NSString *)title frame:(CGRect)frame selector:(SEL)sel {
    UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.frame=frame;
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [_roomView addSubview:b];
    return b;
}

- (void)buildTopActions {
    _talkButton=[[self button:@"Konuş" frame:CGRectMake(570,90,165,48) selector:@selector(toggleTalking)] retain];
    [self button:@"Kamera" frame:CGRectMake(570,145,165,45) selector:@selector(takePhoto)];
    [self button:@"Albüm" frame:CGRectMake(570,195,80,42) selector:@selector(openAlbum)];
    [self button:@"Seyahat" frame:CGRectMake(655,195,80,42) selector:@selector(openTravel)];
    [self button:@"Görevler" frame:CGRectMake(570,242,165,42) selector:@selector(openAchievements)];
}

- (void)buildBottomMenu {
    NSArray *titles=[NSArray arrayWithObjects:@"Yemek",@"Banyo",@"Uyku",@"Oyun",@"Gardırop",@"Oda",nil];
    SEL sels[6]={@selector(openFood),@selector(openBath),@selector(openSleep),@selector(openGames),
                 @selector(openWardrobe),@selector(openDecor)};
    CGFloat start=18, gap=8, width=116;
    for(NSInteger i=0;i<6;i++)
        [self button:[titles objectAtIndex:i] frame:CGRectMake(start+i*(width+gap),920,width,70) selector:sels[i]];
}

- (void)buildPetTouchZones {
    UIButton *head=[UIButton buttonWithType:UIButtonTypeCustom];
    head.frame=CGRectMake(255,245,250,190);
    [head addTarget:self action:@selector(touchHead) forControlEvents:UIControlEventTouchUpInside];
    [_roomView addSubview:head];

    UIButton *body=[UIButton buttonWithType:UIButtonTypeCustom];
    body.frame=CGRectMake(250,440,260,230);
    [body addTarget:self action:@selector(touchBody) forControlEvents:UIControlEventTouchUpInside];
    [_roomView addSubview:body];

    UIButton *feet=[UIButton buttonWithType:UIButtonTypeCustom];
    feet.frame=CGRectMake(245,680,270,145);
    [feet addTarget:self action:@selector(touchFeet) forControlEvents:UIControlEventTouchUpInside];
    [_roomView addSubview:feet];
}

- (void)touchHead { [[SoundManager sharedManager] play:@"tap"]; [_petView touchHead]; [_progress addXP:1]; [self speak:@"Başımı okşaman hoşuma gitti!"]; [self refreshUI]; }
- (void)touchBody { [[SoundManager sharedManager] play:@"tap"]; [_petView touchBody]; [_progress addXP:1]; [self speak:@"Hihi, gıdıklanıyorum!"]; [self refreshUI]; }
- (void)touchFeet { [[SoundManager sharedManager] play:@"tap"]; [_petView touchFeet]; [self speak:@"Ayaklarım hassas!"]; }

- (void)toggleTalking {
    if(!_audio.recording) {
        if([_audio startRecording]) {
            [_talkButton setTitle:@"Bitir / Tekrarla" forState:UIControlStateNormal];
            [self speak:@"Seni dinliyorum..."];
        } else [self showMessage:@"Mikrofon başlatılamadı."];
    } else {
        [_talkButton setTitle:@"Konuş" forState:UIControlStateNormal];
        [_petView setTalking:YES];
        [self speak:@"Şimdi seni taklit ediyorum!"];
        [_audio stopAndRepeat];
        [_progress addXP:3];
        [[AchievementManager sharedManager] increment:@"talk" amount:1];
        [self refreshUI];
    }
}

- (void)petAudioDidFinishRepeat { [_petView setTalking:NO]; [self speak:@"Bir daha konuşalım mı?"]; }

- (void)openFood {
    FoodViewController *v=[[[FoodViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
    [self presentModalViewController:v animated:YES];
}
- (void)openBath {
    BathViewController *v=[[[BathViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
    [self presentModalViewController:v animated:YES];
}
- (void)openSleep {
    SleepViewController *v=[[[SleepViewController alloc] initWithNeeds:_needs progress:_progress] autorelease];
    [self presentModalViewController:v animated:YES];
}
- (void)openGames {
    GameMenuViewController *v=[[[GameMenuViewController alloc] initWithProgressManager:_progress] autorelease];
    [self presentModalViewController:v animated:YES];
}
- (void)openWardrobe {
    WardrobeViewController *v=[[[WardrobeViewController alloc] initWithProgressManager:_progress] autorelease];
    [self presentModalViewController:v animated:YES];
}
- (void)openDecor {
    RoomDecorViewController *v=[[[RoomDecorViewController alloc] init] autorelease];
    [self presentModalViewController:v animated:YES];
}
- (void)openAlbum {
    PhotoAlbumViewController *v=[[[PhotoAlbumViewController alloc] init] autorelease];
    [self presentModalViewController:v animated:YES];
}
- (void)openAchievements {
    AchievementsViewController *v=[[[AchievementsViewController alloc] init] autorelease];
    [self presentModalViewController:v animated:YES];
}

- (void)openTravel {
    TravelViewController *v=[[[TravelViewController alloc] initWithProgressManager:_progress] autorelease];
    [self presentModalViewController:v animated:YES];
}

- (NSString *)albumDirectory {
    NSString *docs=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *dir=[docs stringByAppendingPathComponent:@"Album"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

- (void)takePhoto {
    UIGraphicsBeginImageContextWithOptions(_roomView.bounds.size, YES, 1.0);
    [_roomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *im=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *data=UIImagePNGRepresentation(im);
    NSString *fn=[NSString stringWithFormat:@"pati_%0.f.png",[[NSDate date] timeIntervalSince1970]];
    [data writeToFile:[[self albumDirectory] stringByAppendingPathComponent:fn] atomically:YES];
    [[SoundManager sharedManager] play:@"photo"];
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"daily.photo"]+1 forKey:@"daily.photo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_progress addXP:5];
    [self showMessage:@"Fotoğraf albüme kaydedildi. +5 XP"];
    [self refreshUI];
}

- (void)outfitChanged { [_petView reloadOutfit]; }
- (void)roomChanged { [_roomView reloadTheme]; }

- (void)refreshUI {
    static NSInteger lastLevel = -1;
    if(lastLevel < 0) lastLevel = _progress.level;
    else if(_progress.level > lastLevel) {
        [[SoundManager sharedManager] play:@"level"];
        [self showMessage:[NSString stringWithFormat:@"Seviye %ld! Tebrikler!",(long)_progress.level]];
        lastLevel = _progress.level;
    }
    _hungerBar.progress=_needs.hunger/100.0f;
    _happinessBar.progress=_needs.happiness/100.0f;
    _hygieneBar.progress=_needs.hygiene/100.0f;
    _energyBar.progress=_needs.energy/100.0f;
    _coinLabel.text=[NSString stringWithFormat:@"Coin: %ld",(long)_progress.coins];
    _levelLabel.text=[NSString stringWithFormat:@"Seviye %ld",(long)_progress.level];
    NSInteger needed=[_progress xpNeededForNextLevel];
    _xpBar.progress=needed>0?((float)_progress.xp/(float)needed):0;
}

- (void)speak:(NSString *)text {
    _speechLabel.text=text; _speechLabel.hidden=NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSpeech) object:nil];
    [self performSelector:@selector(hideSpeech) withObject:nil afterDelay:2.3];
}
- (void)hideSpeech { _speechLabel.hidden=YES; }

- (void)showMessage:(NSString *)message {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Pati" message:message delegate:nil
                                       cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)runDecay {
    [_needs applyMinuteDecay];
    if(_needs.hunger<20 || _needs.energy<20) [_petView sad];
    [self refreshUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_petView reloadOutfit];
    [_roomView reloadTheme];
    [self refreshUI];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_decayTimer invalidate]; [_decayTimer release];
    [_petView stop]; [_petView release];
    [_audio stopAll]; [_audio release];
    [_needs release]; [_progress release];
    [_hungerBar release]; [_happinessBar release]; [_hygieneBar release]; [_energyBar release]; [_xpBar release];
    [_coinLabel release]; [_levelLabel release]; [_speechLabel release]; [_talkButton release];
    [_roomView release];
    [super dealloc];
}

@end
