#import "GameMenuViewController.h"
#import "PetProgressManager.h"
#import "MiniGameViewController.h"
#import "BubbleGameViewController.h"
#import "MemoryGameViewController.h"
#import "FoodCatchViewController.h"
#import "MazeGameViewController.h"
#import "BasketGameViewController.h"
#import "RunnerGameViewController.h"
#import "MatchGameViewController.h"
#import "AchievementManager.h"
#import "SoundManager.h"
#import "ScoresViewController.h"

@implementation GameMenuViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init]; if(self) _progress=[progress retain]; return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.93 green:0.90 blue:1 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(40,25,688,55)] autorelease];
    title.text=@"Mini Oyunlar (8)";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:34];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    NSArray *names=[NSArray arrayWithObjects:@"Pati Yakala",@"Baloncuk Patlat",@"Hafıza Kartları",@"Yemek Yakala",
                    @"Labirent",@"Topu Sepete At",@"Koşu",@"Eşleştir",nil];

    for(NSInteger i=0;i<8;i++){
        NSInteger row=i/2,col=i%2;
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.frame=CGRectMake(80+col*330,115+row*190,278,135);
        b.tag=400+i;
        [b setTitle:[names objectAtIndex:i] forState:UIControlStateNormal];
        b.titleLabel.font=[UIFont boldSystemFontOfSize:22];
        [b addTarget:self action:@selector(openGame:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    UIButton *scores=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    scores.frame=CGRectMake(555,930,180,55);
    [scores setTitle:@"Rekorlar" forState:UIControlStateNormal];
    [scores addTarget:self action:@selector(openScores) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scores];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)openGame:(UIButton *)b {
    UIViewController *vc=nil; NSInteger i=b.tag-400;
    if(i==0) vc=[[[MiniGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==1) vc=[[[BubbleGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==2) vc=[[[MemoryGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==3) vc=[[[FoodCatchViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==4) vc=[[[MazeGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==5) vc=[[[BasketGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==6) vc=[[[RunnerGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==7) vc=[[[MatchGameViewController alloc] initWithProgressManager:_progress] autorelease];

    if(vc) {
        [[SoundManager sharedManager] play:@"game"];
        [[AchievementManager sharedManager] increment:@"game" amount:1];
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        [ud setInteger:[ud integerForKey:@"daily.game"]+1 forKey:@"daily.game"];
        [ud synchronize];
        [self presentModalViewController:vc animated:YES];
    }
}

- (void)openScores {
    ScoresViewController *v=[[[ScoresViewController alloc] init] autorelease];
    [self presentModalViewController:v animated:YES];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }
- (void)dealloc { [_progress release]; [super dealloc]; }
@end
