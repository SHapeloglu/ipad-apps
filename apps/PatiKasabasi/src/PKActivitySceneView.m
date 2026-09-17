#import "PKActivitySceneView.h"

static void PKSceneFillEllipse(CGContextRef context, CGRect frame, UIColor *color) {
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, frame);
}

static void PKSceneDrawCloud(CGContextRef context, CGFloat x, CGFloat y, CGFloat scale) {
    UIColor *white = [UIColor colorWithWhite:1.0f alpha:0.82f];
    PKSceneFillEllipse(context, CGRectMake(x, y + (16.0f * scale), 72.0f * scale, 30.0f * scale), white);
    PKSceneFillEllipse(context, CGRectMake(x + (18.0f * scale), y, 42.0f * scale, 42.0f * scale), white);
    PKSceneFillEllipse(context, CGRectMake(x + (47.0f * scale), y + (8.0f * scale), 38.0f * scale, 36.0f * scale), white);
}

@implementation PKActivitySceneView

@synthesize sceneIdentifier = _sceneIdentifier;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame sceneIdentifier:@"park"];
}

- (id)initWithFrame:(CGRect)frame sceneIdentifier:(NSString *)sceneIdentifier {
    self = [super initWithFrame:frame];
    if (self) {
        _sceneIdentifier = [sceneIdentifier copy];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setSceneIdentifier:(NSString *)sceneIdentifier {
    if (_sceneIdentifier != sceneIdentifier) {
        [_sceneIdentifier release];
        _sceneIdentifier = [sceneIdentifier copy];
        [self setNeedsDisplay];
    }
}

- (void)drawParkInContext:(CGContextRef)context rect:(CGRect)rect {
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.69f green:0.88f blue:0.96f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, w, h * 0.47f));
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.55f green:0.79f blue:0.43f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, h * 0.47f, w, h * 0.53f));
    PKSceneFillEllipse(context, CGRectMake(w - 118.0f, 32.0f, 72.0f, 72.0f), [UIColor colorWithRed:1.0f green:0.83f blue:0.27f alpha:1.0f]);
    PKSceneDrawCloud(context, 86.0f, 42.0f, 1.0f);
    PKSceneDrawCloud(context, 720.0f, 80.0f, 0.78f);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.43f green:0.70f blue:0.36f alpha:1.0f].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(-100.0f, h * 0.35f, 530.0f, 250.0f));
    CGContextFillEllipseInRect(context, CGRectMake(590.0f, h * 0.34f, 560.0f, 260.0f));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.87f green:0.73f blue:0.50f alpha:0.92f].CGColor);
    CGContextMoveToPoint(context, w * 0.44f, h);
    CGContextAddQuadCurveToPoint(context, w * 0.50f, h * 0.66f, w * 0.47f, h * 0.45f);
    CGContextAddLineToPoint(context, w * 0.56f, h * 0.45f);
    CGContextAddQuadCurveToPoint(context, w * 0.59f, h * 0.68f, w * 0.66f, h);
    CGContextClosePath(context);
    CGContextFillPath(context);

    PKSceneFillEllipse(context, CGRectMake(370.0f, h - 150.0f, 285.0f, 92.0f), [UIColor colorWithRed:0.36f green:0.73f blue:0.86f alpha:0.82f]);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.60f].CGColor);
    CGContextSetLineWidth(context, 4.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake(382.0f, h - 140.0f, 260.0f, 70.0f));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.48f green:0.29f blue:0.17f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(72.0f, h * 0.41f, 28.0f, 162.0f));
    PKSceneFillEllipse(context, CGRectMake(18.0f, h * 0.31f, 140.0f, 135.0f), [UIColor colorWithRed:0.25f green:0.63f blue:0.30f alpha:1.0f]);
    CGContextFillRect(context, CGRectMake(w - 98.0f, h * 0.42f, 25.0f, 152.0f));
    PKSceneFillEllipse(context, CGRectMake(w - 157.0f, h * 0.32f, 142.0f, 132.0f), [UIColor colorWithRed:0.25f green:0.63f blue:0.30f alpha:1.0f]);

    NSArray *flowerColors = [NSArray arrayWithObjects:
        [UIColor colorWithRed:0.96f green:0.40f blue:0.48f alpha:1.0f],
        [UIColor colorWithRed:0.99f green:0.78f blue:0.20f alpha:1.0f],
        [UIColor colorWithRed:0.64f green:0.42f blue:0.79f alpha:1.0f], nil];
    NSUInteger index = 0;
    for (index = 0; index < 12; index++) {
        CGFloat x = 35.0f + ((CGFloat)index * 83.0f);
        UIColor *color = [flowerColors objectAtIndex:(index % [flowerColors count])];
        PKSceneFillEllipse(context, CGRectMake(x, h - 46.0f - ((index % 2) * 12.0f), 12.0f, 12.0f), color);
    }
}

