#import "PetCharacterView.h"
#import "PetSpriteAnimator.h"
#import "PetRigView.h"
#import "ClothingRigManager.h"

@implementation PetCharacterView

- (id)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if(self) {
        self.backgroundColor=[UIColor clearColor];
        _useRig=YES;

        _motionLayer=[[UIView alloc] initWithFrame:self.bounds];
        _motionLayer.backgroundColor=[UIColor clearColor];
        [self addSubview:_motionLayer];

        _body=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pet_base_neutral.png"]];
        _body.frame=_motionLayer.bounds;
        _body.contentMode=UIViewContentModeScaleAspectFit;
        _body.hidden=_useRig;
        [_motionLayer addSubview:_body];

        _sprite=[[PetSpriteAnimator alloc] initWithImageView:_body];

        _rig=[[PetRigView alloc] initWithFrame:_motionLayer.bounds];
        _rig.hidden=!_useRig;
        [_motionLayer addSubview:_rig];

        _hatLayer=[[UIView alloc] initWithFrame:_motionLayer.bounds];
        _faceLayer=[[UIView alloc] initWithFrame:_motionLayer.bounds];
        _shirtLayer=[[UIView alloc] initWithFrame:_motionLayer.bounds];
        _pantsLayer=[[UIView alloc] initWithFrame:_motionLayer.bounds];
        _shoesLayer=[[UIView alloc] initWithFrame:_motionLayer.bounds];

        for(UIView *v in [NSArray arrayWithObjects:_shirtLayer,_pantsLayer,_shoesLayer,_hatLayer,_faceLayer,nil]){
            v.backgroundColor=[UIColor clearColor];
            v.userInteractionEnabled=NO;
            v.clipsToBounds=NO;
            [_motionLayer addSubview:v];
        }

        // Explicit depth order: body/rig, top, bottom, shoes, head accessories.
        [_motionLayer bringSubviewToFront:_shirtLayer];
        [_motionLayer bringSubviewToFront:_pantsLayer];
        [_motionLayer bringSubviewToFront:_shoesLayer];
        [_motionLayer bringSubviewToFront:_hatLayer];
        [_motionLayer bringSubviewToFront:_faceLayer];

        _clothingRig=[[ClothingRigManager alloc] initWithHostView:_motionLayer];

        [self reloadOutfit];
    }
    return self;
}

- (void)clear:(UIView *)v {
    for(UIView *s in [[v.subviews copy] autorelease]) [s removeFromSuperview];
}

- (void)addImage:(NSString *)name layer:(UIView *)layer rect:(CGRect)rect {
    UIImage *im=[UIImage imageNamed:[@"Outfits/" stringByAppendingString:name]];
    if(!im) return;
    UIImageView *iv=[[[UIImageView alloc] initWithImage:im] autorelease];
    iv.frame=rect;
    iv.contentMode=UIViewContentModeScaleAspectFit;
    [layer addSubview:iv];
}

- (void)reloadOutfit {
    [self clear:_hatLayer]; [self clear:_faceLayer]; [self clear:_shirtLayer];
    [self clear:_pantsLayer]; [self clear:_shoesLayer];

    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    NSInteger hat=[d integerForKey:@"outfit.hat"];
    NSInteger face=[d integerForKey:@"outfit.face"];
    NSInteger shoes=[d integerForKey:@"outfit.shoes"];
    NSInteger topType=[d integerForKey:@"outfit.topType"];
    NSInteger topStyle=[d integerForKey:@"outfit.topStyle"];
    NSInteger bottomType=[d integerForKey:@"outfit.bottomType"];
    NSInteger bottomStyle=[d integerForKey:@"outfit.bottomStyle"];

    CGFloat W=_motionLayer.bounds.size.width,H=_motionLayer.bounds.size.height;

    if(hat==1) [self addImage:@"hat_blue.png" layer:_hatLayer rect:CGRectMake(W*0.23,H*0.015,W*0.54,H*0.15)];
    else if(hat==2) [self addImage:@"hat_red.png" layer:_hatLayer rect:CGRectMake(W*0.23,H*0.015,W*0.54,H*0.15)];

    if(face==1) [self addImage:@"glasses_star.png" layer:_faceLayer rect:CGRectMake(W*0.25,H*0.205,W*0.50,H*0.15)];
    else if(face==2) [self addImage:@"glasses_black.png" layer:_faceLayer rect:CGRectMake(W*0.25,H*0.205,W*0.50,H*0.15)];

    if(topType==1 && topStyle==2)
        [self addImage:@"tshirt_style2.png" layer:_shirtLayer rect:CGRectMake(W*0.195,H*0.415,W*0.61,H*0.285)];
    else if(topType==2 && topStyle==2)
        [self addImage:@"crop_style2.png" layer:_shirtLayer rect:CGRectMake(W*0.205,H*0.445,W*0.59,H*0.195)];

    if(bottomType==1 && bottomStyle==2)
        [self addImage:@"pants_style2.png" layer:_pantsLayer rect:CGRectMake(W*0.195,H*0.615,W*0.61,H*0.19)];
    else if(bottomType==2 && bottomStyle==2)
        [self addImage:@"skirt_style2.png" layer:_pantsLayer rect:CGRectMake(W*0.19,H*0.600,W*0.62,H*0.22)];

    if(shoes==1) [self addImage:@"shoes_red.png" layer:_shoesLayer rect:CGRectMake(W*0.22,H*0.87,W*0.56,H*0.13)];
    else if(shoes==2) [self addImage:@"shoes_blue.png" layer:_shoesLayer rect:CGRectMake(W*0.22,H*0.87,W*0.56,H*0.13)];

    [_clothingRig reload];
}

