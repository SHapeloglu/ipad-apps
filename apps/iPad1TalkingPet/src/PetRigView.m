#import "PetRigView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PetRigView

- (UIImageView *)image:(NSString *)name frame:(CGRect)frame {
    UIImage *im=[UIImage imageNamed:name];
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

        _base=[[self image:@"pet_base_neutral.png" frame:self.bounds] retain];
        [self addSubview:_base];

        _eyeLeft=[[self image:@"Rig/eye_left.png" frame:CGRectMake(W*0.355,H*0.195,W*0.12,H*0.075)] retain];
        _eyeRight=[[self image:@"Rig/eye_right.png" frame:CGRectMake(W*0.525,H*0.195,W*0.12,H*0.075)] retain];
        _lidLeft=[[self image:@"Rig/lid_left.png" frame:_eyeLeft.frame] retain];
        _lidRight=[[self image:@"Rig/lid_right.png" frame:_eyeRight.frame] retain];
        _mouth=[[self image:@"Rig/mouth_1.png" frame:CGRectMake(W*0.455,H*0.315,W*0.09,H*0.06)] retain];

        _lidLeft.alpha=0;
        _lidRight.alpha=0;
        _eyeLeft.alpha=0.0;
        _eyeRight.alpha=0.0;
        _mouth.alpha=0.0;

        [self addSubview:_eyeLeft];
        [self addSubview:_eyeRight];
        [self addSubview:_lidLeft];
        [self addSubview:_lidRight];
        [self addSubview:_mouth];

        [self startIdle];
    }
    return self;
}

- (void)startIdle {
    if(_idleTimer) return;
    _idleTimer=[[NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(idleTick) userInfo:nil repeats:YES] retain];
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
    // Keep the original eyes visible; use a very subtle lid overlay only.
    _lidLeft.alpha=0.0; _lidRight.alpha=0.0;
    [UIView animateWithDuration:0.08 animations:^{
        _lidLeft.alpha=0.72; _lidRight.alpha=0.72;
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.10 animations:^{
            _lidLeft.alpha=0.0; _lidRight.alpha=0.0;
        }];
    }];
}

- (void)lookLeft {
    [UIView animateWithDuration:0.18 animations:^{
        _base.transform=CGAffineTransformMakeRotation(-0.025);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.22 animations:^{
            _base.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)lookRight {
    [UIView animateWithDuration:0.18 animations:^{
        _base.transform=CGAffineTransformMakeRotation(0.025);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.22 animations:^{
            _base.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)wave {
    [UIView animateWithDuration:0.16 animations:^{
        _base.transform=CGAffineTransformMakeRotation(-0.025);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.16 animations:^{
            _base.transform=CGAffineTransformMakeRotation(0.018);
        } completion:^(BOOL f2){
            [UIView animateWithDuration:0.18 animations:^{
                _base.transform=CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)happy {
    [UIView animateWithDuration:0.16 animations:^{
        _base.transform=CGAffineTransformMakeScale(1.018,1.018);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.20 animations:^{
            _base.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)sad {
    [UIView animateWithDuration:0.22 animations:^{
        _base.transform=CGAffineTransformMakeTranslation(0,4);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.22 animations:^{
            _base.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)surprise {
    [UIView animateWithDuration:0.14 animations:^{
        _base.transform=CGAffineTransformMakeScale(1.028,1.028);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.20 animations:^{
            _base.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)stretch {
    [UIView animateWithDuration:0.20 animations:^{
        _base.transform=CGAffineTransformMakeScale(0.985,1.035);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.22 animations:^{
            _base.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)dance {
    [UIView animateWithDuration:0.14 animations:^{
        self.transform=CGAffineTransformMakeTranslation(-5,-3);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.14 animations:^{
            self.transform=CGAffineTransformMakeTranslation(5,-3);
        } completion:^(BOOL f2){
            [UIView animateWithDuration:0.16 animations:^{
                self.transform=CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)jump {
    [UIView animateWithDuration:0.15 animations:^{
        self.transform=CGAffineTransformMakeTranslation(0,-15);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.17 animations:^{
            self.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)setTalking:(BOOL)talking {
    _talking=talking;
    if(!_talking) {
        _mouth.alpha=0.0;
        return;
    }
    _mouth.alpha=0.55;
    _mouthFrame=(_mouthFrame%4)+1;
    _mouth.image=[UIImage imageNamed:[NSString stringWithFormat:@"Rig/mouth_%ld.png",(long)_mouthFrame]];
    [self performSelector:@selector(talkTick) withObject:nil afterDelay:0.12];
}

- (void)talkTick {
    if(!_talking) return;
    _mouthFrame=(_mouthFrame%4)+1;
    _mouth.image=[UIImage imageNamed:[NSString stringWithFormat:@"Rig/mouth_%ld.png",(long)_mouthFrame]];
    [self performSelector:@selector(talkTick) withObject:nil afterDelay:0.12];
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self stopIdle];
    [_base release];
    [_eyeLeft release]; [_eyeRight release];
    [_lidLeft release]; [_lidRight release];
    [_mouth release];
    [super dealloc];
}
@end
