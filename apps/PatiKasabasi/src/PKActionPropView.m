#import "PKActionPropView.h"
#import <QuartzCore/QuartzCore.h>

static void PKPropFillEllipse(CGContextRef context, CGRect frame, UIColor *color) {
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, frame);
}

static NSString *PKPropTitle(NSString *identifier) {
    if ([identifier isEqualToString:@"ball"]) return @"Top";
    if ([identifier isEqualToString:@"brush"]) return @"Fırça";
    if ([identifier isEqualToString:@"food_fish"]) return @"Balık";
    if ([identifier isEqualToString:@"food_carrot"]) return @"Havuç";
    if ([identifier isEqualToString:@"food_cookie"]) return @"Kurabiye";
    return @"Mama";
}

@implementation PKActionPropView

@synthesize propIdentifier = _propIdentifier;
@synthesize depleted = _depleted;
@synthesize targeted = _targeted;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame propIdentifier:@"food_kibble"];
}

- (id)initWithFrame:(CGRect)frame propIdentifier:(NSString *)propIdentifier {
    self = [super initWithFrame:frame];
    if (self) {
        _propIdentifier = [propIdentifier copy];
        _depleted = NO;
        _targeted = NO;
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.88f];
        self.opaque = NO;
        self.layer.cornerRadius = 18.0f;
        self.layer.borderWidth = 3.0f;
        self.layer.borderColor = [UIColor colorWithRed:0.17f green:0.43f blue:0.47f alpha:1.0f].CGColor;
        self.contentMode = UIViewContentModeRedraw;
        self.accessibilityTraits = UIAccessibilityTraitButton;
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = [NSString stringWithFormat:@"%@; yavrunun üzerine sürükle", PKPropTitle(_propIdentifier)];
    }
    return self;
}

- (void)setPropIdentifier:(NSString *)propIdentifier {
    if (_propIdentifier != propIdentifier) {
        [_propIdentifier release];
        _propIdentifier = [propIdentifier copy];
        self.accessibilityLabel = [NSString stringWithFormat:@"%@; yavrunun üzerine sürükle", PKPropTitle(_propIdentifier)];
        [self setNeedsDisplay];
    }
}

- (void)setDepleted:(BOOL)depleted {
    _depleted = depleted;
    [self setNeedsDisplay];
}

- (void)setTargeted:(BOOL)targeted {
    _targeted = targeted;
    self.layer.borderWidth = targeted ? 7.0f : 3.0f;
    UIColor *borderColor = targeted ? [UIColor colorWithRed:1.0f green:0.73f blue:0.12f alpha:1.0f] : [UIColor colorWithRed:0.17f green:0.43f blue:0.47f alpha:1.0f];
    self.layer.borderColor = borderColor.CGColor;
    [self setNeedsDisplay];
}

- (NSString *)actionIdentifier {
    if ([_propIdentifier isEqualToString:@"ball"]) return @"play";
    if ([_propIdentifier isEqualToString:@"brush"]) return @"clean";
    return @"feed";
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    (void)event;
    return CGRectContainsPoint(CGRectInset(self.bounds, -8.0f, -8.0f), point);
}

