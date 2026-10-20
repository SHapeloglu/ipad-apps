#import <UIKit/UIKit.h>

@interface PetAnimator : NSObject {
    UIView *_hostView;
    UIView *_blinkLeft;
    UIView *_blinkRight;
    UIView *_mouth;
    NSTimer *_idleTimer;
    BOOL _talking;
    NSInteger _idleStep;
}
- (id)initWithHostView:(UIView *)hostView;
- (void)startIdle;
- (void)stop;
- (void)blink;
- (void)happy;
- (void)touchReaction;
- (void)setTalking:(BOOL)talking;
@end
