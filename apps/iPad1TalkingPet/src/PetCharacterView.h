#import <UIKit/UIKit.h>
@class PetSpriteAnimator;
@class PetRigView;
@class ClothingRigManager;

@interface PetCharacterView : UIView {
    UIView *_motionLayer;
    UIImageView *_body;
    PetSpriteAnimator *_sprite;
    PetRigView *_rig;
    BOOL _useRig;
    ClothingRigManager *_clothingRig;

    UIView *_hatLayer;
    UIView *_faceLayer;
    UIView *_shirtLayer;
    UIView *_pantsLayer;
    UIView *_shoesLayer;
}
- (void)reloadOutfit;
- (void)startIdle;
- (void)stop;
- (void)blink;
- (void)happy;
- (void)sad;
- (void)touchHead;
- (void)touchBody;
- (void)touchFeet;
- (void)setTalking:(BOOL)t;
- (void)chew;
- (void)sleep;
- (void)lookLeft;
- (void)lookRight;
- (void)wave;
- (void)laugh;
- (void)surprise;
- (void)stretch;
- (void)dance;
- (void)jump;
@end
