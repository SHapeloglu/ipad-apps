#import "GameMenuViewController.h"
#import "PetProgressManager.h"
#import "MiniGameViewController.h"
#import "BubbleGameViewController.h"
#import "MemoryGameViewController.h"
#import "FoodCatchViewController.h"

@implementation GameMenuViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self=[super init]; if(self) _progress=[progress retain]; return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.93 green:0.90 blue:1 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(40,45,688,60)] autorelease];
    title.text=@"Mini Oyunlar"; title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:36]; title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    NSArray *names=[NSArray arrayWithObjects:@"Pati Yakala",@"Baloncuk Patlat",@"Hafıza Kartları",@"Yemek Yakala",nil];
    for(NSInteger i=0;i<4;i++){
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.frame=CGRectMake(135,160+i*155,498,105);
        b.tag=400+i;
        [b setTitle:[names objectAtIndex:i] forState:UIControlStateNormal];
        b.titleLabel.font=[UIFont boldSystemFontOfSize:28];
        [b addTarget:self action:@selector(openGame:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    UILabel *coming=[[[UILabel alloc] initWithFrame:CGRectMake(135,790,498,80)] autorelease];
    coming.text=@"Sonraki: Labirent • Topu Sepete At";
    coming.textAlignment=UITextAlignmentCenter; coming.backgroundColor=[UIColor colorWithWhite:1 alpha:0.55];
    [self.view addSubview:coming];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55); [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)openGame:(UIButton *)b {
    UIViewController *vc=nil;
    NSInteger i=b.tag-400;
    if(i==0) vc=[[[MiniGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==1) vc=[[[BubbleGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==2) vc=[[[MemoryGameViewController alloc] initWithProgressManager:_progress] autorelease];
    else if(i==3) vc=[[[FoodCatchViewController alloc] initWithProgressManager:_progress] autorelease];
    if(vc) [self presentModalViewController:vc animated:YES];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }
- (void)dealloc { [_progress release]; [super dealloc]; }
@end
