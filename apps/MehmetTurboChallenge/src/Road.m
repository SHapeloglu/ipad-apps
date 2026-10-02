#import "Road.h"
@implementation Road
- (void)drawInRect:(CGRect)r scroll:(CGFloat)scroll {
    CGContextRef c=UIGraphicsGetCurrentContext();
    CGFloat w=CGRectGetWidth(r), h=CGRectGetHeight(r);
    CGContextSetFillColorWithColor(c,[UIColor colorWithRed:0.20 green:0.48 blue:0.18 alpha:1].CGColor); CGContextFillRect(c,r);
    CGPoint topL=CGPointMake(w*0.43, h*0.18), topR=CGPointMake(w*0.57,h*0.18), botR=CGPointMake(w*0.88,h), botL=CGPointMake(w*0.12,h);
    CGContextMoveToPoint(c,topL.x,topL.y); CGContextAddLineToPoint(c,topR.x,topR.y); CGContextAddLineToPoint(c,botR.x,botR.y); CGContextAddLineToPoint(c,botL.x,botL.y); CGContextClosePath(c);
    CGContextSetFillColorWithColor(c,[UIColor colorWithRed:0.17 green:0.17 blue:0.18 alpha:1].CGColor); CGContextFillPath(c);
    CGContextSetStrokeColorWithColor(c,[UIColor colorWithWhite:0.92 alpha:1].CGColor); CGContextSetLineWidth(c,5); CGContextMoveToPoint(c,topL.x,topL.y); CGContextAddLineToPoint(c,botL.x,botL.y); CGContextMoveToPoint(c,topR.x,topR.y); CGContextAddLineToPoint(c,botR.x,botR.y); CGContextStrokePath(c);
    int i; for(i=-1;i<12;i++) {
        CGFloat y=0.22f*h + i*42.0f - scroll;
        if(y<0 || y>h) continue;
        CGFloat t=(y/h); CGFloat half=10 + t*120; CGFloat cx=w*0.5f;
        CGContextSetFillColorWithColor(c,[UIColor colorWithWhite:0.95 alpha:1].CGColor); CGContextFillRect(c,CGRectMake(cx-3,y,6,20));
        (void)half;
    }
}
@end
