#import "PetCharacterView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PetCharacterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;

        _body = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pet_base.png"]];
        _body.frame = self.bounds;
        _body.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_body];

        // Face animation overlays are relative to this new transparent layer.
        _blinkLeft = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*0.36, frame.size.height*0.245, 38, 10)];
        _blinkRight = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*0.55, frame.size.height*0.255, 38, 10)];
        _blinkLeft.backgroundColor = [UIColor colorWithRed:0.95 green:0.79 blue:0.79 alpha:0.96];
        _blinkRight.backgroundColor = _blinkLeft.backgroundColor;
        _blinkLeft.layer.cornerRadius = 5;
        _blinkRight.layer.cornerRadius = 5;
        _blinkLeft.hidden = YES; _blinkRight.hidden = YES;
        [self addSubview:_blinkLeft]; [self addSubview:_blinkRight];

        _mouth = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*0.47, frame.size.height*0.35, 30, 12)];
        _mouth.backgroundColor = [UIColor colorWithRed:0.38 green:0.04 blue:0.08 alpha:0.88];
        _mouth.layer.cornerRadius = 7;
        _mouth.hidden = YES;
        [self addSubview:_mouth];

        _hatLayer = [[UIView alloc] initWithFrame:self.bounds];
        _faceLayer = [[UIView alloc] initWithFrame:self.bounds];
        _shirtLayer = [[UIView alloc] initWithFrame:self.bounds];
        _pantsLayer = [[UIView alloc] initWithFrame:self.bounds];
        _shoesLayer = [[UIView alloc] initWithFrame:self.bounds];
        for (UIView *v in [NSArray arrayWithObjects:_shirtLayer,_pantsLayer,_shoesLayer,_hatLayer,_faceLayer,nil]) {
            v.backgroundColor = [UIColor clearColor];
            v.userInteractionEnabled = NO;
            [self addSubview:v];
        }

        [self reloadOutfit];
    }
    return self;
}

- (void)clearLayer:(UIView *)layer {
    NSArray *copy = [[layer.subviews copy] autorelease];
    for (UIView *v in copy) [v removeFromSuperview];
}

- (UIView *)rounded:(CGRect)r color:(UIColor *)color radius:(CGFloat)radius {
    UIView *v = [[[UIView alloc] initWithFrame:r] autorelease];
    v.backgroundColor = color;
    v.layer.cornerRadius = radius;
    return v;
}

- (void)reloadOutfit {
    [self clearLayer:_hatLayer];
    [self clearLayer:_faceLayer];
    [self clearLayer:_shirtLayer];
    [self clearLayer:_pantsLayer];
    [self clearLayer:_shoesLayer];

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSInteger hat = [d integerForKey:@"outfit.hat"];
    NSInteger face = [d integerForKey:@"outfit.face"];
    NSInteger shirt = [d integerForKey:@"outfit.shirt"];
    NSInteger pants = [d integerForKey:@"outfit.pants"];
    NSInteger shoes = [d integerForKey:@"outfit.shoes"];

    CGFloat W = self.bounds.size.width, H = self.bounds.size.height;

    if (hat == 1) {
        [_hatLayer addSubview:[self rounded:CGRectMake(W*0.31,H*0.03,W*0.38,H*0.075)
                                      color:[UIColor colorWithRed:0.10 green:0.32 blue:0.78 alpha:0.96] radius:18]];
        [_hatLayer addSubview:[self rounded:CGRectMake(W*0.25,H*0.09,W*0.50,H*0.026)
                                      color:[UIColor colorWithRed:0.07 green:0.22 blue:0.58 alpha:0.96] radius:7]];
    } else if (hat == 2) {
        [_hatLayer addSubview:[self rounded:CGRectMake(W*0.32,H*0.03,W*0.36,H*0.075)
                                      color:[UIColor colorWithRed:0.64 green:0.10 blue:0.42 alpha:0.96] radius:18]];
    }

    if (face == 1) {
        UIView *l = [self rounded:CGRectMake(W*0.32,H*0.235,W*0.18,H*0.075)
                            color:[UIColor colorWithRed:0.35 green:0.62 blue:1 alpha:0.30] radius:18];
        UIView *r = [self rounded:CGRectMake(W*0.51,H*0.235,W*0.18,H*0.075)
                            color:[UIColor colorWithRed:0.35 green:0.62 blue:1 alpha:0.30] radius:18];
        l.layer.borderWidth=5; r.layer.borderWidth=5;
        l.layer.borderColor=[UIColor colorWithRed:0.60 green:0.05 blue:0.48 alpha:1].CGColor;
        r.layer.borderColor=l.layer.borderColor;
        [_faceLayer addSubview:l]; [_faceLayer addSubview:r];
    }

    if (shirt == 1 || shirt == 2) {
        UIColor *c = shirt==1 ? [UIColor colorWithRed:0.42 green:0.28 blue:0.82 alpha:0.68]
                              : [UIColor colorWithRed:0.10 green:0.56 blue:0.72 alpha:0.68];
        UIView *s = [self rounded:CGRectMake(W*0.29,H*0.45,W*0.42,H*0.22) color:c radius:24];
        [_shirtLayer addSubview:s];
    }

    if (pants == 1) {
        UIView *p = [self rounded:CGRectMake(W*0.32,H*0.66,W*0.36,H*0.13)
                            color:[UIColor colorWithRed:0.12 green:0.20 blue:0.45 alpha:0.70] radius:16];
        [_pantsLayer addSubview:p];
    }

    if (shoes == 1) {
        UIColor *red = [UIColor colorWithRed:0.82 green:0.10 blue:0.12 alpha:0.84];
        [_shoesLayer addSubview:[self rounded:CGRectMake(W*0.29,H*0.91,W*0.17,H*0.05) color:red radius:12]];
        [_shoesLayer addSubview:[self rounded:CGRectMake(W*0.54,H*0.91,W*0.17,H*0.05) color:red radius:12]];
    }
}

