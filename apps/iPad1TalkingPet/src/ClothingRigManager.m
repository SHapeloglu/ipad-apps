#import "ClothingRigManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation ClothingRigManager

- (UIImage *)asset:(NSString *)name {
    NSString *p=[[NSBundle mainBundle] pathForResource:name ofType:@"png" inDirectory:@"Outfits"];
    if(!p) return [UIImage imageNamed:[@"Outfits/" stringByAppendingFormat:@"%@.png",name]];
    return [UIImage imageWithContentsOfFile:p];
}

- (CALayer *)maskNamed:(NSString *)name frame:(CGRect)frame {
    NSString *p=[[NSBundle mainBundle] pathForResource:name ofType:@"png" inDirectory:@"Masks"];
    UIImage *im=p?[UIImage imageWithContentsOfFile:p]:[UIImage imageNamed:[@"Masks/" stringByAppendingFormat:@"%@.png",name]];
    CALayer *m=[CALayer layer];
    m.frame=frame;
    m.contents=(id)im.CGImage;
    m.contentsGravity=kCAGravityResizeAspect;
    return [m retain];
}

- (UIImageView *)part:(NSString *)name {
    UIImageView *v=[[[UIImageView alloc] initWithImage:[self asset:name]] autorelease];
    v.frame=_host.bounds;
    v.contentMode=UIViewContentModeScaleAspectFit;
    v.backgroundColor=[UIColor clearColor];
    return v;
}

- (id)initWithHostView:(UIView *)host {
    self=[super init];
    if(self) {
        _host=[host retain];

        _bottomBack=[[UIView alloc] initWithFrame:_host.bounds];
        _topBack=[[UIView alloc] initWithFrame:_host.bounds];
        _topBody=[[UIView alloc] initWithFrame:_host.bounds];
        _bottomBody=[[UIView alloc] initWithFrame:_host.bounds];
        _topFront=[[UIView alloc] initWithFrame:_host.bounds];
        _bottomFront=[[UIView alloc] initWithFrame:_host.bounds];

        for(UIView *v in [NSArray arrayWithObjects:_bottomBack,_topBack,_topBody,_bottomBody,_topFront,_bottomFront,nil]) {
            v.backgroundColor=[UIColor clearColor];
            v.userInteractionEnabled=NO;
            [_host addSubview:v];
        }

        _torsoMask=[self maskNamed:@"torso_mask" frame:_host.bounds];
        _hipsMask=[self maskNamed:@"hips_mask" frame:_host.bounds];
        _leftLegMask=[self maskNamed:@"left_leg_mask" frame:_host.bounds];
        _rightLegMask=[self maskNamed:@"right_leg_mask" frame:_host.bounds];

        _topBody.layer.mask=_torsoMask;
        _bottomBody.layer.mask=_hipsMask;

        [self reload];
    }
    return self;
}

- (void)clear:(UIView *)v {
    for(UIView *s in [[v.subviews copy] autorelease]) [s removeFromSuperview];
}

