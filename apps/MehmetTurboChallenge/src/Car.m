#import "Car.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

static void CGContextFillRoundedRect(CGContextRef c, CGRect r, CGFloat radius) {
    CGFloat x = CGRectGetMinX(r);
    CGFloat y = CGRectGetMinY(r);
    CGFloat w = CGRectGetWidth(r);
    CGFloat h = CGRectGetHeight(r);
    CGFloat rr = MIN(radius, MIN(w, h) / 2.0f);

    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x + rr, y);
    CGContextAddLineToPoint(c, x + w - rr, y);
    CGContextAddArcToPoint(c, x + w, y, x + w, y + rr, rr);
    CGContextAddLineToPoint(c, x + w, y + h - rr);
    CGContextAddArcToPoint(c, x + w, y + h, x + w - rr, y + h, rr);
    CGContextAddLineToPoint(c, x + rr, y + h);
    CGContextAddArcToPoint(c, x, y + h, x, y + h - rr, rr);
    CGContextAddLineToPoint(c, x, y + rr);
    CGContextAddArcToPoint(c, x, y, x + rr, y, rr);
    CGContextClosePath(c);
    CGContextFillPath(c);
}

@implementation Car

- (void)drawInRect:(CGRect)rect centerX:(CGFloat)x steering:(CGFloat)steering {
    CGContextRef c = UIGraphicsGetCurrentContext();

    CGFloat cx = CGRectGetMidX(rect) + x * (CGRectGetWidth(rect) * 0.33f);
    CGFloat cy = CGRectGetMaxY(rect) - 116.0f;

    CGContextSaveGState(c);
    CGContextTranslateCTM(c, cx, cy);
    CGContextRotateCTM(c, steering * 0.08f);

    CGRect body = CGRectMake(-38, -58, 76, 116);
    CGContextSetFillColorWithColor(c,
        [UIColor colorWithRed:0.85 green:0.08 blue:0.05 alpha:1].CGColor);
    CGContextFillRoundedRect(c, body, 10);

    CGRect cabin = CGRectMake(-25, -38, 50, 42);
    CGContextSetFillColorWithColor(c,
        [UIColor colorWithWhite:0.12 alpha:1].CGColor);
    CGContextFillRoundedRect(c, cabin, 8);

    CGContextSetFillColorWithColor(c,
        [UIColor colorWithWhite:0.55 alpha:1].CGColor);
    CGContextFillRect(c, CGRectMake(-20, -33, 40, 15));
    CGContextFillRect(c, CGRectMake(-20, -12, 40, 10));

    CGContextSetFillColorWithColor(c, [UIColor blackColor].CGColor);
    CGContextFillRect(c, CGRectMake(-44, -42, 8, 28));
    CGContextFillRect(c, CGRectMake(36, -42, 8, 28));
    CGContextFillRect(c, CGRectMake(-44, 20, 8, 28));
    CGContextFillRect(c, CGRectMake(36, 20, 8, 28));

    CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);
    CGContextFillRect(c, CGRectMake(-26, 38, 16, 7));
    CGContextFillRect(c, CGRectMake(10, 38, 16, 7));

    CGContextRestoreGState(c);
}

@end
