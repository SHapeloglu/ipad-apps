#import "RoomBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RoomBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        [self reloadTheme];
    }
    return self;
}

- (void)reloadTheme {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    NSInteger theme = [[NSUserDefaults standardUserDefaults] integerForKey:@"room.theme"];

    UIColor *wall = nil;
    UIColor *floor = nil;
    UIColor *accent = nil;

    if (theme == 1) {
        wall = [UIColor colorWithRed:1.0 green:0.84 blue:0.89 alpha:1.0];
        floor = [UIColor colorWithRed:0.72 green:0.48 blue:0.34 alpha:1.0];
        accent = [UIColor colorWithRed:0.95 green:0.45 blue:0.62 alpha:1.0];
    } else if (theme == 2) {
        wall = [UIColor colorWithRed:0.22 green:0.25 blue:0.38 alpha:1.0];
        floor = [UIColor colorWithRed:0.25 green:0.20 blue:0.24 alpha:1.0];
        accent = [UIColor colorWithRed:0.38 green:0.42 blue:0.72 alpha:1.0];
    } else if (theme == 3) {
        wall = [UIColor colorWithRed:0.93 green:0.78 blue:0.59 alpha:1.0];
        floor = [UIColor colorWithRed:0.62 green:0.40 blue:0.27 alpha:1.0];
        accent = [UIColor colorWithRed:0.85 green:0.48 blue:0.24 alpha:1.0];
    } else {
        wall = [UIColor colorWithRed:0.93 green:0.82 blue:0.73 alpha:1.0];
        floor = [UIColor colorWithRed:0.67 green:0.45 blue:0.31 alpha:1.0];
        accent = [UIColor colorWithRed:0.93 green:0.58 blue:0.66 alpha:1.0];
    }

    [wall setFill];
    CGContextFillRect(c, CGRectMake(0, 0, self.bounds.size.width, 720));

    [floor setFill];
    CGContextFillRect(c, CGRectMake(0, 720, self.bounds.size.width, 304));

    // Window
    [[UIColor colorWithRed:0.72 green:0.91 blue:1 alpha:1] setFill];
    CGContextFillRect(c, CGRectMake(70, 150, 220, 270));
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(c, 8);
    CGContextStrokeRect(c, CGRectMake(70,150,220,270));
    CGContextMoveToPoint(c,180,150); CGContextAddLineToPoint(c,180,420);
    CGContextMoveToPoint(c,70,285); CGContextAddLineToPoint(c,290,285);
    CGContextStrokePath(c);

    // Curtains
    [accent setFill];
    CGContextFillRect(c, CGRectMake(35, 120, 48, 365));
    CGContextFillRect(c, CGRectMake(277, 120, 48, 365));

    // Cabinet
    [[UIColor colorWithRed:0.68 green:0.45 blue:0.33 alpha:1] setFill];
    CGContextFillRect(c, CGRectMake(595, 455, 150, 235));
    [[UIColor colorWithRed:0.82 green:0.62 blue:0.48 alpha:1] setStroke];
    CGContextSetLineWidth(c, 4);
    CGContextStrokeRect(c, CGRectMake(595,455,150,235));
    CGContextMoveToPoint(c,595,530); CGContextAddLineToPoint(c,745,530);
    CGContextMoveToPoint(c,595,605); CGContextAddLineToPoint(c,745,605);
    CGContextStrokePath(c);

    // Sofa
    [accent setFill];
    UIBezierPath *sofa = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(25, 500, 210, 150) cornerRadius:28];
    [sofa fill];
    UIBezierPath *seat = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(42, 565, 176, 80) cornerRadius:18];
    [[UIColor colorWithWhite:1 alpha:0.17] setFill];
    [seat fill];

    // Rug
    [accent setFill];
    CGContextSaveGState(c);
    CGContextTranslateCTM(c, 385, 840);
    CGContextScaleCTM(c, 1.7, 0.55);
    CGContextFillEllipseInRect(c, CGRectMake(-150,-80,300,160));
    CGContextRestoreGState(c);

    // Plant
    [[UIColor colorWithRed:0.42 green:0.25 blue:0.18 alpha:1] setFill];
    CGContextFillRect(c, CGRectMake(665,365,55,65));
    [[UIColor colorWithRed:0.20 green:0.55 blue:0.26 alpha:1] setFill];
    for (NSInteger i=0; i<5; i++) {
        CGContextFillEllipseInRect(c, CGRectMake(635+i*18, 315+(i%2)*18, 55, 90));
    }
}

@end
