#import "MazeGameViewController.h"
#import "PetProgressManager.h"

@implementation MazeGameViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init]; if(self) _progress=[progress retain]; return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.90 green:1.0 blue:0.88 alpha:1];

    UILabel *t=[[[UILabel alloc] initWithFrame:CGRectMake(30,35,708,55)] autorelease];
    t.text=@"Mini Labirent"; t.textAlignment=UITextAlignmentCenter;
    t.font=[UIFont boldSystemFontOfSize:30]; t.backgroundColor=[UIColor clearColor];
    [self.view addSubview:t];

    _player=[[UIView alloc] initWithFrame:CGRectMake(80,170,45,45)];
    _player.backgroundColor=[UIColor colorWithRed:0.95 green:0.35 blue:0.50 alpha:1];
    [self.view addSubview:_player];

    UIView *goal=[[[UIView alloc] initWithFrame:CGRectMake(630,700,75,75)] autorelease];
    goal.tag=999; goal.backgroundColor=[UIColor colorWithRed:0.30 green:0.80 blue:0.30 alpha:1];
    [self.view addSubview:goal];

    NSArray *dirs=[NSArray arrayWithObjects:@"↑",@"↓",@"←",@"→",nil];
    SEL sels[4]={@selector(up),@selector(down),@selector(left),@selector(right)};
    for(NSInteger i=0;i<4;i++){
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.frame=CGRectMake(210+i*95,830,80,60);
        [b setTitle:[dirs objectAtIndex:i] forState:UIControlStateNormal];
        [b addTarget:self action:sels[i] forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    _status=[[UILabel alloc] initWithFrame:CGRectMake(120,760,528,55)];
    _status.text=@"Yeşil hedefe ulaş.";
    _status.textAlignment=UITextAlignmentCenter; _status.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_status];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55); [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)moveX:(CGFloat)x y:(CGFloat)y {
    CGRect f=_player.frame; f.origin.x+=x; f.origin.y+=y;
    if(f.origin.x<25) f.origin.x=25; if(f.origin.x>698) f.origin.x=698;
    if(f.origin.y<120) f.origin.y=120; if(f.origin.y>790) f.origin.y=790;
    _player.frame=f;
    UIView *goal=[self.view viewWithTag:999];
    if(CGRectIntersectsRect(_player.frame,goal.frame)) {
        [_progress addCoins:50]; [_progress addXP:25];
        _status.text=@"Başardın! +50 coin +25 XP";
        goal.hidden=YES;
    }
}
- (void)up{[self moveX:0 y:-35];}
- (void)down{[self moveX:0 y:35];}
- (void)left{[self moveX:-35 y:0];}
- (void)right{[self moveX:35 y:0];}
- (void)goBack{[self dismissModalViewControllerAnimated:YES];}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o{return o==UIInterfaceOrientationPortrait;}
- (void)dealloc{[_progress release];[_player release];[_status release];[super dealloc];}
@end