- (void)drawSchoolInContext:(CGContextRef)context rect:(CGRect)rect {
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.93f green:0.88f blue:0.70f alpha:1.0f].CGColor);
    CGContextFillRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.69f green:0.50f blue:0.31f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, h * 0.72f, w, h * 0.28f));

    CGRect board = CGRectMake(292.0f, 72.0f, 440.0f, 180.0f);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.17f green:0.42f blue:0.34f alpha:1.0f].CGColor);
    CGContextFillRect(context, board);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.55f green:0.33f blue:0.18f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, 14.0f);
    CGContextStrokeRect(context, board);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.78f].CGColor);
    CGContextSetLineWidth(context, 4.0f);
    CGContextMoveToPoint(context, 350.0f, 165.0f);
    CGContextAddLineToPoint(context, 385.0f, 132.0f);
    CGContextAddLineToPoint(context, 420.0f, 165.0f);
    CGContextStrokePath(context);
    CGContextStrokeEllipseInRect(context, CGRectMake(480.0f, 120.0f, 55.0f, 55.0f));
    CGContextMoveToPoint(context, 610.0f, 128.0f);
    CGContextAddLineToPoint(context, 665.0f, 170.0f);
    CGContextMoveToPoint(context, 665.0f, 128.0f);
    CGContextAddLineToPoint(context, 610.0f, 170.0f);
    CGContextStrokePath(context);

    CGRect windowFrame = CGRectMake(60.0f, 75.0f, 170.0f, 170.0f);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.60f green:0.84f blue:0.95f alpha:1.0f].CGColor);
    CGContextFillRect(context, windowFrame);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 10.0f);
    CGContextStrokeRect(context, windowFrame);
    CGContextMoveToPoint(context, CGRectGetMidX(windowFrame), CGRectGetMinY(windowFrame));
    CGContextAddLineToPoint(context, CGRectGetMidX(windowFrame), CGRectGetMaxY(windowFrame));
    CGContextMoveToPoint(context, CGRectGetMinX(windowFrame), CGRectGetMidY(windowFrame));
    CGContextAddLineToPoint(context, CGRectGetMaxX(windowFrame), CGRectGetMidY(windowFrame));
    CGContextStrokePath(context);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.52f green:0.32f blue:0.18f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(w - 205.0f, 68.0f, 145.0f, 250.0f));
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.90f green:0.69f blue:0.33f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, 8.0f);
    CGFloat shelfY = 110.0f;
    while (shelfY < 300.0f) {
        CGContextMoveToPoint(context, w - 190.0f, shelfY);
        CGContextAddLineToPoint(context, w - 75.0f, shelfY);
        shelfY += 48.0f;
    }
    CGContextStrokePath(context);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.91f green:0.58f blue:0.34f alpha:0.95f].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(365.0f, h * 0.62f, 295.0f, 84.0f));
}

