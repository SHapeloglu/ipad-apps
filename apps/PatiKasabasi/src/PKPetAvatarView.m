#import "PKPetAvatarView.h"

static void PKFillEllipse(CGContextRef context, CGRect rect, UIColor *color) {
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, rect);
}

static void PKStrokeLine(CGContextRef context, CGPoint a, CGPoint b, UIColor *color, CGFloat width) {
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, width);
    CGContextMoveToPoint(context, a.x, a.y);
    CGContextAddLineToPoint(context, b.x, b.y);
    CGContextStrokePath(context);
}

@implementation PKPetAvatarView

@synthesize speciesIdentifier = _speciesIdentifier;
@synthesize reactionIdentifier = _reactionIdentifier;
@synthesize lifeStageIdentifier = _lifeStageIdentifier;
@synthesize equippedAccessories = _equippedAccessories;
@synthesize happy = _happy;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame speciesIdentifier:@"cat"];
}

- (id)initWithFrame:(CGRect)frame speciesIdentifier:(NSString *)speciesIdentifier {
    self = [super initWithFrame:frame];
    if (self) {
        _speciesIdentifier = [speciesIdentifier copy];
        _reactionIdentifier = [@"" copy];
        _lifeStageIdentifier = [@"baby" copy];
        _equippedAccessories = [[NSDictionary alloc] init];
        _happy = YES;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setEquippedAccessories:(NSDictionary *)equippedAccessories {
    if (_equippedAccessories != equippedAccessories) {
        [_equippedAccessories release];
        _equippedAccessories = [equippedAccessories copy];
        [self setNeedsDisplay];
    }
}

- (void)setReactionIdentifier:(NSString *)reactionIdentifier {
    if (_reactionIdentifier != reactionIdentifier) {
        [_reactionIdentifier release];
        _reactionIdentifier = [reactionIdentifier copy];
        [self setNeedsDisplay];
    }
}

- (void)setLifeStageIdentifier:(NSString *)lifeStageIdentifier {
    if (_lifeStageIdentifier != lifeStageIdentifier) {
        [_lifeStageIdentifier release];
        _lifeStageIdentifier = [lifeStageIdentifier copy];
        [self setNeedsDisplay];
    }
}

- (void)setSpeciesIdentifier:(NSString *)speciesIdentifier {
    if (_speciesIdentifier != speciesIdentifier) {
        [_speciesIdentifier release];
        _speciesIdentifier = [speciesIdentifier copy];
        [self setNeedsDisplay];
    }
}

- (void)setHappy:(BOOL)happy {
    _happy = happy;
    [self setNeedsDisplay];
}

- (void)drawTriangleInContext:(CGContextRef)context
                            a:(CGPoint)a
                            b:(CGPoint)b
                            c:(CGPoint)c
                        color:(UIColor *)color {
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextMoveToPoint(context, a.x, a.y);
    CGContextAddLineToPoint(context, b.x, b.y);
    CGContextAddLineToPoint(context, c.x, c.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);

    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGFloat stageScale = [_lifeStageIdentifier isEqualToString:@"adult"] ? 1.0f : ([_lifeStageIdentifier isEqualToString:@"young"] ? 0.91f : 0.82f);
    CGFloat scale = MIN(w / 220.0f, h / 260.0f) * stageScale;
    CGFloat ox = (w - (220.0f * scale)) * 0.5f;
    CGFloat oy = (h - (260.0f * scale)) * 0.5f;
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, ox, oy);
    CGContextScaleCTM(context, scale, scale);

    UIColor *outline = [UIColor colorWithRed:0.20f green:0.18f blue:0.17f alpha:1.0f];
    UIColor *body = [UIColor colorWithRed:0.91f green:0.66f blue:0.36f alpha:1.0f];
    UIColor *accent = [UIColor colorWithRed:0.78f green:0.45f blue:0.24f alpha:1.0f];
    UIColor *inner = [UIColor colorWithRed:0.98f green:0.71f blue:0.71f alpha:1.0f];

    if ([_speciesIdentifier isEqualToString:@"dog"]) {
        body = [UIColor colorWithRed:0.73f green:0.54f blue:0.34f alpha:1.0f];
        accent = [UIColor colorWithRed:0.42f green:0.29f blue:0.19f alpha:1.0f];
    } else if ([_speciesIdentifier isEqualToString:@"rabbit"]) {
        body = [UIColor colorWithRed:0.93f green:0.91f blue:0.89f alpha:1.0f];
        accent = [UIColor colorWithRed:0.77f green:0.72f blue:0.70f alpha:1.0f];
    } else if ([_speciesIdentifier isEqualToString:@"panda"]) {
        body = [UIColor colorWithWhite:0.97f alpha:1.0f];
        accent = [UIColor colorWithWhite:0.14f alpha:1.0f];
    }

    /* Soft shadow and body. */
    PKFillEllipse(context, CGRectMake(38.0f, 232.0f, 145.0f, 18.0f), [UIColor colorWithWhite:0.0f alpha:0.13f]);
    NSString *bodyAccessory = [_equippedAccessories objectForKey:@"body"];
    if ([bodyAccessory isEqualToString:@"starcape"]) {
        [self drawTriangleInContext:context
                                  a:CGPointMake(40.0f, 143.0f)
                                  b:CGPointMake(180.0f, 143.0f)
                                  c:CGPointMake(110.0f, 245.0f)
                              color:[UIColor colorWithRed:0.38f green:0.35f blue:0.72f alpha:1.0f]];
    }
    PKFillEllipse(context, CGRectMake(49.0f, 129.0f, 122.0f, 112.0f), body);
    PKFillEllipse(context, CGRectMake(76.0f, 165.0f, 68.0f, 67.0f), [UIColor colorWithWhite:1.0f alpha:0.40f]);
    if ([bodyAccessory isEqualToString:@"stripeshirt"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.29f green:0.67f blue:0.75f alpha:0.96f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(55.0f, 157.0f, 110.0f, 77.0f));
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 8.0f);
        PKStrokeLine(context, CGPointMake(65.0f, 178.0f), CGPointMake(155.0f, 178.0f), [UIColor whiteColor], 7.0f);
        PKStrokeLine(context, CGPointMake(61.0f, 202.0f), CGPointMake(159.0f, 202.0f), [UIColor whiteColor], 7.0f);
    } else if ([bodyAccessory isEqualToString:@"starcape"]) {
        [@"★" drawAtPoint:CGPointMake(95.0f, 178.0f) withFont:[UIFont boldSystemFontOfSize:31.0f]];
    }

    if ([_speciesIdentifier isEqualToString:@"rabbit"]) {
        PKFillEllipse(context, CGRectMake(61.0f, 4.0f, 34.0f, 112.0f), body);
        PKFillEllipse(context, CGRectMake(125.0f, 4.0f, 34.0f, 112.0f), body);
        PKFillEllipse(context, CGRectMake(70.0f, 17.0f, 17.0f, 82.0f), inner);
        PKFillEllipse(context, CGRectMake(134.0f, 17.0f, 17.0f, 82.0f), inner);
    } else if ([_speciesIdentifier isEqualToString:@"cat"]) {
        [self drawTriangleInContext:context a:CGPointMake(43.0f, 84.0f) b:CGPointMake(60.0f, 21.0f) c:CGPointMake(99.0f, 72.0f) color:body];
        [self drawTriangleInContext:context a:CGPointMake(121.0f, 71.0f) b:CGPointMake(162.0f, 21.0f) c:CGPointMake(179.0f, 87.0f) color:body];
        [self drawTriangleInContext:context a:CGPointMake(60.0f, 65.0f) b:CGPointMake(65.0f, 38.0f) c:CGPointMake(85.0f, 67.0f) color:inner];
        [self drawTriangleInContext:context a:CGPointMake(135.0f, 67.0f) b:CGPointMake(156.0f, 38.0f) c:CGPointMake(161.0f, 67.0f) color:inner];
    } else if ([_speciesIdentifier isEqualToString:@"dog"]) {
        PKFillEllipse(context, CGRectMake(31.0f, 55.0f, 51.0f, 91.0f), accent);
        PKFillEllipse(context, CGRectMake(138.0f, 55.0f, 51.0f, 91.0f), accent);
    } else {
        PKFillEllipse(context, CGRectMake(37.0f, 39.0f, 59.0f, 59.0f), accent);
        PKFillEllipse(context, CGRectMake(124.0f, 39.0f, 59.0f, 59.0f), accent);
    }

    /* Head. */
    PKFillEllipse(context, CGRectMake(42.0f, 54.0f, 136.0f, 130.0f), body);

    if ([_speciesIdentifier isEqualToString:@"panda"]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 76.0f, 104.0f);
        CGContextRotateCTM(context, -0.24f);
        PKFillEllipse(context, CGRectMake(-18.0f, -25.0f, 38.0f, 54.0f), accent);
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 144.0f, 104.0f);
        CGContextRotateCTM(context, 0.24f);
        PKFillEllipse(context, CGRectMake(-20.0f, -25.0f, 38.0f, 54.0f), accent);
        CGContextRestoreGState(context);
    }

    UIColor *eyeColor = outline;
    PKFillEllipse(context, CGRectMake(72.0f, 99.0f, 15.0f, 22.0f), eyeColor);
    PKFillEllipse(context, CGRectMake(133.0f, 99.0f, 15.0f, 22.0f), eyeColor);
    PKFillEllipse(context, CGRectMake(77.0f, 102.0f, 5.0f, 7.0f), [UIColor whiteColor]);
    PKFillEllipse(context, CGRectMake(138.0f, 102.0f, 5.0f, 7.0f), [UIColor whiteColor]);

    PKFillEllipse(context, CGRectMake(101.0f, 124.0f, 18.0f, 13.0f), accent);
    if (_happy) {
        CGContextSetStrokeColorWithColor(context, outline.CGColor);
        CGContextSetLineWidth(context, 3.0f);
        CGContextAddArc(context, 110.0f, 137.0f, 13.0f, 0.18f, 2.96f, 0);
        CGContextStrokePath(context);
    } else {
        PKStrokeLine(context, CGPointMake(99.0f, 148.0f), CGPointMake(121.0f, 148.0f), outline, 3.0f);
    }

    if ([_speciesIdentifier isEqualToString:@"cat"] || [_speciesIdentifier isEqualToString:@"rabbit"]) {
        PKStrokeLine(context, CGPointMake(93.0f, 137.0f), CGPointMake(46.0f, 129.0f), outline, 2.0f);
        PKStrokeLine(context, CGPointMake(93.0f, 143.0f), CGPointMake(44.0f, 148.0f), outline, 2.0f);
        PKStrokeLine(context, CGPointMake(127.0f, 137.0f), CGPointMake(174.0f, 129.0f), outline, 2.0f);
        PKStrokeLine(context, CGPointMake(127.0f, 143.0f), CGPointMake(176.0f, 148.0f), outline, 2.0f);
    }

    NSString *neckAccessory = [_equippedAccessories objectForKey:@"neck"];
    if ([neckAccessory isEqualToString:@"greencollar"]) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.24f green:0.68f blue:0.43f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, 10.0f);
        CGContextAddArc(context, 110.0f, 162.0f, 48.0f, 0.18f, 2.96f, 0);
        CGContextStrokePath(context);
        PKFillEllipse(context, CGRectMake(104.0f, 166.0f, 13.0f, 13.0f), [UIColor colorWithRed:0.98f green:0.76f blue:0.22f alpha:1.0f]);
    } else if ([neckAccessory isEqualToString:@"pinkscarf"]) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.92f green:0.40f blue:0.64f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, 13.0f);
        CGContextAddArc(context, 110.0f, 160.0f, 49.0f, 0.15f, 3.0f, 0);
        CGContextStrokePath(context);
        [self drawTriangleInContext:context a:CGPointMake(119.0f, 164.0f) b:CGPointMake(148.0f, 180.0f) c:CGPointMake(124.0f, 207.0f) color:[UIColor colorWithRed:0.92f green:0.40f blue:0.64f alpha:1.0f]];
    }

    NSString *faceAccessory = [_equippedAccessories objectForKey:@"face"];
    if ([faceAccessory isEqualToString:@"roundglasses"]) {
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.20f green:0.29f blue:0.35f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, 4.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(61.0f, 89.0f, 38.0f, 42.0f));
        CGContextStrokeEllipseInRect(context, CGRectMake(121.0f, 89.0f, 38.0f, 42.0f));
        PKStrokeLine(context, CGPointMake(99.0f, 108.0f), CGPointMake(121.0f, 108.0f), [UIColor colorWithRed:0.20f green:0.29f blue:0.35f alpha:1.0f], 4.0f);
    } else if ([faceAccessory isEqualToString:@"starglasses"]) {
        [@"★" drawAtPoint:CGPointMake(57.0f, 82.0f) withFont:[UIFont boldSystemFontOfSize:46.0f]];
        [@"★" drawAtPoint:CGPointMake(119.0f, 82.0f) withFont:[UIFont boldSystemFontOfSize:46.0f]];
        PKStrokeLine(context, CGPointMake(98.0f, 108.0f), CGPointMake(122.0f, 108.0f), outline, 4.0f);
    }

    NSString *headAccessory = [_equippedAccessories objectForKey:@"head"];
    if ([headAccessory isEqualToString:@"redbow"]) {
        PKFillEllipse(context, CGRectMake(46.0f, 52.0f, 37.0f, 27.0f), [UIColor colorWithRed:0.91f green:0.25f blue:0.34f alpha:1.0f]);
        PKFillEllipse(context, CGRectMake(77.0f, 52.0f, 37.0f, 27.0f), [UIColor colorWithRed:0.91f green:0.25f blue:0.34f alpha:1.0f]);
        PKFillEllipse(context, CGRectMake(76.0f, 57.0f, 12.0f, 12.0f), [UIColor colorWithRed:0.98f green:0.72f blue:0.24f alpha:1.0f]);
    } else if ([headAccessory isEqualToString:@"bluecap"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.25f green:0.55f blue:0.82f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(53.0f, 42.0f, 114.0f, 57.0f));
        CGContextFillRect(context, CGRectMake(94.0f, 79.0f, 93.0f, 16.0f));
    }

    /* Paws. */
    PKFillEllipse(context, CGRectMake(43.0f, 210.0f, 57.0f, 34.0f), body);
    PKFillEllipse(context, CGRectMake(120.0f, 210.0f, 57.0f, 34.0f), body);

    /* Short-lived action symbols; no sprite sheets or continuous animation. */
    if ([_reactionIdentifier isEqualToString:@"play"]) {
        PKFillEllipse(context, CGRectMake(174.0f, 183.0f, 35.0f, 35.0f), [UIColor colorWithRed:0.94f green:0.30f blue:0.37f alpha:1.0f]);
        PKStrokeLine(context, CGPointMake(178.0f, 200.0f), CGPointMake(205.0f, 200.0f), [UIColor whiteColor], 3.0f);
    } else if ([_reactionIdentifier isEqualToString:@"sleep"]) {
        [@"Zz" drawAtPoint:CGPointMake(160.0f, 30.0f) withFont:[UIFont boldSystemFontOfSize:27.0f]];
    } else if ([_reactionIdentifier isEqualToString:@"clean"]) {
        PKFillEllipse(context, CGRectMake(175.0f, 70.0f, 25.0f, 25.0f), [UIColor colorWithRed:0.52f green:0.85f blue:0.94f alpha:0.75f]);
        PKFillEllipse(context, CGRectMake(187.0f, 105.0f, 17.0f, 17.0f), [UIColor colorWithRed:0.52f green:0.85f blue:0.94f alpha:0.75f]);
    } else if ([_reactionIdentifier isEqualToString:@"cuddle"] || [_reactionIdentifier isEqualToString:@"touch"]) {
        PKFillEllipse(context, CGRectMake(172.0f, 55.0f, 24.0f, 24.0f), [UIColor colorWithRed:0.94f green:0.30f blue:0.42f alpha:1.0f]);
        PKFillEllipse(context, CGRectMake(190.0f, 55.0f, 24.0f, 24.0f), [UIColor colorWithRed:0.94f green:0.30f blue:0.42f alpha:1.0f]);
        [self drawTriangleInContext:context a:CGPointMake(172.0f, 68.0f) b:CGPointMake(214.0f, 68.0f) c:CGPointMake(193.0f, 98.0f) color:[UIColor colorWithRed:0.94f green:0.30f blue:0.42f alpha:1.0f]];
    } else if ([_reactionIdentifier isEqualToString:@"feed"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.35f green:0.66f blue:0.76f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(166.0f, 205.0f, 50.0f, 22.0f));
    }

    CGContextRestoreGState(context);
}

- (void)dealloc {
    [_speciesIdentifier release];
    [_reactionIdentifier release];
    [_lifeStageIdentifier release];
    [_equippedAccessories release];
    [super dealloc];
}

@end
