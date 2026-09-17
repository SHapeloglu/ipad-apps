#import "AchievementsViewController.h"
#import "AchievementManager.h"

@implementation AchievementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.95 green:0.94 blue:1 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,30,708,55)] autorelease];
    title.text=@"Görevler & Başarımlar";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:32];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    UILabel *d=[[[UILabel alloc] initWithFrame:CGRectMake(50,105,668,40)] autorelease];
    d.text=@"Günlük Görevler";
    d.font=[UIFont boldSystemFontOfSize:24];
    d.backgroundColor=[UIColor clearColor];
    [self.view addSubview:d];

    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSArray *daily=[[AchievementManager sharedManager] dailyTaskRows];
    for(NSInteger i=0;i<[daily count];i++) {
        NSDictionary *r=[daily objectAtIndex:i];
        NSInteger v=[ud integerForKey:[r objectForKey:@"key"]];
        NSInteger g=[[r objectForKey:@"goal"] integerValue];
        UILabel *l=[[[UILabel alloc] initWithFrame:CGRectMake(70,155+i*70,628,52)] autorelease];
        l.text=[NSString stringWithFormat:@"%@   %ld/%ld",[r objectForKey:@"title"],(long)v,(long)g];
        l.backgroundColor=[UIColor colorWithWhite:1 alpha:0.7];
        l.font=[UIFont systemFontOfSize:20];
        [self.view addSubview:l];
    }

    UILabel *a=[[[UILabel alloc] initWithFrame:CGRectMake(50,455,668,40)] autorelease];
    a.text=@"Başarımlar";
    a.font=[UIFont boldSystemFontOfSize:24];
    a.backgroundColor=[UIColor clearColor];
    [self.view addSubview:a];

    NSArray *rows=[[AchievementManager sharedManager] achievementRows];
    for(NSInteger i=0;i<[rows count];i++) {
        NSDictionary *r=[rows objectAtIndex:i];
        NSInteger v=[[AchievementManager sharedManager] valueFor:[r objectForKey:@"key"]];
        NSInteger g=[[r objectForKey:@"goal"] integerValue];
        UILabel *l=[[[UILabel alloc] initWithFrame:CGRectMake(70,505+i*70,628,52)] autorelease];
        l.text=[NSString stringWithFormat:@"%@   %ld/%ld",[r objectForKey:@"title"],(long)v,(long)g];
        l.backgroundColor=[UIColor colorWithWhite:1 alpha:0.7];
        l.font=[UIFont systemFontOfSize:20];
        [self.view addSubview:l];
    }

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }
@end