- (void)drawSquareInContext:(CGContextRef)context rect:(CGRect)rect {
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.70f green:0.87f blue:0.96f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, w, h * 0.43f));
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.85f green:0.76f blue:0.61f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, h * 0.43f, w, h * 0.57f));
    PKSceneDrawCloud(context, 92.0f, 48.0f, 0.9f);
    PKSceneDrawCloud(context, 760.0f, 55.0f, 0.72f);

    NSArray *buildingColors = [NSArray arrayWithObjects:
        [UIColor colorWithRed:0.92f green:0.56f blue:0.48f alpha:1.0f],
        [UIColor colorWithRed:0.48f green:0.69f blue:0.86f alpha:1.0f],
        [UIColor colorWithRed:0.78f green:0.60f blue:0.84f alpha:1.0f], nil];
    NSUInteger index = 0;
    for (index = 0; index < 6; index++) {
        CGFloat x = (CGFloat)index * 174.0f;
        CGFloat buildingHeight = 125.0f + ((index % 3) * 22.0f);
        UIColor *color = [buildingColors objectAtIndex:(index % [buildingColors count])];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, CGRectMake(x, (h * 0.43f) - buildingHeight, 158.0f, buildingHeight));
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.86f blue:0.37f alpha:0.82f].CGColor);
        CGContextFillRect(context, CGRectMake(x + 24.0f, (h * 0.43f) - buildingHeight + 35.0f, 33.0f, 38.0f));
        CGContextFillRect(context, CGRectMake(x + 92.0f, (h * 0.43f) - buildingHeight + 35.0f, 33.0f, 38.0f));
    }

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.48f green:0.34f blue:0.28f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, 4.0f);
    CGContextMoveToPoint(context, 0.0f, 90.0f);
    CGContextAddLineToPoint(context, w, 120.0f);
    CGContextStrokePath(context);
    NSArray *flagColors = [NSArray arrayWithObjects:
        [UIColor colorWithRed:0.96f green:0.38f blue:0.42f alpha:1.0f],
        [UIColor colorWithRed:0.98f green:0.76f blue:0.20f alpha:1.0f],
        [UIColor colorWithRed:0.36f green:0.66f blue:0.82f alpha:1.0f], nil];
    for (index = 0; index < 13; index++) {
        CGFloat x = 25.0f + ((CGFloat)index * 80.0f);
        CGFloat y = 92.0f + ((x / w) * 30.0f);
        UIColor *color = [flagColors objectAtIndex:(index % [flagColors count])];
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x + 30.0f, y + 4.0f);
        CGContextAddLineToPoint(context, x + 14.0f, y + 35.0f);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.52f green:0.32f blue:0.22f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(332.0f, h * 0.52f, 360.0f, 128.0f));
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.96f green:0.45f blue:0.38f alpha:1.0f].CGColor);
    CGContextMoveToPoint(context, 312.0f, h * 0.52f);
    CGContextAddLineToPoint(context, 712.0f, h * 0.52f);
    CGContextAddLineToPoint(context, 658.0f, h * 0.43f);
    CGContextAddLineToPoint(context, 366.0f, h * 0.43f);
    CGContextClosePath(context);
    CGContextFillPath(context);

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.32f].CGColor);
    CGContextSetLineWidth(context, 2.0f);
    CGFloat lineY = h * 0.46f;
    while (lineY < h) {
        CGContextMoveToPoint(context, 0.0f, lineY);
        CGContextAddLineToPoint(context, w, lineY);
        lineY += 38.0f;
    }
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    if ([_sceneIdentifier isEqualToString:@"school"]) [self drawSchoolInContext:context rect:rect];
    else if ([_sceneIdentifier isEqualToString:@"square"]) [self drawSquareInContext:context rect:rect];
    else [self drawParkInContext:context rect:rect];
}

- (void)dealloc {
    [_sceneIdentifier release];
    [super dealloc];
}

@end
