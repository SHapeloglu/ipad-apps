#import "PetAnimator.h"
#import <QuartzCore/QuartzCore.h>

@implementation PetAnimator

- (id)initWithHostView:(UIView *)hostView {
    self = [super init];
    if (self) {
        _hostView = [hostView retain];

        // These lightweight overlays are aligned to the approved 768x1024 home mockup.
        _blinkLeft = [[UIView alloc] initWithFrame:CGRectMake(367, 292, 54, 12)];
        _blinkRight = [[UIView alloc] initWithFrame:CGRectMake(459, 300, 54, 12)];
        _blinkLeft.backgroundColor = [UIColor colorWithRed:0.94 green:0.79 blue:0.78 alpha:0.92];
        _blinkRight.backgroundColor = _blinkLeft.backgroundColor;
        _blinkLeft.layer.cornerRadius = 6;
        _blinkRight.layer.cornerRadius = 6;
        _blinkLeft.hidden = YES;
        _blinkRight.hidden = YES;

        _mouth = [[UIView alloc] initWithFrame:CGRectMake(424, 401, 34, 15)];
        _mouth.backgroundColor = [UIColor colorWithRed:0.38 green:0.05 blue:0.08 alpha:0.80];
        _mouth.layer.cornerRadius = 8;
        _mouth.hidden = YES;

        [_hostView addSubview:_blinkLeft];
        [_hostView addSubview:_blinkRight];
        [_hostView addSubview:_mouth];
    }
    return self;
}

- (void)startIdle {
    if (_idleTimer) return;
    _idleStep = 0;
    _idleTimer = [[NSTimer scheduledTimerWithTimeInterval:2.7
                                                  target:self
                                                selector:@selector(idleTick)
                                                userInfo:nil
                                                 repeats:YES] retain];
}

- (void)idleTick {
    _idleStep++;
    if ((_idleStep % 2) == 0) {
        [self blink];
    } else {
        [UIView animateWithDuration:0.35 animations:^{
            _hostView.transform = CGAffineTransformMakeTranslation(0, -2.0f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.35 animations:^{
                _hostView.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (void)blink {
    _blinkLeft.hidden = NO;
    _blinkRight.hidden = NO;
    [self performSelector:@selector(endBlink) withObject:nil afterDelay:0.14];
}

- (void)endBlink {
    _blinkLeft.hidden = YES;
    _blinkRight.hidden = YES;
}

- (void)happy {
    [UIView animateWithDuration:0.12 animations:^{
        _hostView.transform = CGAffineTransformMakeScale(1.025f, 1.025f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.16 animations:^{
            _hostView.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)touchReaction {
    [UIView animateWithDuration:0.08 animations:^{
        _hostView.transform = CGAffineTransformMakeRotation(0.012f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08 animations:^{
            _hostView.transform = CGAffineTransformMakeRotation(-0.012f);
        } completion:^(BOOL finished2) {
            [UIView animateWithDuration:0.08 animations:^{
                _hostView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)setTalking:(BOOL)talking {
    _talking = talking;
    if (_talking) {
        _mouth.hidden = NO;
        [self talkPulse];
    } else {
        _mouth.hidden = YES;
        [_mouth.layer removeAllAnimations];
    }
}

- (void)talkPulse {
    if (!_talking) return;
    [UIView animateWithDuration:0.10 animations:^{
        _mouth.transform = CGAffineTransformMakeScale(1.0f, 1.65f);
    } completion:^(BOOL finished) {
        if (!_talking) return;
        [UIView animateWithDuration:0.10 animations:^{
            _mouth.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished2) {
            if (_talking) [self performSelector:@selector(talkPulse) withObject:nil afterDelay:0.05];
        }];
    }];
}

- (void)stop {
    [_idleTimer invalidate];
    [_idleTimer release];
    _idleTimer = nil;
    _talking = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dealloc {
    [self stop];
    [_blinkLeft release];
    [_blinkRight release];
    [_mouth release];
    [_hostView release];
    [super dealloc];
}
@end
