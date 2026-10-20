#import "TravelViewController.h"
#import "PetProgressManager.h"
#import "AchievementManager.h"
#import "SoundManager.h"

@implementation TravelViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init]; if(self) _progress=[progress retain]; return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.77 green:0.92 blue:1 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,30,708,60)] autorelease];
    title.text=@"Pati'nin Seyahat Haritası";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:32];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    NSArray *places=[NSArray arrayWithObjects:@"Plaj",@"Orman",@"Şehir",@"Karlı Dağ",nil];
    for(NSInteger i=0;i<4;i++){
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.frame=CGRectMake(150,180+i*150,468,100);
        b.tag=700+i;
        [b setTitle:[NSString stringWithFormat:@"%@  (%ld coin)",[places objectAtIndex:i],(long)(40+i*20)]
           forState:UIControlStateNormal];
        b.titleLabel.font=[UIFont boldSystemFontOfSize:26];
        [b addTarget:self action:@selector(travel:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    _status=[[UILabel alloc] initWithFrame:CGRectMake(90,800,588,80)];
    _status.numberOfLines=2;
    _status.textAlignment=UITextAlignmentCenter;
    _status.backgroundColor=[UIColor colorWithWhite:1 alpha:0.65];
    [self.view addSubview:_status];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)travel:(UIButton *)b {
    NSInteger i=b.tag-700;
    NSInteger cost=40+i*20;
    if(![_progress spendCoins:cost]) {
        _status.text=@"Yeterli coin yok.";
        return;
    }
    [_progress addXP:10+i*5];
    [[SoundManager sharedManager] play:@"coin"];
    [[AchievementManager sharedManager] increment:@"travel" amount:1];
    [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"travel.lastPlace"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _status.text=[NSString stringWithFormat:@"Gezi tamamlandı! +%ld XP",(long)(10+i*5)];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }
- (void)dealloc { [_progress release]; [_status release]; [super dealloc]; }

@end
