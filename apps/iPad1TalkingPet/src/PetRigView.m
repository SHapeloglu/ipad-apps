#import "PetRigView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PetRigView

- (UIImageView *)image:(NSString *)name frame:(CGRect)frame {
    UIImage *im=[UIImage imageNamed:[@"Rig/" stringByAppendingString:name]];
    UIImageView *v=[[[UIImageView alloc] initWithImage:im] autorelease];
    v.frame=frame;
    v.contentMode=UIViewContentModeScaleAspectFit;
    v.backgroundColor=[UIColor clearColor];
    return v;
}

- (id)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if(self) {
        self.backgroundColor=[UIColor clearColor];
        CGFloat W=self.bounds.size.width,H=self.bounds.size.height;

        _tail=[[self image:@"tail.png" frame:CGRectMake(W*0.58,H*0.50,W*0.39,H*0.40)] retain];
        _legLeft=[[self image:@"leg_left.png" frame:CGRectMake(W*0.24,H*0.63,W*0.28,H*0.34)] retain];
        _legRight=[[self image:@"leg_right.png" frame:CGRectMake(W*0.48,H*0.63,W*0.28,H*0.34)] retain];
        _torso=[[self image:@"torso.png" frame:CGRectMake(W*0.23,H*0.35,W*0.54,H*0.42)] retain];
        _armLeft=[[self image:@"arm_left.png" frame:CGRectMake(W*0.08,H*0.35,W*0.33,H*0.43)] retain];
        _armRight=[[self image:@"arm_right.png" frame:CGRectMake(W*0.59,H*0.35,W*0.33,H*0.43)] retain];
        _head=[[self image:@"head.png" frame:CGRectMake(W*0.13,H*0.00,W*0.74,H*0.52)] retain];

        [self addSubview:_tail];
        [self addSubview:_legLeft];
        [self addSubview:_legRight];
        [self addSubview:_torso];
        [self addSubview:_armLeft];
        [self addSubview:_armRight];
        [self addSubview:_head];

        _eyeLeft=[[self image:@"eye_left.png" frame:CGRectMake(W*0.34,H*0.17,W*0.15,H*0.10)] retain];
        _eyeRight=[[self image:@"eye_right.png" frame:CGRectMake(W*0.51,H*0.17,W*0.15,H*0.10)] retain];
        _lidLeft=[[self image:@"lid_left.png" frame:_eyeLeft.frame] retain];
        _lidRight=[[self image:@"lid_right.png" frame:_eyeRight.frame] retain];
        _mouth=[[self image:@"mouth_1.png" frame:CGRectMake(W*0.46,H*0.30,W*0.10,H*0.08)] retain];

        _lidLeft.alpha=0;
        _lidRight.alpha=0;

        [self addSubview:_eyeLeft];
        [self addSubview:_eyeRight];
        [self addSubview:_lidLeft];
        [self addSubview:_lidRight];
        [self addSubview:_mouth];

        _head.layer.anchorPoint=CGPointMake(0.5,0.72);
        _armLeft.layer.anchorPoint=CGPointMake(0.65,0.18);
        _armRight.layer.anchorPoint=CGPointMake(0.35,0.18);
        _tail.layer.anchorPoint=CGPointMake(0.20,0.50);

        [self startIdle];
    }
    return self;
}

- (void)startIdle {
    if(_idleTimer) return;
    _idleTimer=[[NSTimer scheduledTimerWithTimeInterval:3.8 target:self selector:@selector(idleTick) userInfo:nil repeats:YES] retain];
}

- (void)stopIdle {
    [_idleTimer invalidate];
    [_idleTimer release];
    _idleTimer=nil;
}

- (void)idleTick {
    NSInteger r=arc4random()%4;
    if(r==0) [self blink];
    else if(r==1) [self lookLeft];
    else if(r==2) [self lookRight];
    else [self happy];
}

- (void)blink {
    _lidLeft.alpha=1; _lidRight.alpha=1;
    [UIView animateWithDuration:0.12 animations:^{
        _lidLeft.alpha=1; _lidRight.alpha=1;
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.14 animations:^{
            _lidLeft.alpha=0; _lidRight.alpha=0;
        }];
    }];
}