- (void)drawFoodInContext:(CGContextRef)context rect:(CGRect)rect {
    CGFloat cx = CGRectGetMidX(rect);
    UIColor *bowl = [UIColor colorWithRed:0.25f green:0.58f blue:0.73f alpha:1.0f];
    UIColor *rim = [UIColor colorWithRed:0.12f green:0.36f blue:0.50f alpha:1.0f];
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.13f].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(cx - 38.0f, 51.0f, 76.0f, 12.0f));
    CGContextSetFillColorWithColor(context, bowl.CGColor);
    CGContextMoveToPoint(context, cx - 35.0f, 33.0f);
    CGContextAddLineToPoint(context, cx + 35.0f, 33.0f);
    CGContextAddQuadCurveToPoint(context, cx + 29.0f, 58.0f, cx + 20.0f, 59.0f);
    CGContextAddLineToPoint(context, cx - 20.0f, 59.0f);
    CGContextAddQuadCurveToPoint(context, cx - 29.0f, 58.0f, cx - 35.0f, 33.0f);
    CGContextClosePath(context);
    CGContextFillPath(context);
    PKPropFillEllipse(context, CGRectMake(cx - 38.0f, 24.0f, 76.0f, 24.0f), rim);
    UIColor *inside = _depleted ? [UIColor colorWithRed:0.69f green:0.82f blue:0.87f alpha:1.0f] : [UIColor colorWithRed:0.90f green:0.78f blue:0.52f alpha:1.0f];
    PKPropFillEllipse(context, CGRectMake(cx - 32.0f, 28.0f, 64.0f, 16.0f), inside);
    if (!_depleted) {
        if ([_propIdentifier isEqualToString:@"food_fish"]) {
            UIColor *fish = [UIColor colorWithRed:0.28f green:0.70f blue:0.78f alpha:1.0f];
            PKPropFillEllipse(context, CGRectMake(cx - 19.0f, 27.0f, 38.0f, 16.0f), fish);
            CGContextSetFillColorWithColor(context, fish.CGColor);
            CGContextMoveToPoint(context, cx + 17.0f, 35.0f);
            CGContextAddLineToPoint(context, cx + 31.0f, 26.0f);
            CGContextAddLineToPoint(context, cx + 31.0f, 44.0f);
            CGContextClosePath(context);
            CGContextFillPath(context);
            PKPropFillEllipse(context, CGRectMake(cx - 11.0f, 31.0f, 3.0f, 3.0f), [UIColor whiteColor]);
        } else if ([_propIdentifier isEqualToString:@"food_carrot"]) {
            UIColor *orange = [UIColor colorWithRed:0.96f green:0.47f blue:0.16f alpha:1.0f];
            CGContextSetFillColorWithColor(context, orange.CGColor);
            CGContextMoveToPoint(context, cx - 22.0f, 27.0f);
            CGContextAddLineToPoint(context, cx + 18.0f, 31.0f);
            CGContextAddLineToPoint(context, cx + 24.0f, 42.0f);
            CGContextAddLineToPoint(context, cx - 19.0f, 40.0f);
            CGContextClosePath(context);
            CGContextFillPath(context);
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.25f green:0.65f blue:0.31f alpha:1.0f].CGColor);
            CGContextSetLineWidth(context, 4.0f);
            CGContextMoveToPoint(context, cx - 20.0f, 31.0f);
            CGContextAddLineToPoint(context, cx - 30.0f, 22.0f);
            CGContextMoveToPoint(context, cx - 18.0f, 31.0f);
            CGContextAddLineToPoint(context, cx - 20.0f, 19.0f);
            CGContextStrokePath(context);
        } else if ([_propIdentifier isEqualToString:@"food_cookie"]) {
            UIColor *cookie = [UIColor colorWithRed:0.82f green:0.57f blue:0.28f alpha:1.0f];
            PKPropFillEllipse(context, CGRectMake(cx - 18.0f, 23.0f, 36.0f, 26.0f), cookie);
            UIColor *chip = [UIColor colorWithRed:0.34f green:0.21f blue:0.14f alpha:1.0f];
            PKPropFillEllipse(context, CGRectMake(cx - 10.0f, 29.0f, 5.0f, 5.0f), chip);
            PKPropFillEllipse(context, CGRectMake(cx + 5.0f, 26.0f, 5.0f, 5.0f), chip);
            PKPropFillEllipse(context, CGRectMake(cx + 1.0f, 38.0f, 5.0f, 5.0f), chip);
        } else {
            UIColor *kibble = [UIColor colorWithRed:0.43f green:0.27f blue:0.16f alpha:1.0f];
            PKPropFillEllipse(context, CGRectMake(cx - 23.0f, 29.0f, 10.0f, 8.0f), kibble);
            PKPropFillEllipse(context, CGRectMake(cx - 4.0f, 34.0f, 11.0f, 8.0f), kibble);
            PKPropFillEllipse(context, CGRectMake(cx + 15.0f, 29.0f, 10.0f, 8.0f), kibble);
        }
    }
    UIColor *paw = [UIColor colorWithWhite:1.0f alpha:0.88f];
    PKPropFillEllipse(context, CGRectMake(cx - 5.0f, 47.0f, 10.0f, 8.0f), paw);
    PKPropFillEllipse(context, CGRectMake(cx - 11.0f, 43.0f, 5.0f, 5.0f), paw);
    PKPropFillEllipse(context, CGRectMake(cx - 2.5f, 40.0f, 5.0f, 5.0f), paw);
    PKPropFillEllipse(context, CGRectMake(cx + 6.0f, 43.0f, 5.0f, 5.0f), paw);
}

- (void)drawBallInContext:(CGContextRef)context rect:(CGRect)rect {
    CGFloat cx = CGRectGetMidX(rect);
    CGRect ballFrame = CGRectMake(cx - 29.0f, 8.0f, 58.0f, 58.0f);
    PKPropFillEllipse(context, ballFrame, [UIColor colorWithRed:0.94f green:0.30f blue:0.39f alpha:1.0f]);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.86f].CGColor);
    CGContextSetLineWidth(context, 5.0f);
    CGContextAddArc(context, cx, 37.0f, 20.0f, -1.0f, 1.05f, 0);
    CGContextStrokePath(context);
    CGContextAddArc(context, cx, 37.0f, 20.0f, 2.15f, 4.15f, 0);
    CGContextStrokePath(context);
}

- (void)drawBrushInContext:(CGContextRef)context rect:(CGRect)rect {
    CGFloat cx = CGRectGetMidX(rect);
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, cx, 34.0f);
    CGContextRotateCTM(context, -0.42f);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.91f green:0.58f blue:0.31f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(-7.0f, -1.0f, 55.0f, 14.0f));
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.33f green:0.70f blue:0.78f alpha:1.0f].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(-43.0f, -14.0f, 45.0f, 40.0f));
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.88f].CGColor);
    CGContextSetLineWidth(context, 3.0f);
    CGFloat x = -34.0f;
    while (x <= -8.0f) {
        CGContextMoveToPoint(context, x, 17.0f);
        CGContextAddLineToPoint(context, x, 28.0f);
        x += 8.0f;
    }
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    if (_targeted) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.83f blue:0.22f alpha:0.19f].CGColor);
        CGContextFillEllipseInRect(context, CGRectInset(rect, 5.0f, 5.0f));
    }
    if ([_propIdentifier isEqualToString:@"ball"]) [self drawBallInContext:context rect:rect];
    else if ([_propIdentifier isEqualToString:@"brush"]) [self drawBrushInContext:context rect:rect];
    else [self drawFoodInContext:context rect:rect];

    NSString *title = PKPropTitle(_propIdentifier);
    [[UIColor colorWithRed:0.14f green:0.28f blue:0.31f alpha:1.0f] set];
    [title drawInRect:CGRectMake(4.0f, rect.size.height - 24.0f, rect.size.width - 8.0f, 20.0f)
             withFont:[UIFont boldSystemFontOfSize:14.0f]
        lineBreakMode:UILineBreakModeTailTruncation
            alignment:UITextAlignmentCenter];
}

- (void)dealloc {
    [_propIdentifier release];
    [super dealloc];
}

@end
