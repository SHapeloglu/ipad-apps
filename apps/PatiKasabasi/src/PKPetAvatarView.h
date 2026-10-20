#import <UIKit/UIKit.h>

@interface PKPetAvatarView : UIView {
    NSString *_speciesIdentifier;
    NSString *_reactionIdentifier;
    NSString *_lifeStageIdentifier;
    NSDictionary *_equippedAccessories;
    BOOL _happy;
    CGFloat _visualScale;
}

@property(nonatomic, copy) NSString *speciesIdentifier;
@property(nonatomic, copy) NSString *reactionIdentifier;
@property(nonatomic, copy) NSString *lifeStageIdentifier;
@property(nonatomic, copy) NSDictionary *equippedAccessories;
@property(nonatomic, assign) BOOL happy;
@property(nonatomic, assign) CGFloat visualScale;

- (id)initWithFrame:(CGRect)frame speciesIdentifier:(NSString *)speciesIdentifier;
- (NSString *)interactionZoneAtPoint:(CGPoint)point;

@end
