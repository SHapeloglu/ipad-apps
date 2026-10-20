#import <UIKit/UIKit.h>

@interface PKAmbientObjectView : UIView {
    NSString *_objectIdentifier;
}

@property(nonatomic, copy) NSString *objectIdentifier;

- (id)initWithFrame:(CGRect)frame objectIdentifier:(NSString *)identifier;

@end
