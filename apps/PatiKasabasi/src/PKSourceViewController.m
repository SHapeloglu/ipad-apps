#import "PKSourceViewController.h"
#import "PKGameState.h"
#import "PKPetSelectionViewController.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation PKSourceViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Yavrun nereden gelsin?";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *heading = [self labelWithFrame:CGRectMake(100.0f, 25.0f, 824.0f, 55.0f)
                                       text:@"Yeni arkadaşınla nasıl tanışmak istersin?"
                                   fontSize:32.0f
                                       bold:YES];
    heading.textColor = [PKTheme darkTealColor];
    [self.view addSubview:heading];

    [self addChoicePanelWithFrame:CGRectMake(90.0f, 115.0f, 380.0f, 465.0f)
                            title:@"Barınaktan Sahiplen"
                         subtitle:@"Bir yavruya sıcak bir yuva ver. Sahiplenme ücretsizdir ve 500 pati parasıyla başlarsın."
                           symbol:@"YENİ BİR YUVA"
                     buttonTitle:@"Barınağa Git"
                              tag:0];

    [self addChoicePanelWithFrame:CGRectMake(554.0f, 115.0f, 380.0f, 465.0f)
                            title:@"Pet Shop'tan Al"
                         subtitle:@"Yavrun için bir başlangıç paketi seç. 200 pati parası öder, 300 pati parasıyla başlarsın."
                           symbol:@"OYUNCAK HEDİYE"
                     buttonTitle:@"Pet Shop'a Git"
                              tag:1];

    UILabel *note = [self labelWithFrame:CGRectMake(140.0f, 610.0f, 744.0f, 48.0f)
                                    text:@"Her iki seçimde de bütün yavrular eşit derecede sevgiye ve bakıma ihtiyaç duyar."
                                fontSize:17.0f
                                    bold:NO];
    [self.view addSubview:note];
}

- (void)addChoicePanelWithFrame:(CGRect)frame
                          title:(NSString *)title
                       subtitle:(NSString *)subtitle
                         symbol:(NSString *)symbol
                   buttonTitle:(NSString *)buttonTitle
                            tag:(NSInteger)tag {
    UIView *panel = [[[UIView alloc] initWithFrame:frame] autorelease];
    [PKTheme stylePanel:panel];
    [self.view addSubview:panel];

    UIView *circle = [[[UIView alloc] initWithFrame:CGRectMake(130.0f, 35.0f, 120.0f, 120.0f)] autorelease];
    circle.backgroundColor = tag == 0 ? [PKTheme mintColor] : [PKTheme coralColor];
    circle.layer.cornerRadius = 60.0f;
    [panel addSubview:circle];

    UILabel *paw = [self labelWithFrame:CGRectMake(10.0f, 28.0f, 100.0f, 65.0f)
                                   text:(tag == 0 ? @"♥" : @"★")
                               fontSize:48.0f
                                   bold:YES];
    paw.textColor = [UIColor whiteColor];
    [circle addSubview:paw];

    UILabel *titleLabel = [self labelWithFrame:CGRectMake(25.0f, 175.0f, 330.0f, 52.0f)
                                          text:title
                                      fontSize:27.0f
                                          bold:YES];
    titleLabel.textColor = [PKTheme darkTealColor];
    [panel addSubview:titleLabel];

    UILabel *detail = [self labelWithFrame:CGRectMake(35.0f, 230.0f, 310.0f, 100.0f)
                                      text:subtitle
                                  fontSize:18.0f
                                      bold:NO];
    [panel addSubview:detail];

    UILabel *badge = [self labelWithFrame:CGRectMake(80.0f, 335.0f, 220.0f, 30.0f)
                                     text:symbol
                                 fontSize:14.0f
                                     bold:YES];
    badge.textColor = tag == 0 ? [PKTheme darkTealColor] : [PKTheme coralColor];
    [panel addSubview:badge];

    UIButton *button = tag == 0
        ? [self secondaryButtonWithFrame:CGRectMake(65.0f, 380.0f, 250.0f, 60.0f) title:buttonTitle]
        : [self primaryButtonWithFrame:CGRectMake(65.0f, 380.0f, 250.0f, 60.0f) title:buttonTitle];
    button.tag = tag;
    [button addTarget:self action:@selector(choiceTapped:) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:button];
}

- (void)choiceTapped:(UIButton *)button {
    NSString *source = button.tag == 0 ? @"shelter" : @"shop";
    PKPetSelectionViewController *selection = [[PKPetSelectionViewController alloc] initWithGameState:_gameState
                                                                                                  source:source];
    [self.navigationController pushViewController:selection animated:YES];
    [selection release];
}

- (void)dealloc {
    [_gameState release];
    [super dealloc];
}

@end
