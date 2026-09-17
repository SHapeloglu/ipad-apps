#import "FoodViewController.h"
#import "PetNeedsManager.h"
#import "PetProgressManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation FoodViewController

- (id)initWithNeeds:(PetNeedsManager *)needs progress:(PetProgressManager *)progress {
    self = [super init];
    if (self) { _needs=[needs retain]; _progress=[progress retain]; }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.94 blue:0.86 alpha:1.0];
    _selectedFood = 0;

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(40,25,688,50)] autorelease];
    title.text=@"Yemek"; title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:34]; title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    UILabel *cat = [[[UILabel alloc] initWithFrame:CGRectMake(235,120,298,285)] autorelease];
    cat.text=@"PATI"; cat.font=[UIFont boldSystemFontOfSize:70];
    cat.textAlignment=UITextAlignmentCenter; cat.backgroundColor=[UIColor colorWithWhite:1 alpha:0.65];
    cat.layer.cornerRadius=40; [self.view addSubview:cat];

    _mouthTarget=[[UIView alloc] initWithFrame:CGRectMake(337,315,95,68)];
    _mouthTarget.backgroundColor=[UIColor colorWithRed:1 green:0.70 blue:0.70 alpha:0.45];
    _mouthTarget.layer.cornerRadius=28; [self.view addSubview:_mouthTarget];

    NSArray *foods=[NSArray arrayWithObjects:@"Elma",@"Muz",@"Havuç",@"Tavuk",@"Pasta",@"Süt",nil];
    for (NSInteger i=0;i<6;i++) {
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        NSInteger row=i/3, col=i%3;
        b.frame=CGRectMake(80+col*210,470+row*85,190,65);
        b.tag=300+i;
        [b setTitle:[foods objectAtIndex:i] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(selectFood:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
    }

    _foodButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _foodButton.frame=CGRectMake(284,680,200,90);
    [_foodButton setTitle:@"ELMA" forState:UIControlStateNormal];
    _foodButton.titleLabel.font=[UIFont boldSystemFontOfSize:26];
    [_foodButton addTarget:self action:@selector(foodDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [_foodButton addTarget:self action:@selector(foodDrop:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.view addSubview:_foodButton]; _foodHome=_foodButton.center;

    _statusLabel=[[UILabel alloc] initWithFrame:CGRectMake(75,805,618,75)];
    _statusLabel.textAlignment=UITextAlignmentCenter;
    _statusLabel.numberOfLines=2;
    _statusLabel.backgroundColor=[UIColor colorWithWhite:1 alpha:0.72];
    [self.view addSubview:_statusLabel];

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55); [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    [self refreshStatus];
}

- (void)selectFood:(UIButton *)b {
    _selectedFood=b.tag-300;
    NSArray *foods=[NSArray arrayWithObjects:@"ELMA",@"MUZ",@"HAVUÇ",@"TAVUK",@"PASTA",@"SÜT",nil];
    [_foodButton setTitle:[foods objectAtIndex:_selectedFood] forState:UIControlStateNormal];
}

- (void)foodDrag:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *t=[[event allTouches] anyObject];
    sender.center=[t locationInView:self.view];
}

- (void)foodDrop:(UIButton *)sender withEvent:(UIEvent *)event {
    if (CGRectIntersectsRect(sender.frame,_mouthTarget.frame)) {
        NSInteger costs[6]={5,6,5,12,18,7};
        NSInteger xp[6]={3,3,3,5,6,3};
        if ([_progress spendCoins:costs[_selectedFood]]) {
            [_needs feed];
            [_progress addXP:xp[_selectedFood]];
            _statusLabel.text=[NSString stringWithFormat:@"Afiyet olsun! +%ld XP",(long)xp[_selectedFood]];
        } else {
            _statusLabel.text=@"Yeterli coin yok.";
        }
    } else {
        _statusLabel.text=@"Yemeği ağız bölgesine bırak.";
    }
    [UIView animateWithDuration:0.22 animations:^{ sender.center=_foodHome; }];
    [self refreshStatus];
}

- (void)refreshStatus {
    _statusLabel.text=[NSString stringWithFormat:@"Açlık: %ld/100   Coin: %ld",
                       (long)_needs.hunger,(long)_progress.coins];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }

- (void)dealloc {
    [_mouthTarget release]; [_foodButton release]; [_statusLabel release];
    [_needs release]; [_progress release]; [super dealloc];
}
@end
