#import "GameMenuViewController.h"
#import "PetProgressManager.h"
#import "MiniGameViewController.h"
#import "BubbleGameViewController.h"

@implementation GameMenuViewController

- (id)initWithProgressManager:(PetProgressManager *)progress {
    self = [super init];
    if (self) _progress = [progress retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.93 green:0.90 blue:1 alpha:1];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(40,50,688,60)] autorelease];
    title.text = @"Mini Oyunlar";
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:36];
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    UIButton *pati = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    pati.frame = CGRectMake(135,240,498,110);
    [pati setTitle:@"Pati Yakala" forState:UIControlStateNormal];
    pati.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [pati addTarget:self action:@selector(openPati) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pati];

    UIButton *bubble = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bubble.frame = CGRectMake(135,400,498,110);
    [bubble setTitle:@"Baloncuk Patlat" forState:UIControlStateNormal];
    bubble.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    [bubble addTarget:self action:@selector(openBubble) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bubble];

    UILabel *coming = [[[UILabel alloc] initWithFrame:CGRectMake(135,570,498,150)] autorelease];
    coming.text = @"Sonraki oyunlar:\nHafıza Kartları • Yemek Yakala • Labirent";
    coming.numberOfLines = 3;
    coming.textAlignment = UITextAlignmentCenter;
    coming.backgroundColor = [UIColor colorWithWhite:1 alpha:0.55];
    coming.font = [UIFont systemFontOfSize:22];
    [self.view addSubview:coming];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (void)openPati {
    MiniGameViewController *m = [[[MiniGameViewController alloc] initWithProgressManager:_progress] autorelease];
    [self presentModalViewController:m animated:YES];
}

- (void)openBubble {
    BubbleGameViewController *b = [[[BubbleGameViewController alloc] initWithProgressManager:_progress] autorelease];
    [self presentModalViewController:b animated:YES];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_progress release];
    [super dealloc];
}
@end
