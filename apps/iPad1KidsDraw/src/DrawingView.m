#import "DrawingView.h"

@implementation DrawingView

@synthesize strokeColor = _strokeColor;
@synthesize lineWidth = _lineWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.multipleTouchEnabled = NO;
        self.opaque = YES;
        self.strokeColor = [UIColor blackColor];
        self.lineWidth = 6.0f;
        _drawing = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [_image drawInRect:self.bounds];
}

- (void)ensureImage
{
    if (_image != nil) return;

    UIGraphicsBeginImageContext(self.bounds.size);
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_image release];
    _image = [newImage retain];
}

- (void)drawLineFrom:(CGPoint)fromPoint to:(CGPoint)toPoint
{
    [self ensureImage];

    UIGraphicsBeginImageContext(self.bounds.size);
    [_image drawInRect:self.bounds];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(ctx, toPoint.x, toPoint.y);
    CGContextStrokePath(ctx);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_image release];
    _image = [newImage retain];

    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _lastPoint = [touch locationInView:self];
    _drawing = YES;

    // Draw a tiny dot on tap.
    [self drawLineFrom:_lastPoint to:_lastPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_drawing) return;

    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    [self drawLineFrom:_lastPoint to:currentPoint];
    _lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _drawing = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _drawing = NO;
}

- (void)clearCanvas
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [[UIColor whiteColor] setFill];
    UIRectFill(self.bounds);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [_image release];
    _image = [newImage retain];
    [self setNeedsDisplay];
}

- (UIImage *)renderedImage
{
    [self ensureImage];
    return _image;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Keep implementation lightweight. We intentionally do not rescale the
    // existing bitmap during rotation to avoid repeated large allocations.
}

- (void)dealloc
{
    [_image release];
    [_strokeColor release];
    [super dealloc];
}

@end
