#import <UIKit/UIKit.h>
@class PetSpriteAnimator;

@interface PetCharacterView : UIView {
    UIImageView *_body;
    PetSpriteAnimator *_sprite;
    UIView *_hatLayer;
    UIView *_faceLayer;
    UIView *_shirtLayer;
    UIView *_pantsLayer;
    UIView *_shoesLayer;
}
- (void)startIdle;
- (void)stop;
- (void)blink;
- (void)happy;
- (void)sad;
- (void)touchHead;
- (void)touchBody;
- (void)touchFeet;
- (void)setTalking:(BOOL)talking;
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
- (void)reloadOutfit;
@end