- (void)lookLeft {
    [UIView animateWithDuration:0.20 animations:^{
        _eyeLeft.transform=CGAffineTransformMakeTranslation(-5,0);
        _eyeRight.transform=CGAffineTransformMakeTranslation(-5,0);
        _head.transform=CGAffineTransformMakeRotation(-0.035);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.25 animations:^{
            _eyeLeft.transform=CGAffineTransformIdentity;
            _eyeRight.transform=CGAffineTransformIdentity;
            _head.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)lookRight {
    [UIView animateWithDuration:0.20 animations:^{
        _eyeLeft.transform=CGAffineTransformMakeTranslation(5,0);
        _eyeRight.transform=CGAffineTransformMakeTranslation(5,0);
        _head.transform=CGAffineTransformMakeRotation(0.035);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.25 animations:^{
            _eyeLeft.transform=CGAffineTransformIdentity;
            _eyeRight.transform=CGAffineTransformIdentity;
            _head.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)wave {
    [UIView animateWithDuration:0.18 animations:^{
        _armLeft.transform=CGAffineTransformMakeRotation(-0.45);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.14 animations:^{
            _armLeft.transform=CGAffineTransformMakeRotation(-0.15);
        } completion:^(BOOL f2){
            [UIView animateWithDuration:0.14 animations:^{
                _armLeft.transform=CGAffineTransformMakeRotation(-0.50);
            } completion:^(BOOL f3){
                [UIView animateWithDuration:0.18 animations:^{
                    _armLeft.transform=CGAffineTransformIdentity;
                }];
            }];
        }];
    }];
}

- (void)happy {
    [UIView animateWithDuration:0.16 animations:^{
        _head.transform=CGAffineTransformMakeRotation(-0.035);
        _tail.transform=CGAffineTransformMakeRotation(0.16);
        _torso.transform=CGAffineTransformMakeScale(1.02,1.02);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.22 animations:^{
            _head.transform=CGAffineTransformIdentity;
            _tail.transform=CGAffineTransformIdentity;
            _torso.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)sad {
    [UIView animateWithDuration:0.25 animations:^{
        _head.transform=CGAffineTransformMakeRotation(0.06);
        _torso.transform=CGAffineTransformMakeTranslation(0,5);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.25 animations:^{
            _head.transform=CGAffineTransformIdentity;
            _torso.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)surprise {
    _mouth.image=[UIImage imageNamed:@"Rig/mouth_4.png"];
    [UIView animateWithDuration:0.16 animations:^{
        _head.transform=CGAffineTransformMakeScale(1.04,1.04);
        _eyeLeft.transform=CGAffineTransformMakeScale(1.08,1.08);
        _eyeRight.transform=CGAffineTransformMakeScale(1.08,1.08);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.25 animations:^{
            _head.transform=CGAffineTransformIdentity;
            _eyeLeft.transform=CGAffineTransformIdentity;
            _eyeRight.transform=CGAffineTransformIdentity;
        } completion:^(BOOL f2){
            _mouth.image=[UIImage imageNamed:@"Rig/mouth_1.png"];
        }];
    }];
}

- (void)stretch {
    [UIView animateWithDuration:0.25 animations:^{
        _torso.transform=CGAffineTransformMakeScale(1.02,1.07);
        _armLeft.transform=CGAffineTransformMakeRotation(-0.18);
        _armRight.transform=CGAffineTransformMakeRotation(0.18);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.25 animations:^{
            _torso.transform=CGAffineTransformIdentity;
            _armLeft.transform=CGAffineTransformIdentity;
            _armRight.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)dance {
    [UIView animateWithDuration:0.16 animations:^{
        self.transform=CGAffineTransformMakeTranslation(-5,-4);
        _tail.transform=CGAffineTransformMakeRotation(-0.18);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.16 animations:^{
            self.transform=CGAffineTransformMakeTranslation(5,-4);
            _tail.transform=CGAffineTransformMakeRotation(0.18);
        } completion:^(BOOL f2){
            [UIView animateWithDuration:0.16 animations:^{
                self.transform=CGAffineTransformIdentity;
                _tail.transform=CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)jump {
    [UIView animateWithDuration:0.16 animations:^{
        self.transform=CGAffineTransformMakeTranslation(0,-18);
        _torso.transform=CGAffineTransformMakeScale(1.04,0.96);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.18 animations:^{
            self.transform=CGAffineTransformIdentity;
            _torso.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)setTalking:(BOOL)talking {
    _talking=talking;
    if(!_talking) {
        _mouth.image=[UIImage imageNamed:@"Rig/mouth_1.png"];
        return;
    }
    _mouthFrame=(_mouthFrame%4)+1;
    _mouth.image=[UIImage imageNamed:[NSString stringWithFormat:@"Rig/mouth_%ld.png",(long)_mouthFrame]];
    [self performSelector:@selector(talkTick) withObject:nil afterDelay:0.11];
}

- (void)talkTick {
    if(!_talking) return;
    _mouthFrame=(_mouthFrame%4)+1;
    _mouth.image=[UIImage imageNamed:[NSString stringWithFormat:@"Rig/mouth_%ld.png",(long)_mouthFrame]];
    [self performSelector:@selector(talkTick) withObject:nil afterDelay:0.11];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopIdle];
    [_head release]; [_torso release]; [_armLeft release]; [_armRight release];
    [_legLeft release]; [_legRight release]; [_tail release];
    [_eyeLeft release]; [_eyeRight release]; [_lidLeft release]; [_lidRight release];
    [_mouth release];
    [super dealloc];
}
@end
