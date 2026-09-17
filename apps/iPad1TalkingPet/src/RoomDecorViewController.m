#import "RoomDecorViewController.h"

@implementation RoomDecorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.92 blue:0.86 alpha:1];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(30,40,708,60)] autorelease];
    title.text = @"Oda Dekorasyonu";
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:34];
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    NSArray *names = [NSArray arrayWithObjects:@"Klasik", @"Pembe", @"Gece", @"Sıcak", nil];
    for (NSInteger i=0;i<4;i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.frame = CGRectMake(150, 180+i*140, 468, 95);
        b.tag = 200+i;
        [b setTitle:[names objectAtIndex:i] forState:UIControlStateNormal];
        b.titleLabel.font = [UIFont boldSystemFontOfSize:26];
        [b addTarget:self action:@selector(selectTheme:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)selectTheme:(UIButton *)b {
    NSInteger theme = b.tag - 200;
    [[NSUserDefaults standardUserDefaults] setInteger:theme forKey:@"room.theme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RoomThemeChanged" object:nil];

    UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Oda"
                                                message:@"Tema seçildi."
                                               delegate:nil
                                      cancelButtonTitle:@"Tamam"
                                      otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}
@end
