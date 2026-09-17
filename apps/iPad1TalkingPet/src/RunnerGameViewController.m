#import "RunnerGameViewController.h"
#import "PetProgressManager.h"

@implementation RunnerGameViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init]; if(self) _progress=[progress retain]; return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.88 green:0.97 blue:1 alpha:1];

    _label=[[UILabel alloc] initWithFrame:CGRectMake(30,35,708,55)];
    _label.textAlignment=UITextAlignmentCenter;
    _label.font=[UIFont boldSystemFontOfSize:25];
    _label.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_label];

    _runner=[[UIView alloc] initWithFrame:CGRectMake(90,720,70,70)];
    _runner.backgroundColor=[UIColor colorWithRed:0.95 green:0.35 blue:0.45 alpha:1];
    [self.view addSubview:_runner];

    _obstacle=[[UIView alloc] initWithFrame:CGRectMake(720,735,45,55)];
    _obstacle.backgroundColor=[UIColor colorWithRed:0.25 green:0.25 blue:0.3 alpha:1];
    [self.view addSubview:_obstacle];

    UIButton *jump=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    jump.frame=CGRectMake(280,840,210,70);
    [jump setTitle:@"ZIPLA" forState:UIControlStateNormal];
    [jump addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jump];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    _timer=[[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(tick) userInfo:nil repeats:YES] retain];
    [self update];
}

- (void)jump {
    if(_jumping) return;
    _jumping=YES;
    [UIView animateWithDuration:0.24 animations:^{
        CGRect f=_runner.frame; f.origin.y=610; _runner.frame=f;
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.28 animations:^{
            CGRect r=_runner.frame; r.origin.y=720; _runner.frame=r;
        } completion:^(BOOL f2){ _jumping=NO; }];
    }];
}

- (void)tick {
    CGRect o=_obstacle.frame; o.origin.x-=9; _obstacle.frame=o;
    if(CGRectIntersectsRect(_runner.frame,_obstacle.frame)) {
        [_timer invalidate];
        [_progress addCoins:_score*2];
        [_progress addXP:_score];
        _label.text=@"Çarptın! Oyun bitti.";
        return;
    }
    if(CGRectGetMaxX(_obstacle.frame)<0) {
        _score++;
        _obstacle.frame=CGRectMake(720,735,45,55);
        [self update];
    }
}

- (void)update { _label.text=[NSString stringWithFormat:@"Koşu Puanı: %ld",(long)_score]; }
- (void)goBack { [_timer invalidate]; [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }

- (void)dealloc {
    [_timer invalidate]; [_timer release];
    [_progress release]; [_runner release]; [_obstacle release]; [_label release];
    [super dealloc];
}
@end