- (void)animateWhole:(CGAffineTransform)t duration:(NSTimeInterval)d {
    [UIView animateWithDuration:d animations:^{ _motionLayer.transform=t; }
                     completion:^(BOOL f){
        [UIView animateWithDuration:d animations:^{ _motionLayer.transform=CGAffineTransformIdentity; }];
    }];
}

- (void)startIdle { if(_useRig)[_rig startIdle]; else [_sprite startIdle]; }
- (void)stop { if(_useRig)[_rig stopIdle]; else [_sprite stop]; }
- (void)blink { if(_useRig)[_rig blink]; else [_sprite blink]; }

- (void)happy {
    if(_useRig) [_rig happy]; else [_sprite happy];
    [self animateWhole:CGAffineTransformMakeScale(1.015,1.015) duration:0.16];
}
- (void)sad {
    if(_useRig) [_rig sad]; else [_sprite sad];
}
- (void)touchHead {
    if(_useRig){[_rig happy];[_rig blink];} else {[_sprite happy];[_sprite blink];}
}
- (void)touchBody {
    if(_useRig)[_rig surprise]; else [_sprite touch];
}
- (void)touchFeet {
    if(_useRig)[_rig sad]; else [_sprite sad];
}
- (void)setTalking:(BOOL)t {
    if(_useRig)[_rig setTalking:t]; else {if(t)[_sprite talkStart];else[_sprite talkStop];}
}
- (void)chew { if(_useRig)[_rig happy]; else [_sprite chew]; }
- (void)sleep { if(_useRig)[_rig sad]; else [_sprite sleep]; }
- (void)lookLeft { if(_useRig)[_rig lookLeft]; else [_sprite lookLeft]; }
- (void)lookRight { if(_useRig)[_rig lookRight]; else [_sprite lookRight]; }
- (void)wave { if(_useRig)[_rig wave]; else [_sprite wave]; [_clothingRig setPoseWave]; }
- (void)laugh { if(_useRig)[_rig happy]; else [_sprite laugh]; }
- (void)surprise { if(_useRig)[_rig surprise]; else [_sprite surprise]; }
- (void)stretch {
    if(_useRig)[_rig stretch]; else [_sprite stretch];
    [_clothingRig setPoseStretch];
    [self animateWhole:CGAffineTransformMakeScale(0.99,1.025) duration:0.20];
}
- (void)dance {
    if(_useRig)[_rig dance]; else [_sprite dance];
    [_clothingRig setPoseDance];
    [self animateWhole:CGAffineTransformMakeRotation(0.025) duration:0.16];
}
- (void)jump {
    if(_useRig)[_rig jump]; else [_sprite jump];
    [_clothingRig setPoseJump];
    [self animateWhole:CGAffineTransformMakeTranslation(0,-14) duration:0.15];
}

- (void)dealloc {
    [_clothingRig release];
    [_motionLayer release];
    [_rig release];
    [_sprite release];
    [_body release];
    [_hatLayer release]; [_faceLayer release]; [_shirtLayer release];
    [_pantsLayer release]; [_shoesLayer release];
    [super dealloc];
}
@end