- (void)startIdle {
    if (_idleTimer) return;
    _idleTimer = [[NSTimer scheduledTimerWithTimeInterval:2.8 target:self selector:@selector(idleTick)
                                                  userInfo:nil repeats:YES] retain];
}

- (void)idleTick {
    if (arc4random()%3 == 0) [self blink];
    [UIView animateWithDuration:0.40 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0,-3);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.40 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)blink {
    _blinkLeft.hidden=NO; _blinkRight.hidden=NO;
    [self performSelector:@selector(endBlink) withObject:nil afterDelay:0.14];
}
- (void)endBlink { _blinkLeft.hidden=YES; _blinkRight.hidden=YES; }

- (void)happy {
    [UIView animateWithDuration:0.12 animations:^{
        self.transform=CGAffineTransformMakeScale(1.045,1.045);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.16 animations:^{ self.transform=CGAffineTransformIdentity; }];
    }];
}

- (void)sad {
    [UIView animateWithDuration:0.15 animations:^{
        self.transform=CGAffineTransformMakeTranslation(0,8);
        self.alpha=0.90;
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.18 animations:^{
            self.transform=CGAffineTransformIdentity; self.alpha=1;
        }];
    }];
}

- (void)touchHead { [self happy]; [self blink]; }
- (void)touchBody {
    [UIView animateWithDuration:0.08 animations:^{
        self.transform=CGAffineTransformMakeRotation(0.025);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.08 animations:^{
            self.transform=CGAffineTransformMakeRotation(-0.025);
        } completion:^(BOOL f2){
            [UIView animateWithDuration:0.08 animations:^{self.transform=CGAffineTransformIdentity;}];
        }];
    }];
}
- (void)touchFeet { [self sad]; }

- (void)setTalking:(BOOL)talking {
    _talking=talking;
    _mouth.hidden=!talking;
    if (talking) [self talkPulse];
    else { _mouth.transform=CGAffineTransformIdentity; }
}

- (void)talkPulse {
    if(!_talking) return;
    [UIView animateWithDuration:0.09 animations:^{
        _mouth.transform=CGAffineTransformMakeScale(1.0,1.8);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.09 animations:^{
            _mouth.transform=CGAffineTransformIdentity;
        } completion:^(BOOL f2){
            if(_talking) [self performSelector:@selector(talkPulse) withObject:nil afterDelay:0.04];
        }];
    }];
}

- (void)chew {
    _mouth.hidden=NO;
    [UIView animateWithDuration:0.10 animations:^{
        _mouth.transform=CGAffineTransformMakeScale(1.35,0.65);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.10 animations:^{
            _mouth.transform=CGAffineTransformIdentity;
        } completion:^(BOOL f2){
            _mouth.hidden=YES;
            [self happy];
        }];
    }];
}

- (void)stop {
    [_idleTimer invalidate]; [_idleTimer release]; _idleTimer=nil;
    _talking=NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dealloc {
    [self stop];
    [_body release]; [_blinkLeft release]; [_blinkRight release]; [_mouth release];
    [_hatLayer release]; [_faceLayer release]; [_shirtLayer release]; [_pantsLayer release]; [_shoesLayer release];
    [super dealloc];
}
@end
