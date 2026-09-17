#import "VNCView.h"
#import "VNCClient.h"

@implementation VNCView
@synthesize image = _image;
@synthesize client = _client;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor blackColor];
        self.multipleTouchEnabled = NO;
        UILongPressGestureRecognizer *longPress = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)] autorelease];
        longPress.minimumPressDuration = 0.55;
        [self addGestureRecognizer:longPress];
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
    CGFloat scale = MIN(bs.width / is.width, bs.height / is.height);
    CGSize ds = CGSizeMake(is.width * scale, is.height * scale);
    return CGRectMake((bs.width-ds.width)/2.0, (bs.height-ds.height)/2.0, ds.width, ds.height);
}

- (void)drawRect:(CGRect)rect {
    (void)rect;
    if (_image) [_image drawInRect:[self imageRect]];
}

- (CGPoint)remotePointForTouch:(UITouch *)touch {
    CGPoint p = [touch locationInView:self];
    CGRect r = [self imageRect];
    if (r.size.width <= 0 || r.size.height <= 0 || !_client) return CGPointZero;
    CGFloat rx = (p.x-r.origin.x)/r.size.width;
    CGFloat ry = (p.y-r.origin.y)/r.size.height;
    rx = MIN(1, MAX(0, rx)); ry = MIN(1, MAX(0, ry));
    return CGPointMake(rx * MAX(1, _client.framebufferWidth-1), ry * MAX(1, _client.framebufferHeight-1));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    (void)event;
    UITouch *t = [touches anyObject];
    _lastPoint = [self remotePointForTouch:t];
    [_client sendPointerX:(NSUInteger)_lastPoint.x y:(NSUInteger)_lastPoint.y buttons:1];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    (void)event;
    UITouch *t = [touches anyObject];
    _lastPoint = [self remotePointForTouch:t];
    [_client sendPointerX:(NSUInteger)_lastPoint.x y:(NSUInteger)_lastPoint.y buttons:1];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    (void)event;
    UITouch *t = [touches anyObject];
    _lastPoint = [self remotePointForTouch:t];
    [_client sendPointerX:(NSUInteger)_lastPoint.x y:(NSUInteger)_lastPoint.y buttons:0];
}

- (void)longPress:(UILongPressGestureRecognizer *)g {
    CGPoint p = [g locationInView:self];
    CGRect r = [self imageRect];
    if (!_client || !CGRectContainsPoint(r,p)) return;
    NSUInteger x = (NSUInteger)(((p.x-r.origin.x)/r.size.width)*MAX(1,_client.framebufferWidth-1));
    NSUInteger y = (NSUInteger)(((p.y-r.origin.y)/r.size.height)*MAX(1,_client.framebufferHeight-1));
    if (g.state == UIGestureRecognizerStateBegan) [_client sendPointerX:x y:y buttons:4];
    else if (g.state == UIGestureRecognizerStateEnded || g.state == UIGestureRecognizerStateCancelled) [_client sendPointerX:x y:y buttons:0];
}
@end
