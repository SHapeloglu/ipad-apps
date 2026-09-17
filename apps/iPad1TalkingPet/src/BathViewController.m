#import "BathViewController.h"
#import "PetNeedsManager.h"
#import "PetProgressManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation BathViewController

- (id)initWithNeeds:(PetNeedsManager *)needs progress:(PetProgressManager *)progress {
    self = [super init];
    if (self) {
        _needs = [needs retain];
        _progress = [progress retain];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.82 green:0.94 blue:1.0 alpha:1.0];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(40,30,688,55)] autorelease];
    title.text = @"Banyo";
    title.textAlignment = UITextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:34];
    title.backgroundColor = [UIColor clearColor];
    [self.view addSubview:title];

    _catArea = [[UIView alloc] initWithFrame:CGRectMake(220,160,330,460)];
    _catArea.backgroundColor = [UIColor colorWithWhite:1 alpha:0.55];
    _catArea.layer.cornerRadius = 45;
    [self.view addSubview:_catArea];

    UILabel *cat = [[[UILabel alloc] initWithFrame:_catArea.bounds] autorelease];
    cat.text = @"PATI";
    cat.textAlignment = UITextAlignmentCenter;
    cat.font = [UIFont boldSystemFontOfSize:70];
    cat.backgroundColor = [UIColor clearColor];
    [_catArea addSubview:cat];

    _soap = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _soap.frame = CGRectMake(80,700,220,90);
    [_soap setTitle:@"SABUN" forState:UIControlStateNormal];
    _soap.titleLabel.font = [UIFont boldSystemFontOfSize:26];
    [_soap addTarget:self action:@selector(soapDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside|UIControlEventTouchDragOutside];
    [_soap addTarget:self action:@selector(soapDrop:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.view addSubview:_soap];

    _shower = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _shower.frame = CGRectMake(468,700,220,90);
    [_shower setTitle:@"DUŞ" forState:UIControlStateNormal];
    _shower.titleLabel.font = [UIFont boldSystemFontOfSize:26];
    [_shower addTarget:self action:@selector(showerPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shower];

    _status = [[UILabel alloc] initWithFrame:CGRectMake(90,825,588,65)];
    _status.textAlignment = UITextAlignmentCenter;
    _status.numberOfLines = 2;
    _status.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    [self.view addSubview:_status];

    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    _soapRubCount = 0;
    _soapy = NO;
    [self refresh];
}

- (void)soapDrag:(UIButton *)sender withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    sender.center = [touch locationInView:self.view];
    if (CGRectIntersectsRect(sender.frame, _catArea.frame)) {
        _soapRubCount++;
        if (_soapRubCount >= 5) {
            _soapy = YES;
            _catArea.backgroundColor = [UIColor colorWithWhite:1 alpha:0.90];
            for (NSInteger i=0;i<10;i++) {
                UIView *bubble = [[[UIView alloc] initWithFrame:CGRectMake(20+(arc4random()%270),
                                                                          20+(arc4random()%390),
                                                                          20+(arc4random()%28),
                                                                          20+(arc4random()%28))] autorelease];
                bubble.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
                bubble.layer.cornerRadius = bubble.frame.size.width/2.0;
                bubble.tag = 909;
                [_catArea addSubview:bubble];
            }
            _status.text = @"Köpüklendi! Şimdi duşu kullan.";
        }
    }
}

- (void)soapDrop:(UIButton *)sender withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.2 animations:^{
        sender.frame = CGRectMake(80,700,220,90);
    }];
}

- (void)showerPressed {
    if (!_soapy) {
        _status.text = @"Önce sabunu kedinin üzerinde gezdir.";
        return;
    }
    [_needs bathe];
    [_progress addXP:6];
    _soapy = NO;
    _soapRubCount = 0;
    for (UIView *v in [[_catArea.subviews copy] autorelease]) {
        if (v.tag == 909) [v removeFromSuperview];
    }
    _catArea.backgroundColor = [UIColor colorWithWhite:1 alpha:0.55];
    _status.text = @"Temizlendin! +6 XP";
    [self refresh];
}

- (void)refresh {
    if (!_soapy)
        _status.text = [NSString stringWithFormat:@"Hijyen: %ld/100", (long)_needs.hygiene];
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o {
    return o == UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    [_catArea release];
    [_soap release];
    [_shower release];
    [_status release];
    [_needs release];
    [_progress release];
    [super dealloc];
}
@end
