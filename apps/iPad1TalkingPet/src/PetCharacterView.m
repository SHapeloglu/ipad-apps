#import "PetCharacterView.h"
#import "PetSpriteAnimator.h"
#import "PetRigView.h"

@implementation PetCharacterView

- (id)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if(self) {
        self.backgroundColor=[UIColor clearColor];

        _useRig=YES;

        _body=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pet_base.png"]];
        _body.frame=self.bounds;
        _body.contentMode=UIViewContentModeScaleAspectFit;
        _body.hidden=_useRig;
        [self addSubview:_body];

        _sprite=[[PetSpriteAnimator alloc] initWithImageView:_body];

        _rig=[[PetRigView alloc] initWithFrame:self.bounds];
        _rig.hidden=!_useRig;
        [self addSubview:_rig];

        _hatLayer=[[UIView alloc] initWithFrame:self.bounds];
        _faceLayer=[[UIView alloc] initWithFrame:self.bounds];
        _shirtLayer=[[UIView alloc] initWithFrame:self.bounds];
        _pantsLayer=[[UIView alloc] initWithFrame:self.bounds];
        _shoesLayer=[[UIView alloc] initWithFrame:self.bounds];

        for(UIView *v in [NSArray arrayWithObjects:_shirtLayer,_pantsLayer,_shoesLayer,_hatLayer,_faceLayer,nil]){
            v.backgroundColor=[UIColor clearColor];
            v.userInteractionEnabled=NO;
            [self addSubview:v];
        }

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

    CGFloat W=self.bounds.size.width,H=self.bounds.size.height;

    if(hat==1) [self addImage:@"hat_blue.png" layer:_hatLayer rect:CGRectMake(W*0.23,H*0.015,W*0.54,H*0.15)];
    else if(hat==2) [self addImage:@"hat_red.png" layer:_hatLayer rect:CGRectMake(W*0.23,H*0.015,W*0.54,H*0.15)];

    if(face==1) [self addImage:@"glasses_star.png" layer:_faceLayer rect:CGRectMake(W*0.25,H*0.205,W*0.50,H*0.15)];
    else if(face==2) [self addImage:@"glasses_black.png" layer:_faceLayer rect:CGRectMake(W*0.25,H*0.205,W*0.50,H*0.15)];

    if(topType==1 && topStyle==1)
        [self addImage:@"tshirt_style1.png" layer:_shirtLayer rect:CGRectMake(W*0.205,H*0.405,W*0.59,H*0.315)];
    else if(topType==1 && topStyle==2)
        [self addImage:@"tshirt_style2.png" layer:_shirtLayer rect:CGRectMake(W*0.205,H*0.405,W*0.59,H*0.315)];
    else if(topType==2 && topStyle==1)
        [self addImage:@"crop_style1.png" layer:_shirtLayer rect:CGRectMake(W*0.215,H*0.43,W*0.57,H*0.215)];
    else if(topType==2 && topStyle==2)
        [self addImage:@"crop_style2.png" layer:_shirtLayer rect:CGRectMake(W*0.215,H*0.43,W*0.57,H*0.215)];

    if(bottomType==1 && bottomStyle==1)
        [self addImage:@"pants_style1.png" layer:_pantsLayer rect:CGRectMake(W*0.205,H*0.615,W*0.59,H*0.205)];
    else if(bottomType==1 && bottomStyle==2)
        [self addImage:@"pants_style2.png" layer:_pantsLayer rect:CGRectMake(W*0.205,H*0.615,W*0.59,H*0.205)];
    else if(bottomType==2 && bottomStyle==1)
        [self addImage:@"skirt_style1.png" layer:_pantsLayer rect:CGRectMake(W*0.20,H*0.605,W*0.60,H*0.235)];
    else if(bottomType==2 && bottomStyle==2)
        [self addImage:@"skirt_style2.png" layer:_pantsLayer rect:CGRectMake(W*0.20,H*0.605,W*0.60,H*0.235)];

    if(shoes==1) [self addImage:@"shoes_red.png" layer:_shoesLayer rect:CGRectMake(W*0.22,H*0.87,W*0.56,H*0.13)];
    else if(shoes==2) [self addImage:@"shoes_blue.png" layer:_shoesLayer rect:CGRectMake(W*0.22,H*0.87,W*0.56,H*0.13)];
}

- (void)startIdle { if(_useRig)[_rig startIdle]; else [_sprite startIdle]; }
- (void)stop { if(_useRig)[_rig stopIdle]; else [_sprite stop]; }
- (void)blink { if(_useRig)[_rig blink]; else [_sprite blink]; }
- (void)happy { if(_useRig)[_rig happy]; else [_sprite happy]; }
- (void)sad { if(_useRig)[_rig sad]; else [_sprite sad]; }
- (void)touchHead { if(_useRig){[_rig happy];[_rig blink];} else {[_sprite happy];[_sprite blink];} }
- (void)touchBody { if(_useRig)[_rig surprise]; else [_sprite touch]; }
- (void)touchFeet { if(_useRig)[_rig sad]; else [_sprite sad]; }
- (void)setTalking:(BOOL)t { if(_useRig)[_rig setTalking:t]; else {if(t)[_sprite talkStart];else[_sprite talkStop];} }
- (void)chew { if(_useRig)[_rig happy]; else [_sprite chew]; }
- (void)sleep { if(_useRig)[_rig sad]; else [_sprite sleep]; }
- (void)lookLeft { if(_useRig)[_rig lookLeft]; else [_sprite lookLeft]; }
- (void)lookRight { if(_useRig)[_rig lookRight]; else [_sprite lookRight]; }
- (void)wave { if(_useRig)[_rig wave]; else [_sprite wave]; }
- (void)laugh { if(_useRig)[_rig happy]; else [_sprite laugh]; }
- (void)surprise { if(_useRig)[_rig surprise]; else [_sprite surprise]; }
- (void)stretch { if(_useRig)[_rig stretch]; else [_sprite stretch]; }
- (void)dance { if(_useRig)[_rig dance]; else [_sprite dance]; }
- (void)jump { if(_useRig)[_rig jump]; else [_sprite jump]; }

- (void)dealloc {
    [_rig release];
    [_sprite release];
    [_body release];
    [_hatLayer release]; [_faceLayer release]; [_shirtLayer release];
    [_pantsLayer release]; [_shoesLayer release];
    [super dealloc];
}
@end
