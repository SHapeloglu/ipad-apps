#import <UIKit/UIKit.h>

@interface PKActionPropView : UIView {
    NSString *_propIdentifier;
    BOOL _depleted;
    BOOL _targeted;
}

@property(nonatomic, copy) NSString *propIdentifier;
@property(nonatomic, assign) BOOL depleted;
@property(nonatomic, assign) BOOL targeted;

- (id)initWithFrame:(CGRect)frame propIdentifier:(NSString *)propIdentifier;
- (NSString *)actionIdentifier;

@end
