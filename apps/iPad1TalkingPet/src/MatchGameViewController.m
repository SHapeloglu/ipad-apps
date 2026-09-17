#import "MatchGameViewController.h"
#import "PetProgressManager.h"

@implementation MatchGameViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init]; if(self) _progress=[progress retain]; return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:1 green:0.95 blue:0.88 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,35,708,55)] autorelease];
    title.text=@"Eşleştir";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:30];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    NSArray *vals=[NSArray arrayWithObjects:@"A",@"A",@"B",@"B",@"C",@"C",@"D",@"D",@"E",@"E",@"F",@"F",nil];
    NSMutableArray *sh=[NSMutableArray arrayWithArray:vals];
    for(NSInteger i=[sh count]-1;i>0;i--){NSInteger j=arc4random()%(i+1);[sh exchangeObjectAtIndex:i withObjectAtIndex:j];}

    for(NSInteger i=0;i<12;i++){
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSInteger row=i/4,col=i%4;
        b.frame=CGRectMake(40+col*180,150+row*180,150,130);
        b.tag=100+i;
        [b setTitle:[sh objectAtIndex:i] forState:UIControlStateNormal];
        b.titleLabel.font=[UIFont boldSystemFontOfSize:34];
        [b addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    _status=[[UILabel alloc] initWithFrame:CGRectMake(120,760,528,70)];
    _status.textAlignment=UITextAlignmentCenter;
    _status.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_status];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    [self update];
}

- (void)tap:(UIButton *)b {
    if(!b.enabled) return;
    b.enabled=NO;
    _score++;
    if(_score>=6) {
        [_progress addCoins:60];
        [_progress addXP:30];
        _status.text=@"Tamamlandı! +60 coin +30 XP";
    } else [self update];
}

- (void)update { _status.text=[NSString stringWithFormat:@"Eşleşme: %ld/6",(long)_score]; }
- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }
- (void)dealloc { [_progress release]; [_status release]; [super dealloc]; }
@end
