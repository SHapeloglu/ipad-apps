#import "PKTownMapView.h"

@implementation PKTownMapView

@synthesize dayPart = _dayPart;
@synthesize season = _season;
@synthesize requestLocation = _requestLocation;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
        _dayPart = [@"Sabah" copy];
        _season = [@"İlkbahar" copy];
        _requestLocation = [@"park" copy];
    }
    return self;
}

- (void)setDayPart:(NSString *)dayPart {
    if (_dayPart != dayPart) { [_dayPart release]; _dayPart = [dayPart copy]; [self setNeedsDisplay]; }
}

- (void)setSeason:(NSString *)season {
    if (_season != season) { [_season release]; _season = [season copy]; [self setNeedsDisplay]; }
}

- (void)setRequestLocation:(NSString *)requestLocation {
    if (_requestLocation != requestLocation) { [_requestLocation release]; _requestLocation = [requestLocation copy]; [self setNeedsDisplay]; }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *ground = [_season isEqualToString:@"Kış"] ? [UIColor colorWithRed:0.84f green:0.91f blue:0.92f alpha:1.0f] : [UIColor colorWithRed:0.67f green:0.84f blue:0.55f alpha:1.0f];
    if ([_season isEqualToString:@"Sonbahar"]) ground = [UIColor colorWithRed:0.81f green:0.72f blue:0.45f alpha:1.0f];
    CGContextSetFillColorWithColor(context, ground.CGColor);
    CGContextFillRect(context, rect);

    /* River and compact walking paths make the four destinations read as a town. */
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.32f green:0.69f blue:0.84f alpha:0.88f].CGColor);
    CGContextSetLineWidth(context, 52.0f);
    CGContextMoveToPoint(context, 0.0f, 250.0f);
    CGContextAddCurveToPoint(context, 260.0f, 205.0f, 500.0f, 310.0f, 760.0f, 250.0f);
    CGContextAddCurveToPoint(context, 870.0f, 222.0f, 930.0f, 205.0f, rect.size.width, 220.0f);
    CGContextStrokePath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.91f green:0.82f blue:0.61f alpha:1.0f].CGColor);
    CGContextSetLineWidth(context, 24.0f);
    CGContextMoveToPoint(context, 190.0f, 420.0f);
    CGContextAddLineToPoint(context, 255.0f, 150.0f);
    CGContextAddLineToPoint(context, 525.0f, 420.0f);
    CGContextAddLineToPoint(context, 790.0f, 155.0f);
    CGContextStrokePath(context);

    UIColor *skyTint = [_dayPart isEqualToString:@"Gece"] ? [UIColor colorWithWhite:0.11f alpha:0.18f] : [UIColor colorWithWhite:1.0f alpha:0.04f];
    CGContextSetFillColorWithColor(context, skyTint.CGColor);
    CGContextFillRect(context, rect);

    CGPoint marker = CGPointMake(952.0f, 82.0f);
    if ([_requestLocation isEqualToString:@"school"]) marker = CGPointMake(350.0f, 105.0f);
    else if ([_requestLocation isEqualToString:@"square"]) marker = CGPointMake(712.0f, 370.0f);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.79f blue:0.16f alpha:1.0f].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(marker.x - 22.0f, marker.y - 22.0f, 44.0f, 44.0f));
    [@"!" drawAtPoint:CGPointMake(marker.x - 6.0f, marker.y - 19.0f) withFont:[UIFont boldSystemFontOfSize:31.0f]];
}

- (void)dealloc {
    [_dayPart release];
    [_season release];
    [_requestLocation release];
    [super dealloc];
}

@end
