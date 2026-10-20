#import <UIKit/UIKit.h>

@interface PKNeedBarView : UIView {
    UILabel *_titleLabel;
    UILabel *_valueLabel;
    UIView *_trackView;
    UIView *_fillView;
    NSInteger _value;
}

@property(nonatomic, assign) NSInteger value;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color;

@end
