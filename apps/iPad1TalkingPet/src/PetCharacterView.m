#import "PetCharacterView.h"
#import "PetSpriteAnimator.h"

@implementation PetCharacterView

- (id)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if(self) {
        self.backgroundColor=[UIColor clearColor];

        _body=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pet_base.png"]];
        _body.frame=self.bounds;
        _body.contentMode=UIViewContentModeScaleAspectFit;
        [self addSubview:_body];

        _sprite=[[PetSpriteAnimator alloc] initWithImageView:_body];

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
    [self clear:_hatLayer];
    [self clear:_faceLayer];
    [self clear:_shirtLayer];
    [self clear:_pantsLayer];
    [self clear:_shoesLayer];

    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];

    NSInteger hat=[d integerForKey:@"outfit.hat"];
    NSInteger face=[d integerForKey:@"outfit.face"];
    NSInteger shoes=[d integerForKey:@"outfit.shoes"];

    NSInteger topType=[d integerForKey:@"outfit.topType"];
    NSInteger topStyle=[d integerForKey:@"outfit.topStyle"];
    NSInteger bottomType=[d integerForKey:@"outfit.bottomType"];
    NSInteger bottomStyle=[d integerForKey:@"outfit.bottomStyle"];

    CGFloat W=self.bounds.size.width;
    CGFloat H=self.bounds.size.height;

    // Existing head accessories
    if(hat==1) [self addImage:@"hat_blue.png" layer:_hatLayer rect:CGRectMake(W*0.23,H*0.015,W*0.54,H*0.15)];
    else if(hat==2) [self addImage:@"hat_red.png" layer:_hatLayer rect:CGRectMake(W*0.23,H*0.015,W*0.54,H*0.15)];

    if(face==1) [self addImage:@"glasses_star.png" layer:_faceLayer rect:CGRectMake(W*0.25,H*0.205,W*0.50,H*0.15)];
    else if(face==2) [self addImage:@"glasses_black.png" layer:_faceLayer rect:CGRectMake(W*0.25,H*0.205,W*0.50,H*0.15)];

    // Tops tailored to torso
    if(topType==1 && topStyle==1)
        [self addImage:@"tshirt_style1.png" layer:_shirtLayer rect:CGRectMake(W*0.22,H*0.405,W*0.56,H*0.34)];
    else if(topType==1 && topStyle==2)
        [self addImage:@"tshirt_style2.png" layer:_shirtLayer rect:CGRectMake(W*0.22,H*0.405,W*0.56,H*0.34)];
    else if(topType==2 && topStyle==1)
        [self addImage:@"crop_style1.png" layer:_shirtLayer rect:CGRectMake(W*0.24,H*0.43,W*0.52,H*0.24)];
    else if(topType==2 && topStyle==2)
        [self addImage:@"crop_style2.png" layer:_shirtLayer rect:CGRectMake(W*0.24,H*0.43,W*0.52,H*0.24)];

    // Bottoms tailored to hip/leg area
    if(bottomType==1 && bottomStyle==1)
        [self addImage:@"pants_style1.png" layer:_pantsLayer rect:CGRectMake(W*0.25,H*0.63,W*0.50,H*0.24)];
    else if(bottomType==1 && bottomStyle==2)
        [self addImage:@"pants_style2.png" layer:_pantsLayer rect:CGRectMake(W*0.25,H*0.63,W*0.50,H*0.24)];
    else if(bottomType==2 && bottomStyle==1)
        [self addImage:@"skirt_style1.png" layer:_pantsLayer rect:CGRectMake(W*0.23,H*0.62,W*0.54,H*0.25)];
    else if(bottomType==2 && bottomStyle==2)
        [self addImage:@"skirt_style2.png" layer:_pantsLayer rect:CGRectMake(W*0.23,H*0.62,W*0.54,H*0.25)];

    if(shoes==1) [self addImage:@"shoes_red.png" layer:_shoesLayer rect:CGRectMake(W*0.22,H*0.87,W*0.56,H*0.13)];
    else if(shoes==2) [self addImage:@"shoes_blue.png" layer:_shoesLayer rect:CGRectMake(W*0.22,H*0.87,W*0.56,H*0.13)];
}

- (void)startIdle{[_sprite startIdle];}
- (void)stop{[_sprite stop];}
- (void)blink{[_sprite blink];}
- (void)happy{[_sprite happy];}
- (void)sad{[_sprite sad];}
- (void)touchHead{[_sprite happy];[_sprite blink];}
- (void)touchBody{[_sprite touch];}
- (void)touchFeet{[_sprite sad];}
- (void)setTalking:(BOOL)t{if(t)[_sprite talkStart];else[_sprite talkStop];}
- (void)chew{[_sprite chew];}
- (void)sleep{[_sprite sleep];}

- (void)dealloc {
    [_sprite release];
    [_body release];
    [_hatLayer release];
    [_faceLayer release];
    [_shirtLayer release];
    [_pantsLayer release];
    [_shoesLayer release];
    [super dealloc];
}
@end
