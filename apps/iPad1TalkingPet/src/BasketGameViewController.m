#import "BasketGameViewController.h"
#import "PetProgressManager.h"

@implementation BasketGameViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init]; if(self) _progress=[progress retain]; return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:1.0 green:0.92 blue:0.80 alpha:1];

    UILabel *t=[[[UILabel alloc] initWithFrame:CGRectMake(30,35,708,55)] autorelease];
    t.text=@"Topu Sepete At"; t.textAlignment=UITextAlignmentCenter;
    t.font=[UIFont boldSystemFontOfSize:30]; t.backgroundColor=[UIColor clearColor];
    [self.view addSubview:t];

    _basket=[[UIView alloc] initWithFrame:CGRectMake(280,170,210,70)];
    _basket.backgroundColor=[UIColor colorWithRed:0.85 green:0.25 blue:0.15 alpha:1];
    [self.view addSubview:_basket];

    _ball=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _ball.frame=CGRectMake(325,690,120,120);
    [_ball setTitle:@"TOP" forState:UIControlStateNormal];
    [_ball addTarget:self action:@selector(drag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [_ball addTarget:self action:@selector(drop:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.view addSubview:_ball];

    _scoreLabel=[[UILabel alloc] initWithFrame:CGRectMake(220,300,328,60)];
    _scoreLabel.textAlignment=UITextAlignmentCenter; _scoreLabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_scoreLabel];
    [self update];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55); [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)drag:(UIButton *)b withEvent:(UIEvent *)e {
    UITouch *t=[[e allTouches] anyObject]; b.center=[t locationInView:self.view];
}
- (void)drop:(UIButton *)b withEvent:(UIEvent *)e {
    if(CGRectIntersectsRect(b.frame,_basket.frame)) {
        _score++; [_progress addCoins:5]; [_progress addXP:2];
    }
    [UIView animateWithDuration:0.25 animations:^{b.frame=CGRectMake(325,690,120,120);}];
    [self update];
}
- (void)update{_scoreLabel.text=[NSString stringWithFormat:@"Basket: %ld",(long)_score];}
- (void)goBack{[self dismissModalViewControllerAnimated:YES];}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o{return o==UIInterfaceOrientationPortrait;}
- (void)dealloc{[_progress release];[_ball release];[_basket release];[_scoreLabel release];[super dealloc];}
@end
