#import "VNCView.h"
#import "VNCClient.h"

@implementation VNCView
@synthesize image = _image;
@synthesize client = _client;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor blackColor];
        self.multipleTouchEnabled = YES;
        _zoomScale = 1.0;
        _pinchStartScale = 1.0;
        _scrollAccumulator = 0.0;

        UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)] autorelease];
        longPress.minimumPressDuration = 0.55;
        [self addGestureRecognizer:longPress];

        UIPinchGestureRecognizer *pinch = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)] autorelease];
        pinch.cancelsTouchesInView = YES;
        [self addGestureRecognizer:pinch];

        UIPanGestureRecognizer *scroll = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerScroll:)] autorelease];
        scroll.minimumNumberOfTouches = 2;
        scroll.maximumNumberOfTouches = 2;
        scroll.cancelsTouchesInView = YES;
        [self addGestureRecognizer:scroll];
    }
    return self;
}

- (void)dealloc {
    [_image release];
    [super dealloc];
}

- (void)updateImage:(UIImage *)image {
    self.image = image;
    [self setNeedsDisplay];
}

- (CGRect)imageRect {
    if (!_image) return self.bounds;
    CGSize is = _image.size;
    CGSize bs = self.bounds.size;
    CGFloat fit = MIN(bs.width / is.width, bs.height / is.height);
    CGFloat scale = fit * _zoomScale;
    CGSize ds = CGSizeMake(is.width * scale, is.height * scale);
    return CGRectMake((bs.width-ds.width)/2.0, (bs.height-ds.height)/2.0, ds.width, ds.height);
}

- (void)drawRect:(CGRect)rect {
    (void)rect;
    if (_image) [_image drawInRect:[self imageRect]];
}

- (CGPoint)remotePointForViewPoint:(CGPoint)p {
    CGRect r = [self imageRect];
    if (r.size.width <= 0 || r.size.height <= 0 || !_client) return CGPointZero;
    CGFloat rx = (p.x-r.origin.x)/r.size.width;
    CGFloat ry = (p.y-r.origin.y)/r.size.height;
    rx = MIN(1, MAX(0, rx)); ry = MIN(1, MAX(0, ry));
    return CGPointMake(rx * MAX(1, _client.framebufferWidth-1), ry * MAX(1, _client.framebufferHeight-1));
}

- (CGPoint)remotePointForTouch:(UITouch *)touch {
    return [self remotePointForViewPoint:[touch locationInView:self]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[event allTouches] count] != 1) return;
    UITouch *t = [touches anyObject];
    _lastPoint = [self remotePointForTouch:t];
    [_client sendPointerX:(NSUInteger)_lastPoint.x y:(NSUInteger)_lastPoint.y buttons:1];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[event allTouches] count] != 1) return;
    UITouch *t = [touches anyObject];
    _lastPoint = [self remotePointForTouch:t];
    [_client sendPointerX:(NSUInteger)_lastPoint.x y:(NSUInteger)_lastPoint.y buttons:1];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[event allTouches] count] > 1) return;
    UITouch *t = [touches anyObject];
    _lastPoint = [self remotePointForTouch:t];
    [_client sendPointerX:(NSUInteger)_lastPoint.x y:(NSUInteger)_lastPoint.y buttons:0];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    (void)touches; (void)event;
    [_client sendPointerX:(NSUInteger)_lastPoint.x y:(NSUInteger)_lastPoint.y buttons:0];
}

- (void)longPress:(UILongPressGestureRecognizer *)g {
    CGPoint p = [g locationInView:self];
    CGRect r = [self imageRect];
    if (!_client || !CGRectContainsPoint(r,p)) return;
    CGPoint rp = [self remotePointForViewPoint:p];
    NSUInteger x=(NSUInteger)rp.x, y=(NSUInteger)rp.y;
    if (g.state == UIGestureRecognizerStateBegan) [_client sendPointerX:x y:y buttons:4];
    else if (g.state == UIGestureRecognizerStateEnded || g.state == UIGestureRecognizerStateCancelled) [_client sendPointerX:x y:y buttons:0];
}

- (void)pinch:(UIPinchGestureRecognizer *)g {
    if (g.state == UIGestureRecognizerStateBegan) _pinchStartScale = _zoomScale;
    if (g.state == UIGestureRecognizerStateBegan || g.state == UIGestureRecognizerStateChanged) {
        CGFloat next = _pinchStartScale * g.scale;
        _zoomScale = MIN(2.5, MAX(1.0, next));
        [self setNeedsDisplay];
    }
}

- (void)twoFingerScroll:(UIPanGestureRecognizer *)g {
    if (!_client) return;
    CGPoint p = [g locationInView:self];
    CGPoint rp = [self remotePointForViewPoint:p];
    _lastPoint = rp;

    if (g.state == UIGestureRecognizerStateBegan) {
        _scrollAccumulator = 0.0;
        [g setTranslation:CGPointZero inView:self];
        return;
    }
    if (g.state != UIGestureRecognizerStateChanged) return;

    CGPoint tr = [g translationInView:self];
    _scrollAccumulator += tr.y;
    [g setTranslation:CGPointZero inView:self];

    const CGFloat step = 24.0;
    while (_scrollAccumulator >= step) {
        [_client sendPointerX:(NSUInteger)rp.x y:(NSUInteger)rp.y buttons:16];
        [_client sendPointerX:(NSUInteger)rp.x y:(NSUInteger)rp.y buttons:0];
        _scrollAccumulator -= step;
    }
    while (_scrollAccumulator <= -step) {
        [_client sendPointerX:(NSUInteger)rp.x y:(NSUInteger)rp.y buttons:8];
        [_client sendPointerX:(NSUInteger)rp.x y:(NSUInteger)rp.y buttons:0];
        _scrollAccumulator += step;
    }
}
@end
