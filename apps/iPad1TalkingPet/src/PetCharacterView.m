#import "PetCharacterView.h"
#import "PetSpriteAnimator.h"
#import <QuartzCore/QuartzCore.h>

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

- (void)clear:(UIView *)v { for(UIView *s in [[v.subviews copy] autorelease]) [s removeFromSuperview]; }
- (UIView *)rounded:(CGRect)r color:(UIColor *)c radius:(CGFloat)rad {
    UIView *v=[[[UIView alloc] initWithFrame:r] autorelease];
    v.backgroundColor=c; v.layer.cornerRadius=rad; return v;
}

- (void)reloadOutfit {
    [self clear:_hatLayer]; [self clear:_faceLayer]; [self clear:_shirtLayer]; [self clear:_pantsLayer]; [self clear:_shoesLayer];
    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    NSInteger hat=[d integerForKey:@"outfit.hat"], face=[d integerForKey:@"outfit.face"];
    NSInteger shirt=[d integerForKey:@"outfit.shirt"], pants=[d integerForKey:@"outfit.pants"], shoes=[d integerForKey:@"outfit.shoes"];
    CGFloat W=self.bounds.size.width,H=self.bounds.size.height;

    if(hat>0){
        UIColor *hc=hat==1?[UIColor colorWithRed:0.10 green:0.32 blue:0.78 alpha:0.96]:
                           [UIColor colorWithRed:0.72 green:0.10 blue:0.18 alpha:0.96];
        [_hatLayer addSubview:[self rounded:CGRectMake(W*0.31,H*0.03,W*0.38,H*0.075) color:hc radius:18]];
        [_hatLayer addSubview:[self rounded:CGRectMake(W*0.25,H*0.09,W*0.50,H*0.026) color:hc radius:7]];
    }
    if(face>0){
        UIColor *fc=face==1?[UIColor colorWithRed:0.35 green:0.62 blue:1 alpha:0.28]:
                            [UIColor colorWithRed:0.10 green:0.10 blue:0.12 alpha:0.40];
        UIView *l=[self rounded:CGRectMake(W*0.32,H*0.235,W*0.18,H*0.075) color:fc radius:18];
        UIView *r=[self rounded:CGRectMake(W*0.51,H*0.235,W*0.18,H*0.075) color:fc radius:18];
        l.layer.borderWidth=5;r.layer.borderWidth=5;
        l.layer.borderColor=[UIColor colorWithRed:0.60 green:0.05 blue:0.48 alpha:1].CGColor;
        r.layer.borderColor=l.layer.borderColor;
        [_faceLayer addSubview:l];[_faceLayer addSubview:r];
    }
    if(shirt>0){
        UIColor *c=shirt==1?[UIColor colorWithRed:0.42 green:0.28 blue:0.82 alpha:0.70]:
                             [UIColor colorWithRed:0.08 green:0.58 blue:0.72 alpha:0.70];
        [_shirtLayer addSubview:[self rounded:CGRectMake(W*0.29,H*0.45,W*0.42,H*0.22) color:c radius:24]];
    }
    if(pants>0){
        UIColor *c=pants==1?[UIColor colorWithRed:0.12 green:0.20 blue:0.45 alpha:0.72]:
                             [UIColor colorWithRed:0.18 green:0.45 blue:0.70 alpha:0.72];
        [_pantsLayer addSubview:[self rounded:CGRectMake(W*0.32,H*0.66,W*0.36,H*0.13) color:c radius:16]];
    }
    if(shoes>0){
        UIColor *c=shoes==1?[UIColor colorWithRed:0.82 green:0.10 blue:0.12 alpha:0.86]:
                             [UIColor colorWithRed:0.12 green:0.25 blue:0.80 alpha:0.86];
        [_shoesLayer addSubview:[self rounded:CGRectMake(W*0.29,H*0.91,W*0.17,H*0.05) color:c radius:12]];
        [_shoesLayer addSubview:[self rounded:CGRectMake(W*0.54,H*0.91,W*0.17,H*0.05) color:c radius:12]];
    }
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

- (void)dealloc{
    [_sprite release];[_body release];[_hatLayer release];[_faceLayer release];
    [_shirtLayer release];[_pantsLayer release];[_shoesLayer release];[super dealloc];
}
@end
