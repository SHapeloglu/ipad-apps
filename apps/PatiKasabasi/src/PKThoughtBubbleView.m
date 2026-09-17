#import "PKThoughtBubbleView.h"

static void PKBubbleFillEllipse(CGContextRef context, CGRect frame, UIColor *color) {
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, frame);
}

@implementation PKThoughtBubbleView

@synthesize text = _text;
@synthesize iconIdentifier = _iconIdentifier;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame text:@"" iconIdentifier:@"happy"];
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)text iconIdentifier:(NSString *)iconIdentifier {
    self = [super initWithFrame:frame];
    if (self) {
        _text = [text copy];
        _iconIdentifier = [iconIdentifier copy];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.isAccessibilityElement = YES;
    }
    return self;
}

- (void)setText:(NSString *)text {
    if (_text != text) {
        [_text release];
        _text = [text copy];
        self.accessibilityLabel = _text;
        [self setNeedsDisplay];
    }
}

- (void)setIconIdentifier:(NSString *)iconIdentifier {
    if (_iconIdentifier != iconIdentifier) {
        [_iconIdentifier release];
        _iconIdentifier = [iconIdentifier copy];
        [self setNeedsDisplay];
    }
}

- (void)drawIconInContext:(CGContextRef)context frame:(CGRect)frame {
    CGFloat cx = CGRectGetMidX(frame);
    CGFloat cy = CGRectGetMidY(frame);
    if ([_iconIdentifier isEqualToString:@"food"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.23f green:0.58f blue:0.73f alpha:1.0f].CGColor);
        CGContextMoveToPoint(context, cx - 24.0f, cy - 2.0f);
        CGContextAddLineToPoint(context, cx + 24.0f, cy - 2.0f);
        CGContextAddQuadCurveToPoint(context, cx + 17.0f, cy + 20.0f, cx + 10.0f, cy + 20.0f);
        CGContextAddLineToPoint(context, cx - 10.0f, cy + 20.0f);
        CGContextAddQuadCurveToPoint(context, cx - 17.0f, cy + 20.0f, cx - 24.0f, cy - 2.0f);
        CGContextClosePath(context);
        CGContextFillPath(context);
        PKBubbleFillEllipse(context, CGRectMake(cx - 26.0f, cy - 10.0f, 52.0f, 18.0f), [UIColor colorWithRed:0.45f green:0.28f blue:0.16f alpha:1.0f]);
    } else if ([_iconIdentifier isEqualToString:@"play"]) {
        PKBubbleFillEllipse(context, CGRectMake(cx - 25.0f, cy - 25.0f, 50.0f, 50.0f), [UIColor colorWithRed:0.94f green:0.30f blue:0.39f alpha:1.0f]);
    } else if ([_iconIdentifier isEqualToString:@"clean"]) {
        PKBubbleFillEllipse(context, CGRectMake(cx - 23.0f, cy - 18.0f, 28.0f, 28.0f), [UIColor colorWithRed:0.42f green:0.79f blue:0.91f alpha:0.82f]);
        PKBubbleFillEllipse(context, CGRectMake(cx + 4.0f, cy - 25.0f, 20.0f, 20.0f), [UIColor colorWithRed:0.42f green:0.79f blue:0.91f alpha:0.82f]);
        PKBubbleFillEllipse(context, CGRectMake(cx + 7.0f, cy + 5.0f, 15.0f, 15.0f), [UIColor colorWithRed:0.42f green:0.79f blue:0.91f alpha:0.82f]);
    } else if ([_iconIdentifier isEqualToString:@"cuddle"] || [_iconIdentifier isEqualToString:@"social"]) {
        UIColor *heart = [UIColor colorWithRed:0.94f green:0.28f blue:0.45f alpha:1.0f];
        PKBubbleFillEllipse(context, CGRectMake(cx - 25.0f, cy - 20.0f, 28.0f, 28.0f), heart);
        PKBubbleFillEllipse(context, CGRectMake(cx - 2.0f, cy - 20.0f, 28.0f, 28.0f), heart);
        CGContextSetFillColorWithColor(context, heart.CGColor);
        CGContextMoveToPoint(context, cx - 25.0f, cy - 5.0f);
        CGContextAddLineToPoint(context, cx + 26.0f, cy - 5.0f);
        CGContextAddLineToPoint(context, cx, cy + 27.0f);
        CGContextClosePath(context);
        CGContextFillPath(context);
    } else {
        NSString *symbol = @"★";
        if ([_iconIdentifier isEqualToString:@"sleep"]) symbol = @"Zz";
        else if ([_iconIdentifier isEqualToString:@"music"]) symbol = @"♪";
        else if ([_iconIdentifier isEqualToString:@"curious"]) symbol = @"?";
        [[UIColor colorWithRed:0.17f green:0.43f blue:0.47f alpha:1.0f] set];
        [symbol drawInRect:frame
                  withFont:[UIFont boldSystemFontOfSize:34.0f]
             lineBreakMode:UILineBreakModeClip
                 alignment:UITextAlignmentCenter];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGRect bubble = CGRectMake(10.0f, 2.0f, rect.size.width - 20.0f, rect.size.height - 18.0f);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 2.0f), 3.0f, [UIColor colorWithWhite:0.0f alpha:0.18f].CGColor);
    PKBubbleFillEllipse(context, bubble, [UIColor colorWithWhite:1.0f alpha:0.94f]);
    CGContextSetShadowWithColor(context, CGSizeZero, 0.0f, NULL);
    PKBubbleFillEllipse(context, CGRectMake(42.0f, rect.size.height - 18.0f, 18.0f, 13.0f), [UIColor colorWithWhite:1.0f alpha:0.94f]);
    PKBubbleFillEllipse(context, CGRectMake(26.0f, rect.size.height - 8.0f, 10.0f, 8.0f), [UIColor colorWithWhite:1.0f alpha:0.94f]);
    [self drawIconInContext:context frame:CGRectMake(24.0f, 18.0f, 58.0f, 52.0f)];
    UIColor *ink = [UIColor colorWithRed:0.16f green:0.27f blue:0.29f alpha:1.0f];
    CGContextSetFillColorWithColor(context, ink.CGColor);
    [ink set];
    [_text drawInRect:CGRectMake(86.0f, 20.0f, rect.size.width - 110.0f, rect.size.height - 39.0f)
              withFont:[UIFont boldSystemFontOfSize:18.0f]
         lineBreakMode:UILineBreakModeTailTruncation
             alignment:UITextAlignmentLeft];
}

- (void)dealloc {
    [_text release];
    [_iconIdentifier release];
    [super dealloc];
}

@end