- (void)reload {
    [self clear:_bottomBack]; [self clear:_topBack]; [self clear:_topBody];
    [self clear:_bottomBody]; [self clear:_topFront]; [self clear:_bottomFront];

    [_leftSleeve release]; _leftSleeve=nil;
    [_rightSleeve release]; _rightSleeve=nil;
    [_leftLeg release]; _leftLeg=nil;
    [_rightLeg release]; _rightLeg=nil;

    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    NSInteger topType=[d integerForKey:@"outfit.topType"];
    NSInteger topStyle=[d integerForKey:@"outfit.topStyle"];
    NSInteger bottomType=[d integerForKey:@"outfit.bottomType"];
    NSInteger bottomStyle=[d integerForKey:@"outfit.bottomStyle"];

    // Style 1 rigged set.
    if(topStyle==1 && topType==1) {
        [_topBody addSubview:[self part:@"rig_tshirt_body_style1"]];
        _leftSleeve=[[self part:@"rig_tshirt_sleeve_left_style1"] retain];
        _rightSleeve=[[self part:@"rig_tshirt_sleeve_right_style1"] retain];
        [_topFront addSubview:_leftSleeve];
        [_topFront addSubview:_rightSleeve];
    } else if(topStyle==1 && topType==2) {
        [_topBody addSubview:[self part:@"rig_crop_body_style1"]];
        _leftSleeve=[[self part:@"rig_crop_sleeve_left_style1"] retain];
        _rightSleeve=[[self part:@"rig_crop_sleeve_right_style1"] retain];
        [_topFront addSubview:_leftSleeve];
        [_topFront addSubview:_rightSleeve];
    }

    if(bottomStyle==1 && bottomType==1) {
        [_bottomBody addSubview:[self part:@"rig_pants_waist_style1"]];

        _leftLeg=[[self part:@"rig_pants_leg_left_style1"] retain];
        _rightLeg=[[self part:@"rig_pants_leg_right_style1"] retain];

        CALayer *lm=[self maskNamed:@"left_leg_mask" frame:_host.bounds];
        CALayer *rm=[self maskNamed:@"right_leg_mask" frame:_host.bounds];
        _leftLeg.layer.mask=lm;
        _rightLeg.layer.mask=rm;
        [lm release]; [rm release];

        [_bottomFront addSubview:_leftLeg];
        [_bottomFront addSubview:_rightLeg];
    } else if(bottomStyle==1 && bottomType==2) {
        [_bottomBack addSubview:[self part:@"rig_skirt_back_style1"]];
        [_bottomBody addSubview:[self part:@"rig_skirt_waist_style1"]];
        [_bottomFront addSubview:[self part:@"rig_skirt_front_style1"]];
    }

    [self setPoseNeutral];
}

- (void)setPoseNeutral {
    _leftSleeve.transform=CGAffineTransformIdentity;
    _rightSleeve.transform=CGAffineTransformIdentity;
    _leftLeg.transform=CGAffineTransformIdentity;
    _rightLeg.transform=CGAffineTransformIdentity;
    _topBody.transform=CGAffineTransformIdentity;
    _bottomBody.transform=CGAffineTransformIdentity;
    _bottomBack.transform=CGAffineTransformIdentity;
    _bottomFront.transform=CGAffineTransformIdentity;
}

- (void)setPoseWave {
    [UIView animateWithDuration:0.18 animations:^{
        _leftSleeve.transform=CGAffineTransformMakeRotation(-0.18);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.20 animations:^{
            _leftSleeve.transform=CGAffineTransformIdentity;
        }];
    }];
}

- (void)setPoseJump {
    [UIView animateWithDuration:0.15 animations:^{
        _topBody.transform=CGAffineTransformMakeScale(1.02,0.98);
        _bottomBody.transform=CGAffineTransformMakeScale(1.02,0.98);
        _bottomFront.transform=CGAffineTransformMakeTranslation(0,-2);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.17 animations:^{ [self setPoseNeutral]; }];
    }];
}

- (void)setPoseDance {
    [UIView animateWithDuration:0.15 animations:^{
        _topBody.transform=CGAffineTransformMakeRotation(-0.02);
        _bottomFront.transform=CGAffineTransformMakeRotation(0.018);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.15 animations:^{
            _topBody.transform=CGAffineTransformMakeRotation(0.02);
            _bottomFront.transform=CGAffineTransformMakeRotation(-0.018);
        } completion:^(BOOL f2){
            [UIView animateWithDuration:0.16 animations:^{ [self setPoseNeutral]; }];
        }];
    }];
}

- (void)setPoseStretch {
    [UIView animateWithDuration:0.20 animations:^{
        _topBody.transform=CGAffineTransformMakeScale(0.99,1.03);
    } completion:^(BOOL f){
        [UIView animateWithDuration:0.22 animations:^{ [self setPoseNeutral]; }];
    }];
}

- (void)dealloc {
    [_leftSleeve release]; [_rightSleeve release];
    [_leftLeg release]; [_rightLeg release];

    [_torsoMask release]; [_hipsMask release];
    [_leftLegMask release]; [_rightLegMask release];

    [_bottomBack release]; [_topBack release]; [_topBody release];
    [_bottomBody release]; [_topFront release]; [_bottomFront release];
    [_host release];
    [super dealloc];
}
@end
