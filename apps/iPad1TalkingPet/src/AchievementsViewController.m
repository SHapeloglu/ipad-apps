#import "AchievementsViewController.h"
#import "AchievementManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation AchievementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.95 green:0.94 blue:1 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,25,708,55)] autorelease];
    title.text=@"Görevler & Başarımlar";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:32];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    UILabel *dailyTitle=[[[UILabel alloc] initWithFrame:CGRectMake(50,95,668,40)] autorelease];
    dailyTitle.text=@"Günlük Görevler";
    dailyTitle.font=[UIFont boldSystemFontOfSize:24];
    dailyTitle.backgroundColor=[UIColor clearColor];
    [self.view addSubview:dailyTitle];

    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSArray *daily=[[AchievementManager sharedManager] dailyTaskRows];
    for(NSInteger i=0;i<[daily count];i++){
        NSDictionary *r=[daily objectAtIndex:i];
        NSInteger v=[ud integerForKey:[r objectForKey:@"key"]];
        NSInteger g=[[r objectForKey:@"goal"] integerValue];

        UILabel *l=[[[UILabel alloc] initWithFrame:CGRectMake(70,145+i*65,628,50)] autorelease];
        l.backgroundColor=[UIColor colorWithWhite:1 alpha:0.72];
        l.layer.cornerRadius=9;
        l.text=[NSString stringWithFormat:@"%@   %ld/%ld",[r objectForKey:@"title"],(long)v,(long)g];
        l.font=[UIFont systemFontOfSize:19];
        [self.view addSubview:l];
    }

    UILabel *achTitle=[[[UILabel alloc] initWithFrame:CGRectMake(50,430,668,40)] autorelease];
    achTitle.text=@"Rozetler";
    achTitle.font=[UIFont boldSystemFontOfSize:24];
    achTitle.backgroundColor=[UIColor clearColor];
    [self.view addSubview:achTitle];

    NSArray *rows=[[AchievementManager sharedManager] achievementRows];
    for(NSInteger i=0;i<[rows count];i++){
        NSDictionary *r=[rows objectAtIndex:i];
        NSInteger v=[[AchievementManager sharedManager] valueFor:[r objectForKey:@"key"]];
        NSInteger g=[[r objectForKey:@"goal"] integerValue];

        UIView *badge=[[[UIView alloc] initWithFrame:CGRectMake(70,485+i*78,62,62)] autorelease];
        badge.layer.cornerRadius=31;
        badge.backgroundColor=(v>=g)?[UIColor colorWithRed:1 green:0.78 blue:0.14 alpha:1]:
                                      [UIColor colorWithWhite:0.75 alpha:1];
        [self.view addSubview:badge];

        UILabel *n=[[[UILabel alloc] initWithFrame:CGRectMake(150,485+i*78,548,62)] autorelease];
        n.backgroundColor=[UIColor colorWithWhite:1 alpha:0.70];
        n.text=[NSString stringWithFormat:@"%@   %ld/%ld",[r objectForKey:@"title"],(long)v,(long)g];
        n.font=[UIFont systemFontOfSize:20];
        [self.view addSubview:n];
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
