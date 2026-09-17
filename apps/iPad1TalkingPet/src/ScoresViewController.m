#import "ScoresViewController.h"
#import "HighScoreManager.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/QuartzCore.h>

@implementation ScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.92 green:0.97 blue:1 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,30,708,55)] autorelease];
    title.text=@"Rekorlar";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:32];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    NSArray *names=[NSArray arrayWithObjects:
                    @"Pati Yakala",@"Baloncuk Patlat",@"Hafıza Kartları",@"Yemek Yakala",
                    @"Labirent",@"Topu Sepete At",@"Koşu",@"Eşleştir",nil];
    NSArray *keys=[NSArray arrayWithObjects:
                   @"paw",@"bubble",@"memory",@"foodcatch",
                   @"maze",@"basket",@"runner",@"match",nil];

    for(NSInteger i=0;i<8;i++){
        NSInteger row=i/2,col=i%2;
        UIView *card=[[[UIView alloc] initWithFrame:CGRectMake(55+col*355,125+row*180,300,135)] autorelease];
        card.backgroundColor=[UIColor colorWithWhite:1 alpha:0.78];
        card.layer.cornerRadius=15;
        [self.view addSubview:card];

        UILabel *n=[[[UILabel alloc] initWithFrame:CGRectMake(15,15,270,45)] autorelease];
        n.text=[names objectAtIndex:i];
        n.font=[UIFont boldSystemFontOfSize:20];
        n.backgroundColor=[UIColor clearColor];
        [card addSubview:n];

        NSInteger hs=[[HighScoreManager sharedManager] highScoreForGame:[keys objectAtIndex:i]];
        UILabel *s=[[[UILabel alloc] initWithFrame:CGRectMake(15,67,270,42)] autorelease];
        s.text=[NSString stringWithFormat:@"En iyi: %ld",(long)hs];
        s.font=[UIFont systemFontOfSize:19];
        s.backgroundColor=[UIColor clearColor];
        [card addSubview:s];
    }

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o==UIInterfaceOrientationPortrait;
}
@end
