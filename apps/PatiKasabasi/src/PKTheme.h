#import <UIKit/UIKit.h>

@interface PKTheme : NSObject

+ (UIColor *)mintColor;
+ (UIColor *)darkTealColor;
+ (UIColor *)creamColor;
+ (UIColor *)coralColor;
+ (UIColor *)inkColor;
+ (UIColor *)panelColor;
+ (void)stylePrimaryButton:(UIButton *)button;
+ (void)styleSecondaryButton:(UIButton *)button;
+ (void)stylePanel:(UIView *)view;

@end
