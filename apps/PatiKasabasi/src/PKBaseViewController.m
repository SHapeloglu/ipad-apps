#import "PKBaseViewController.h"
#import "PKTheme.h"

@implementation PKBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [PKTheme creamColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

- (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                   fontSize:(CGFloat)fontSize
                       bold:(BOOL)bold {
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [PKTheme inkColor];
    label.text = text;
    label.font = bold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
    label.textAlignment = UITextAlignmentCenter;
    label.numberOfLines = 0;
    return label;
}

- (UIButton *)primaryButtonWithFrame:(CGRect)frame title:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [PKTheme stylePrimaryButton:button];
    return button;
}

- (UIButton *)secondaryButtonWithFrame:(CGRect)frame title:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [PKTheme styleSecondaryButton:button];
    return button;
}

@end
