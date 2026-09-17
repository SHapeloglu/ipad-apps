#import "PKRoomBackgroundView.h"

@interface PKRoomBackgroundView ()
- (CGRect)itemFrameForIdentifier:(NSString *)identifier;
@end

@implementation PKRoomBackgroundView

@synthesize placedItems = _placedItems;
@synthesize dayPart = _dayPart;
@synthesize season = _season;
@synthesize highlightedItemIdentifier = _highlightedItemIdentifier;

- (CGRect)itemFrameForIdentifier:(NSString *)identifier {
    CGFloat floorY = self.bounds.size.height * 0.68f;
    if ([identifier isEqualToString:@"rug"]) return CGRectMake(215.0f, floorY + 15.0f, 395.0f, 160.0f);
    if ([identifier isEqualToString:@"bed"]) return CGRectMake(32.0f, floorY + 20.0f, 200.0f, 130.0f);
    if ([identifier isEqualToString:@"bowl"]) return CGRectMake(590.0f, floorY + 75.0f, 112.0f, 70.0f);
    if ([identifier isEqualToString:@"ball"]) return CGRectMake(684.0f, floorY + 62.0f, 86.0f, 86.0f);
    if ([identifier isEqualToString:@"plant"]) return CGRectMake(880.0f, floorY - 75.0f, 105.0f, 160.0f);
    if ([identifier isEqualToString:@"bookshelf"]) return CGRectMake(800.0f, 170.0f, 165.0f, 285.0f);
    if ([identifier isEqualToString:@"piano"]) return CGRectMake(42.0f, 310.0f, 210.0f, 140.0f);
    if ([identifier isEqualToString:@"arttable"]) return CGRectMake(590.0f, 306.0f, 200.0f, 139.0f);
    return CGRectZero;
}

- (NSString *)itemIdentifierAtPoint:(CGPoint)point {
    NSArray *hitOrder = [NSArray arrayWithObjects:@"arttable", @"piano", @"bookshelf", @"plant", @"ball", @"bowl", @"bed", @"rug", nil];
    NSUInteger index = 0;
    for (index = 0; index < [hitOrder count]; index++) {
        NSString *identifier = [hitOrder objectAtIndex:index];
        if ([_placedItems containsObject:identifier] && CGRectContainsPoint([self itemFrameForIdentifier:identifier], point)) return identifier;
    }
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        _placedItems = [[NSArray alloc] init];
        _dayPart = [@"Sabah" copy];
        _season = [@"İlkbahar" copy];
    }
    return self;
}

- (void)setPlacedItems:(NSArray *)placedItems {
    if (_placedItems != placedItems) {
        [_placedItems release];
        _placedItems = [placedItems copy];
        [self setNeedsDisplay];
    }
}

- (void)setDayPart:(NSString *)dayPart {
    if (_dayPart != dayPart) {
        [_dayPart release];
        _dayPart = [dayPart copy];
        [self setNeedsDisplay];
    }
}

- (void)setSeason:(NSString *)season {
    if (_season != season) {
        [_season release];
        _season = [season copy];
        [self setNeedsDisplay];
    }
}

