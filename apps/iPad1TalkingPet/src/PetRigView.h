#import <UIKit/UIKit.h>

@interface PetRigView : UIView {
    UIImageView *_head;
    UIImageView *_torso;
    UIImageView *_armLeft;
    UIImageView *_armRight;
    UIImageView *_legLeft;
    UIImageView *_legRight;
    UIImageView *_tail;

    UIImageView *_eyeLeft;
    UIImageView *_eyeRight;
    UIImageView *_lidLeft;
    UIImageView *_lidRight;
    UIImageView *_mouth;

    NSTimer *_idleTimer;
    NSInteger _mouthFrame;
    BOOL _talking;
}
- (void)startIdle;
- (void)stopIdle;
- (void)blink;
- (void)lookLeft;
- (void)lookRight;
- (void)wave;
- (void)happy;
- (void)sad;
- (void)surprise;
- (void)stretch;
- (void)dance;
- (void)jump;
- (void)setTalking:(BOOL)talking;
@end
