#import <UIKit/UIKit.h>

@interface PKBaseViewController : UIViewController

- (UILabel *)labelWithFrame:(CGRect)frame
                       text:(NSString *)text
                   fontSize:(CGFloat)fontSize
                       bold:(BOOL)bold;
- (UIButton *)primaryButtonWithFrame:(CGRect)frame title:(NSString *)title;
- (UIButton *)secondaryButtonWithFrame:(CGRect)frame title:(NSString *)title;

@end
