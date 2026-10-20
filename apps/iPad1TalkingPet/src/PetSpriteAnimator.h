#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PetSpriteAnimator : NSObject {
    UIImageView *_imageView;
    NSTimer *_idleTimer;
    BOOL _busy;
}
- (id)initWithImageView:(UIImageView *)imageView;
- (void)startIdle;
- (void)stop;
- (void)playNamed:(NSString *)name frameCount:(NSInteger)count duration:(NSTimeInterval)duration repeat:(NSInteger)repeatCount;
- (void)blink;
- (void)happy;
- (void)sad;
- (void)touch;
- (void)talkStart;
- (void)talkStop;
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
