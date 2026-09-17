#import "RoomBackgroundView.h"

@implementation RoomBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self=[super initWithFrame:frame];
    if(self){self.opaque=YES;[self reloadTheme];}
    return self;
}

- (void)reloadTheme { [self setNeedsDisplay]; }

- (void)drawImage:(NSString *)name inRect:(CGRect)r {
    UIImage *im=[UIImage imageNamed:[@"Furniture/" stringByAppendingString:name]];
    [im drawInRect:r];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c=UIGraphicsGetCurrentContext();
    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    NSInteger theme=[d integerForKey:@"room.theme"];

    UIColor *wall=nil,*floor=nil;
    if(theme==1){wall=[UIColor colorWithRed:1 green:0.84 blue:0.89 alpha:1];floor=[UIColor colorWithRed:0.72 green:0.48 blue:0.34 alpha:1];}
    else if(theme==2){wall=[UIColor colorWithRed:0.22 green:0.25 blue:0.38 alpha:1];floor=[UIColor colorWithRed:0.25 green:0.20 blue:0.24 alpha:1];}
    else if(theme==3){wall=[UIColor colorWithRed:0.93 green:0.78 blue:0.59 alpha:1];floor=[UIColor colorWithRed:0.62 green:0.40 blue:0.27 alpha:1];}
    else {wall=[UIColor colorWithRed:0.93 green:0.82 blue:0.73 alpha:1];floor=[UIColor colorWithRed:0.67 green:0.45 blue:0.31 alpha:1];}

    [wall setFill];CGContextFillRect(c,CGRectMake(0,0,self.bounds.size.width,720));
    [floor setFill];CGContextFillRect(c,CGRectMake(0,720,self.bounds.size.width,304));

    [[UIColor colorWithRed:0.72 green:0.91 blue:1 alpha:1] setFill];
    CGContextFillRect(c,CGRectMake(70,150,220,270));
    [[UIColor whiteColor] setStroke];CGContextSetLineWidth(c,8);CGContextStrokeRect(c,CGRectMake(70,150,220,270));

    NSInteger sofa=[d integerForKey:@"room.furniture.0"];
    NSInteger rug=[d integerForKey:@"room.furniture.1"];
    NSInteger lamp=[d integerForKey:@"room.furniture.2"];
    NSInteger plant=[d integerForKey:@"room.furniture.4"];

    [self drawImage:[NSString stringWithFormat:@"sofa_%ld.png",(long)(sofa?1:0)] inRect:CGRectMake(10,500,260,150)];
    [self drawImage:[NSString stringWithFormat:@"rug_%ld.png",(long)(rug?1:0)] inRect:CGRectMake(245,760,280,120)];
    [self drawImage:[NSString stringWithFormat:@"lamp_%ld.png",(long)(lamp?1:0)] inRect:CGRectMake(585,400,100,180)];
    [self drawImage:[NSString stringWithFormat:@"plant_%ld.png",(long)(plant?1:0)] inRect:CGRectMake(650,300,120,180)];

    // Cabinet
    [[UIColor colorWithRed:0.68 green:0.45 blue:0.33 alpha:1] setFill];
    CGContextFillRect(c,CGRectMake(600,550,145,150));
}

@end
