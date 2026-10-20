#import "PetAccessoryView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PetAccessoryView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        [self reloadSelectedOutfit];
    }
    return self;
}

- (void)reloadSelectedOutfit {
    NSArray *copy = [[self.subviews copy] autorelease];
    for (UIView *v in copy) [v removeFromSuperview];

    NSInteger idx = [[NSUserDefaults standardUserDefaults] integerForKey:@"wardrobe.selected"];

    if (idx == 1) {
        UIView *hat = [[[UIView alloc] initWithFrame:CGRectMake(85, 0, 150, 48)] autorelease];
        hat.backgroundColor = [UIColor colorWithRed:0.16 green:0.35 blue:0.80 alpha:0.95];
        hat.layer.cornerRadius = 22;
        [self addSubview:hat];

        UIView *brim = [[[UIView alloc] initWithFrame:CGRectMake(55, 38, 210, 18)] autorelease];
        brim.backgroundColor = [UIColor colorWithRed:0.10 green:0.24 blue:0.62 alpha:0.95];
        brim.layer.cornerRadius = 8;
        [self addSubview:brim];
    } else if (idx == 2) {
        UIView *left = [[[UIView alloc] initWithFrame:CGRectMake(75, 95, 78, 52)] autorelease];
        UIView *right = [[[UIView alloc] initWithFrame:CGRectMake(169, 95, 78, 52)] autorelease];
        left.backgroundColor = [UIColor colorWithRed:0.25 green:0.55 blue:0.95 alpha:0.45];
        right.backgroundColor = left.backgroundColor;
        left.layer.borderWidth = 6; right.layer.borderWidth = 6;
        left.layer.borderColor = [UIColor colorWithRed:0.55 green:0.08 blue:0.45 alpha:1].CGColor;
        right.layer.borderColor = left.layer.borderColor;
        left.layer.cornerRadius = 22; right.layer.cornerRadius = 22;
        [self addSubview:left]; [self addSubview:right];

        UIView *bridge = [[[UIView alloc] initWithFrame:CGRectMake(150, 116, 22, 8)] autorelease];
        bridge.backgroundColor = [UIColor colorWithRed:0.55 green:0.08 blue:0.45 alpha:1];
        [self addSubview:bridge];
    }
}

@end
