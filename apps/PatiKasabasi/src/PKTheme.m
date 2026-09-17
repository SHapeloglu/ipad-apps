#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation PKTheme

+ (UIColor *)mintColor { return [UIColor colorWithRed:0.31f green:0.72f blue:0.64f alpha:1.0f]; }
+ (UIColor *)darkTealColor { return [UIColor colorWithRed:0.10f green:0.35f blue:0.36f alpha:1.0f]; }
+ (UIColor *)creamColor { return [UIColor colorWithRed:0.98f green:0.96f blue:0.88f alpha:1.0f]; }
+ (UIColor *)coralColor { return [UIColor colorWithRed:0.94f green:0.48f blue:0.38f alpha:1.0f]; }
+ (UIColor *)inkColor { return [UIColor colorWithRed:0.16f green:0.20f blue:0.22f alpha:1.0f]; }
+ (UIColor *)panelColor { return [UIColor colorWithWhite:1.0f alpha:0.90f]; }

+ (void)baseButton:(UIButton *)button {
    button.titleLabel.font = [UIFont boldSystemFontOfSize:21.0f];
    button.layer.cornerRadius = 12.0f;
    button.layer.borderWidth = 2.0f;
    button.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 18.0f, 10.0f, 18.0f);
    button.showsTouchWhenHighlighted = YES;
}

+ (void)stylePrimaryButton:(UIButton *)button {
    [self baseButton:button];
    button.backgroundColor = [self coralColor];
    button.layer.borderColor = [UIColor colorWithRed:0.76f green:0.30f blue:0.24f alpha:1.0f].CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

+ (void)styleSecondaryButton:(UIButton *)button {
    [self baseButton:button];
    button.backgroundColor = [self mintColor];
    button.layer.borderColor = [self darkTealColor].CGColor;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

+ (void)stylePanel:(UIView *)view {
    view.backgroundColor = [self panelColor];
    view.layer.cornerRadius = 18.0f;
    view.layer.borderWidth = 2.0f;
    view.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.95f].CGColor;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.12f;
    view.layer.shadowRadius = 5.0f;
    view.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
}

@end
