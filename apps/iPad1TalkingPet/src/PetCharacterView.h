#import <UIKit/UIKit.h>

@interface PetCharacterView : UIView {
    UIImageView *_body;
    UIView *_blinkLeft;
    UIView *_blinkRight;
    UIView *_mouth;
    UIView *_hatLayer;
    UIView *_faceLayer;
    UIView *_shirtLayer;
    UIView *_pantsLayer;
    UIView *_shoesLayer;
    NSTimer *_idleTimer;
    BOOL _talking;
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
- (void)reloadOutfit;
@end
