#import <UIKit/UIKit.h>

@interface PKThoughtBubbleView : UIView {
    NSString *_text;
    NSString *_iconIdentifier;
}

@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *iconIdentifier;

- (id)initWithFrame:(CGRect)frame text:(NSString *)text iconIdentifier:(NSString *)iconIdentifier;

@end
