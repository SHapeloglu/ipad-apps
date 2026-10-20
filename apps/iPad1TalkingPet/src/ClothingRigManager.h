#import <UIKit/UIKit.h>

@interface ClothingRigManager : NSObject {
    UIView *_host;

    UIView *_topBack;
    UIView *_topBody;
    UIView *_topFront;

    UIView *_bottomBack;
    UIView *_bottomBody;
    UIView *_bottomFront;

    UIImageView *_leftSleeve;
    UIImageView *_rightSleeve;
    UIImageView *_leftLeg;
    UIImageView *_rightLeg;

    CALayer *_torsoMask;
    CALayer *_hipsMask;
    CALayer *_leftLegMask;
    CALayer *_rightLegMask;
}
- (id)initWithHostView:(UIView *)host;
- (void)reload;
- (void)setPoseNeutral;
- (void)setPoseWave;
- (void)setPoseJump;
- (void)setPoseDance;
- (void)setPoseStretch;
@end
