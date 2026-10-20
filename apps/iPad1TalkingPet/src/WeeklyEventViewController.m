#import "WeeklyEventViewController.h"
#import "WeeklyEventManager.h"

@implementation WeeklyEventViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:1 green:0.95 blue:0.82 alpha:1];

    UILabel *t=[[[UILabel alloc] initWithFrame:CGRectMake(50,150,668,70)] autorelease];
    t.text=[[WeeklyEventManager sharedManager] todayEventTitle];
    t.textAlignment=UITextAlignmentCenter;
    t.font=[UIFont boldSystemFontOfSize:32];
    t.backgroundColor=[UIColor clearColor];
    [self.view addSubview:t];

    UILabel *d=[[[UILabel alloc] initWithFrame:CGRectMake(90,280,588,140)] autorelease];
    d.text=[[WeeklyEventManager sharedManager] todayEventDetail];
    d.numberOfLines=3;
    d.textAlignment=UITextAlignmentCenter;
    d.font=[UIFont systemFontOfSize:24];
    d.backgroundColor=[UIColor colorWithWhite:1 alpha:0.7];
    [self.view addSubview:d];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}
- (void)goBack {[self dismissModalViewControllerAnimated:YES];}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o{return o==UIInterfaceOrientationPortrait;}
@end
