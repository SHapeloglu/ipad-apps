#import "RoomDecorViewController.h"

@implementation RoomDecorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.96 green:0.92 blue:0.86 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,30,708,60)] autorelease];
    title.text=@"Oda & Mobilya";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:34];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    UILabel *themes=[[[UILabel alloc] initWithFrame:CGRectMake(50,120,668,45)] autorelease];
    themes.text=@"Oda Teması";
    themes.font=[UIFont boldSystemFontOfSize:24];
    themes.backgroundColor=[UIColor clearColor];
    [self.view addSubview:themes];

    NSArray *names=[NSArray arrayWithObjects:@"Klasik",@"Pembe",@"Gece",@"Sıcak",nil];
    for(NSInteger i=0;i<4;i++){
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.frame=CGRectMake(45+i*180,180,160,70);
        b.tag=200+i;
        [b setTitle:[names objectAtIndex:i] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(selectTheme:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    UILabel *f=[[[UILabel alloc] initWithFrame:CGRectMake(50,300,668,45)] autorelease];
    f.text=@"Mobilya Koleksiyonu";
    f.font=[UIFont boldSystemFontOfSize:24];
    f.backgroundColor=[UIColor clearColor];
    [self.view addSubview:f];

    NSArray *slots=[NSArray arrayWithObjects:@"Koltuk",@"Halı",@"Lamba",@"Dolap",@"Bitki",nil];
    for(NSInteger row=0;row<5;row++){
        UILabel *lab=[[[UILabel alloc] initWithFrame:CGRectMake(70,370+row*95,160,55)] autorelease];
        lab.text=[slots objectAtIndex:row];
        lab.font=[UIFont boldSystemFontOfSize:21];
        lab.backgroundColor=[UIColor clearColor];
        [self.view addSubview:lab];

        for(NSInteger col=0;col<2;col++){
            UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
            b.frame=CGRectMake(260+col*220,360+row*95,190,65);
            b.tag=500+row*10+col;
            [b setTitle:(col==0?@"Standart":@"Alternatif") forState:UIControlStateNormal];
            [b addTarget:self action:@selector(selectFurniture:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:b];
        }
    }

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)selectTheme:(UIButton *)b {
    [[NSUserDefaults standardUserDefaults] setInteger:b.tag-200 forKey:@"room.theme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RoomThemeChanged" object:nil];
}

- (void)selectFurniture:(UIButton *)b {
    NSInteger raw=b.tag-500;
    NSInteger slot=raw/10, option=raw%10;
    NSString *key=[NSString stringWithFormat:@"room.furniture.%ld",(long)slot];
    [[NSUserDefaults standardUserDefaults] setInteger:option forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RoomThemeChanged" object:nil];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }

@end
