#import "PKAmbientObjectView.h"

@implementation PKAmbientObjectView

@synthesize objectIdentifier = _objectIdentifier;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame objectIdentifier:@"tree"];
}

- (id)initWithFrame:(CGRect)frame objectIdentifier:(NSString *)identifier {
    self = [super initWithFrame:frame];
    if (self) {
        _objectIdentifier = [identifier copy];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setObjectIdentifier:(NSString *)objectIdentifier {
    if (_objectIdentifier != objectIdentifier) {
        [_objectIdentifier release];
        _objectIdentifier = [objectIdentifier copy];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGContextSetAllowsAntialiasing(context, true);

    if ([_objectIdentifier isEqualToString:@"flag"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.36f green:0.29f blue:0.24f alpha:1.0f].CGColor);
        CGContextFillRect(context, CGRectMake(w * 0.27f, h * 0.10f, MAX(4.0f, w * 0.08f), h * 0.82f));
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.96f green:0.42f blue:0.34f alpha:1.0f].CGColor);
        CGContextMoveToPoint(context, w * 0.34f, h * 0.14f);
        CGContextAddLineToPoint(context, w * 0.95f, h * 0.28f);
        CGContextAddLineToPoint(context, w * 0.34f, h * 0.47f);
        CGContextClosePath(context);
        CGContextFillPath(context);
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.98f green:0.79f blue:0.24f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.19f, h * 0.04f, w * 0.23f, w * 0.23f));
    } else if ([_objectIdentifier isEqualToString:@"lantern"]) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.29f green:0.25f blue:0.31f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, MAX(3.0f, w * 0.06f));
        CGContextMoveToPoint(context, w * 0.50f, 0.0f);
        CGContextAddLineToPoint(context, w * 0.50f, h * 0.24f);
        CGContextStrokePath(context);
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.82f blue:0.27f alpha:0.30f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.06f, h * 0.18f, w * 0.88f, w * 0.88f));
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.74f blue:0.16f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.24f, h * 0.34f, w * 0.52f, w * 0.52f));
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.45f green:0.28f blue:0.18f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, 3.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(w * 0.24f, h * 0.34f, w * 0.52f, w * 0.52f));
    } else {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.47f green:0.29f blue:0.17f alpha:1.0f].CGColor);
        CGContextFillRect(context, CGRectMake(w * 0.42f, h * 0.48f, w * 0.18f, h * 0.48f));
        UIColor *leaf = [UIColor colorWithRed:0.22f green:0.61f blue:0.31f alpha:1.0f];
        CGContextSetFillColorWithColor(context, leaf.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.04f, h * 0.19f, w * 0.58f, h * 0.50f));
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.38f, h * 0.06f, w * 0.58f, h * 0.54f));
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.25f, h * 0.26f, w * 0.62f, h * 0.48f));
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.95f green:0.48f blue:0.48f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.25f, h * 0.38f, 8.0f, 8.0f));
        CGContextFillEllipseInRect(context, CGRectMake(w * 0.67f, h * 0.31f, 8.0f, 8.0f));
    }
}

- (void)dealloc {
    [_objectIdentifier release];
    [super dealloc];
}

@end