- (void)setHighlightedItemIdentifier:(NSString *)highlightedItemIdentifier {
    if (_highlightedItemIdentifier != highlightedItemIdentifier) {
        [_highlightedItemIdentifier release];
        _highlightedItemIdentifier = [highlightedItemIdentifier copy];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat floorY = rect.size.height * 0.68f;

    UIColor *wall = [_season isEqualToString:@"Kış"] ? [UIColor colorWithRed:0.88f green:0.93f blue:0.96f alpha:1.0f] : [UIColor colorWithRed:0.88f green:0.94f blue:0.88f alpha:1.0f];
    CGContextSetFillColorWithColor(context, wall.CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, rect.size.width, floorY));
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.74f green:0.57f blue:0.38f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, floorY, rect.size.width, rect.size.height - floorY));

    /* Floor planks. */
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.62f green:0.43f blue:0.28f alpha:0.45f].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGFloat y = floorY + 28.0f;
    while (y < rect.size.height) {
        CGContextMoveToPoint(context, 0.0f, y);
        CGContextAddLineToPoint(context, rect.size.width, y);
        y += 36.0f;
    }
    CGContextStrokePath(context);

    /* Window. */
    CGRect windowFrame = CGRectMake(68.0f, 58.0f, 210.0f, 145.0f);
    UIColor *sky = [UIColor colorWithRed:0.61f green:0.84f blue:0.94f alpha:1.0f];
    if ([_dayPart isEqualToString:@"Akşam"]) sky = [UIColor colorWithRed:0.94f green:0.55f blue:0.42f alpha:1.0f];
    if ([_dayPart isEqualToString:@"Gece"]) sky = [UIColor colorWithRed:0.16f green:0.24f blue:0.46f alpha:1.0f];
    CGContextSetFillColorWithColor(context, sky.CGColor);
    CGContextFillRect(context, windowFrame);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 12.0f);
    CGContextStrokeRect(context, windowFrame);
    CGContextMoveToPoint(context, CGRectGetMidX(windowFrame), CGRectGetMinY(windowFrame));
    CGContextAddLineToPoint(context, CGRectGetMidX(windowFrame), CGRectGetMaxY(windowFrame));
    CGContextMoveToPoint(context, CGRectGetMinX(windowFrame), CGRectGetMidY(windowFrame));
    CGContextAddLineToPoint(context, CGRectGetMaxX(windowFrame), CGRectGetMidY(windowFrame));
    CGContextStrokePath(context);

    /* A small seasonal view outside the window. */
    UIColor *outside = [_season isEqualToString:@"Sonbahar"] ? [UIColor colorWithRed:0.83f green:0.49f blue:0.20f alpha:1.0f] : [UIColor colorWithRed:0.35f green:0.68f blue:0.34f alpha:1.0f];
    if ([_season isEqualToString:@"Kış"]) outside = [UIColor colorWithWhite:0.96f alpha:1.0f];
    CGContextSetFillColorWithColor(context, outside.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(80.0f, 145.0f, 180.0f, 50.0f));

    if ([_highlightedItemIdentifier length] > 0) {
        CGRect targetFrame = CGRectInset([self itemFrameForIdentifier:_highlightedItemIdentifier], -7.0f, -7.0f);
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.87f blue:0.24f alpha:0.30f].CGColor);
        CGContextFillEllipseInRect(context, targetFrame);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1.0f green:0.80f blue:0.12f alpha:0.95f].CGColor);
        CGContextSetLineWidth(context, 6.0f);
        CGContextStrokeEllipseInRect(context, targetFrame);
    }

    if ([_placedItems containsObject:@"rug"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.94f green:0.60f blue:0.48f alpha:0.82f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(235.0f, floorY + 35.0f, 355.0f, 120.0f));
    }
    if ([_placedItems containsObject:@"bed"]) {
        UIColor *bedOuter = [UIColor colorWithRed:0.28f green:0.60f blue:0.70f alpha:1.0f];
        UIColor *bedRim = [UIColor colorWithRed:0.14f green:0.39f blue:0.50f alpha:1.0f];
        UIColor *bedCushion = [UIColor colorWithRed:0.98f green:0.83f blue:0.75f alpha:1.0f];
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.15f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(34.0f, floorY + 105.0f, 204.0f, 28.0f));
        CGContextSetFillColorWithColor(context, bedRim.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(38.0f, floorY + 25.0f, 192.0f, 102.0f));
        CGContextSetFillColorWithColor(context, bedCushion.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(53.0f, floorY + 38.0f, 162.0f, 73.0f));

        CGContextSetFillColorWithColor(context, bedOuter.CGColor);
        CGContextMoveToPoint(context, 40.0f, floorY + 71.0f);
        CGContextAddQuadCurveToPoint(context, 45.0f, floorY + 121.0f, 68.0f, floorY + 127.0f);
        CGContextAddQuadCurveToPoint(context, 134.0f, floorY + 144.0f, 204.0f, floorY + 127.0f);
        CGContextAddQuadCurveToPoint(context, 226.0f, floorY + 121.0f, 230.0f, floorY + 71.0f);
        CGContextAddQuadCurveToPoint(context, 135.0f, floorY + 105.0f, 40.0f, floorY + 71.0f);
        CGContextClosePath(context);
        CGContextFillPath(context);

        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.90f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(127.0f, floorY + 112.0f, 17.0f, 14.0f));
        CGContextFillEllipseInRect(context, CGRectMake(115.0f, floorY + 106.0f, 9.0f, 10.0f));
        CGContextFillEllipseInRect(context, CGRectMake(127.0f, floorY + 101.0f, 9.0f, 10.0f));
        CGContextFillEllipseInRect(context, CGRectMake(140.0f, floorY + 106.0f, 9.0f, 10.0f));
    }
    if ([_placedItems containsObject:@"bowl"]) {
        UIColor *bowlBlue = [UIColor colorWithRed:0.27f green:0.58f blue:0.72f alpha:1.0f];
        UIColor *bowlRim = [UIColor colorWithRed:0.13f green:0.38f blue:0.52f alpha:1.0f];
        UIColor *food = [UIColor colorWithRed:0.79f green:0.61f blue:0.37f alpha:1.0f];
        UIColor *kibble = [UIColor colorWithRed:0.43f green:0.27f blue:0.16f alpha:1.0f];

        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.16f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(598.0f, floorY + 132.0f, 98.0f, 15.0f));

        CGContextSetFillColorWithColor(context, bowlBlue.CGColor);
        CGContextMoveToPoint(context, 601.0f, floorY + 98.0f);
        CGContextAddLineToPoint(context, 693.0f, floorY + 98.0f);
        CGContextAddQuadCurveToPoint(context, 688.0f, floorY + 137.0f, 676.0f, floorY + 140.0f);
        CGContextAddLineToPoint(context, 618.0f, floorY + 140.0f);
        CGContextAddQuadCurveToPoint(context, 606.0f, floorY + 137.0f, 601.0f, floorY + 98.0f);
        CGContextClosePath(context);
        CGContextFillPath(context);

        CGContextSetFillColorWithColor(context, bowlRim.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(598.0f, floorY + 84.0f, 98.0f, 31.0f));
        CGContextSetFillColorWithColor(context, food.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(605.0f, floorY + 89.0f, 84.0f, 21.0f));
        CGContextSetFillColorWithColor(context, kibble.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(617.0f, floorY + 91.0f, 13.0f, 10.0f));
        CGContextFillEllipseInRect(context, CGRectMake(638.0f, floorY + 96.0f, 14.0f, 10.0f));
        CGContextFillEllipseInRect(context, CGRectMake(660.0f, floorY + 91.0f, 13.0f, 10.0f));

        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.88f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(640.0f, floorY + 116.0f, 15.0f, 13.0f));
        CGContextFillEllipseInRect(context, CGRectMake(630.0f, floorY + 111.0f, 8.0f, 9.0f));
        CGContextFillEllipseInRect(context, CGRectMake(641.0f, floorY + 107.0f, 8.0f, 9.0f));
        CGContextFillEllipseInRect(context, CGRectMake(652.0f, floorY + 111.0f, 8.0f, 9.0f));
    }
    if ([_placedItems containsObject:@"ball"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.94f green:0.30f blue:0.37f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(704.0f, floorY + 82.0f, 46.0f, 46.0f));
    }
    if ([_placedItems containsObject:@"plant"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.35f green:0.68f blue:0.34f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(900.0f, floorY - 55.0f, 65.0f, 105.0f));
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.67f green:0.38f blue:0.22f alpha:1.0f].CGColor);
        CGContextFillRect(context, CGRectMake(910.0f, floorY + 18.0f, 48.0f, 52.0f));
    }
    if ([_placedItems containsObject:@"bookshelf"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.55f green:0.34f blue:0.20f alpha:1.0f].CGColor);
        CGContextFillRect(context, CGRectMake(820.0f, 190.0f, 125.0f, 245.0f));
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.90f green:0.72f blue:0.38f alpha:1.0f].CGColor);
        CGContextSetLineWidth(context, 12.0f);
        CGFloat shelfY = 225.0f;
        while (shelfY < 420.0f) { CGContextMoveToPoint(context, 835.0f, shelfY); CGContextAddLineToPoint(context, 930.0f, shelfY); shelfY += 42.0f; }
        CGContextStrokePath(context);
    }
    if ([_placedItems containsObject:@"piano"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.24f green:0.30f blue:0.34f alpha:1.0f].CGColor);
        CGContextFillRect(context, CGRectMake(62.0f, 330.0f, 170.0f, 100.0f));
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillRect(context, CGRectMake(78.0f, 375.0f, 140.0f, 32.0f));
    }
    if ([_placedItems containsObject:@"arttable"]) {
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.89f green:0.61f blue:0.35f alpha:1.0f].CGColor);
        CGContextFillRect(context, CGRectMake(610.0f, 350.0f, 160.0f, 75.0f));
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.76f green:0.34f blue:0.54f alpha:1.0f].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(655.0f, 326.0f, 42.0f, 42.0f));
    }
}

- (void)dealloc {
    [_placedItems release];
    [_dayPart release];
    [_season release];
    [_highlightedItemIdentifier release];
    [super dealloc];
}

@end
