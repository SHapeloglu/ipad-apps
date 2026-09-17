#import "WardrobeViewController.h"
#import "PetProgressManager.h"

@implementation WardrobeViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init];
    if(self) _progress=[progress retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.98 green:0.90 blue:0.95 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,30,708,55)] autorelease];
    title.text=@"Gardırop 2.0";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:34];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    _coinLabel=[[UILabel alloc] initWithFrame:CGRectMake(520,95,190,40)];
    _coinLabel.textAlignment=UITextAlignmentCenter;
    _coinLabel.backgroundColor=[UIColor colorWithWhite:1 alpha:0.72];
    [self.view addSubview:_coinLabel];

    NSArray *sections=[NSArray arrayWithObjects:@"Şapka",@"Yüz",@"Tişört",@"Pantolon",@"Ayakkabı",nil];
    for(NSInteger row=0;row<5;row++){
        UILabel *lab=[[[UILabel alloc] initWithFrame:CGRectMake(55,170+row*135,150,45)] autorelease];
        lab.text=[sections objectAtIndex:row];
        lab.font=[UIFont boldSystemFontOfSize:22];
        lab.backgroundColor=[UIColor clearColor];
        [self.view addSubview:lab];

        for(NSInteger col=0;col<3;col++){
            UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            b.frame=CGRectMake(215+col*165,155+row*135,145,70);
            b.tag=1000 + row*10 + col;
            NSString *name = col==0 ? @"Yok" : (col==1 ? @"Stil 1" : @"Stil 2");
            [b setTitle:name forState:UIControlStateNormal];
            [b addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:b];
        }
    }

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    [self refresh];
}

- (NSString *)keyForRow:(NSInteger)row {
    if(row==0) return @"outfit.hat";
    if(row==1) return @"outfit.face";
    if(row==2) return @"outfit.shirt";
    if(row==3) return @"outfit.pants";
    return @"outfit.shoes";
}

- (void)selectItem:(UIButton *)b {
    NSInteger raw=b.tag-1000;
    NSInteger row=raw/10;
    NSInteger col=raw%10;
    NSInteger cost=(col==0)?0:(row==2?120:(row==4?140:100));

    NSString *owned=[NSString stringWithFormat:@"outfit.owned.%ld.%ld",(long)row,(long)col];
    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    if(col>0 && ![d boolForKey:owned]) {
        if(![_progress spendCoins:cost]) {
            UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Gardırop" message:@"Yeterli coin yok."
                                                      delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
            [a show]; return;
        }
        [d setBool:YES forKey:owned];
    }

    [d setInteger:col forKey:[self keyForRow:row]];
    [d synchronize];
    [_progress addXP:3];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WardrobeChanged" object:nil];
    [self refresh];
}

- (void)refresh { _coinLabel.text=[NSString stringWithFormat:@"Coin: %ld",(long)_progress.coins]; }
- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }

- (void)dealloc { [_progress release]; [_coinLabel release]; [super dealloc]; }
@end
