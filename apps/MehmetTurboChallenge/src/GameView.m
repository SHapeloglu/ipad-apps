#import "GameView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <math.h>

static inline float MTClamp(float v, float lo, float hi)
{
    if (v < lo) return lo;
    if (v > hi) return hi;
    return v;
}

static inline CGFloat MTLerp(CGFloat a, CGFloat b, CGFloat t)
{
    return a + (b - a) * t;
}

static void MTFillRoundedRect(CGContextRef ctx, CGRect r, CGFloat radius)
{
    CGFloat maxR = MIN(r.size.width, r.size.height) * 0.5f;
    radius = MIN(radius, maxR);

    CGPathRef p = CGPathCreateMutable();
    CGMutablePathRef path = (CGMutablePathRef)p;

    CGPathMoveToPoint(path, NULL, CGRectGetMidX(r), CGRectGetMinY(r));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(r), CGRectGetMinY(r),
                        CGRectGetMaxX(r), CGRectGetMaxY(r), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(r), CGRectGetMaxY(r),
                        CGRectGetMinX(r), CGRectGetMaxY(r), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(r), CGRectGetMaxY(r),
                        CGRectGetMinX(r), CGRectGetMinY(r), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(r), CGRectGetMinY(r),
                        CGRectGetMaxX(r), CGRectGetMinY(r), radius);
    CGPathCloseSubpath(path);

    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
}

@interface GameView ()
@end

@implementation GameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.multipleTouchEnabled = NO;

        _playerX = 0.0f;
        _steer = 0.0f;
        _steerTarget = 0.0f;
        _roadScroll = 0.0f;
        _distance = 0.0f;
        _raceTime = 0.0f;
        _lap = 1;
        _score = 0;
        _lastTime = 0.0;
        _paused = NO;

        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        _displayLink.frameInterval = 2;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)dealloc
{
    [_displayLink invalidate];
    [_displayLink release];
    [super dealloc];
}

- (void)pauseGame
{
    _paused = YES;
    [_displayLink setPaused:YES];
}

- (void)resumeGame
{
    _lastTime = 0.0;
    _paused = NO;
    [_displayLink setPaused:NO];
}

- (void)tick:(CADisplayLink *)link
{
    if (_paused) return;

    CFTimeInterval now = link.timestamp;
    if (_lastTime == 0.0) {
        _lastTime = now;
        return;
    }

    float dt = (float)(now - _lastTime);
    _lastTime = now;
    dt = MTClamp(dt, 0.001f, 0.05f);

    _steer += (_steerTarget - _steer) * MTClamp(dt * 9.0f, 0.0f, 1.0f);

    float speed = 0.82f + fabsf(_steer) * 0.08f;
    _roadScroll += dt * speed;
    _distance += dt * 175.0f;
    _raceTime += dt;

    if (_distance > 10000.0f) {
        _distance -= 10000.0f;
        _lap++;
        if (_lap > 3) _lap = 1;
    }

    _score += (int)(dt * (90.0f + speed * 20.0f));

    /* Steering moves the car, but recenters naturally when released. */
    _playerX += _steer * dt * 0.75f;
    _playerX = MTClamp(_playerX, -0.58f, 0.58f);

    [self setNeedsDisplay];
}

#pragma mark - Input

- (void)updateTouchAtPoint:(CGPoint)p
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;

    if (h <= 0.0f || w <= 0.0f) return;

    if (p.x < w * 0.42f) {
        _touchLeft = YES;
        _touchRight = NO;
        _steerTarget = -1.0f;
    } else if (p.x > w * 0.58f) {
        _touchLeft = NO;
        _touchRight = YES;
        _steerTarget = 1.0f;
    } else {
        _touchLeft = NO;
        _touchRight = NO;
        _steerTarget = 0.0f;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    (void)event;
    UITouch *touch = [touches anyObject];
    [self updateTouchAtPoint:[touch locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    (void)event;
    UITouch *touch = [touches anyObject];
    [self updateTouchAtPoint:[touch locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    (void)touches;
    (void)event;
    _touchLeft = NO;
    _touchRight = NO;
    _steerTarget = 0.0f;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    (void)touches;
    (void)event;
    _touchLeft = NO;
    _touchRight = NO;
    _steerTarget = 0.0f;
}

#pragma mark - World

- (CGFloat)roadCenterAtY:(CGFloat)y width:(CGFloat)w height:(CGFloat)h
{
    CGFloat horizon = h * 0.335f;
    CGFloat near = (y - horizon) / (h - horizon);
    near = MTClamp(near, 0.0f, 1.0f);

    /*
     * A repeating 90s arcade road: long bend, counter-bend, then a
     * shorter S section. The function is cheap enough for iPad 1.
     */
    CGFloat z = (1.0f - near) * 8.0f + _roadScroll * 1.15f;
    CGFloat curve = sinf(z * 0.72f) * 0.13f
                  + sinf(z * 0.31f + 1.7f) * 0.10f;

    return w * 0.5f + curve * w * near;
}

- (CGFloat)roadHalfWidthAtY:(CGFloat)y width:(CGFloat)w height:(CGFloat)h
{
    CGFloat horizon = h * 0.335f;
    CGFloat t = (y - horizon) / (h - horizon);
    t = MTClamp(t, 0.0f, 1.0f);

    return MTLerp(w * 0.055f, w * 0.46f, powf(t, 0.82f));
}

- (void)drawSkyAndMountains:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h
{
    CGFloat horizon = h * 0.335f;

    /* Sky bands: intentionally flat/pixel-like for a 90s arcade feel. */
    int bands = 18;
    CGFloat bh = horizon / bands;

    for (int i = 0; i < bands; i++) {
        CGFloat t = (CGFloat)i / (CGFloat)(bands - 1);
        CGFloat r = 0.10f + 0.32f * t;
        CGFloat g = 0.22f + 0.30f * t;
        CGFloat b = 0.55f + 0.33f * t;

        CGContextSetRGBFillColor(ctx, r, g, b, 1.0f);
        CGContextFillRect(ctx, CGRectMake(0, i * bh, w, bh + 1));
    }

    /* Sun glow. */
    CGContextSetRGBFillColor(ctx, 1.0, 0.88, 0.34, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(w * 0.73f, h * 0.08f,
                                               w * 0.12f, w * 0.12f));

    /* Distant mountains. */
    CGMutablePathRef p = CGPathCreateMutable();
    CGPathMoveToPoint(p, NULL, 0, horizon);

    int peaks = 11;
    for (int i = 0; i <= peaks; i++) {
        CGFloat x = (w / peaks) * i;
        CGFloat peak = horizon - h * (0.10f + 0.08f * fabsf(sinf((float)i * 1.71f)));
        if (i == 2 || i == 7) peak -= h * 0.07f;
        CGPathAddLineToPoint(p, NULL, x, peak);
    }

    CGPathAddLineToPoint(p, NULL, w, horizon);
    CGPathCloseSubpath(p);

    CGContextSetRGBFillColor(ctx, 0.15, 0.20, 0.17, 1.0);
    CGContextAddPath(ctx, p);
    CGContextFillPath(ctx);
    CGPathRelease(p);

    /* Mountain highlight ridges. */
    CGContextSetLineWidth(ctx, 2.0f);
    CGContextSetRGBStrokeColor(ctx, 0.27, 0.25, 0.20, 1.0);

    for (int i = 0; i < peaks; i += 2) {
        CGFloat x = (w / peaks) * i;
        CGFloat y = horizon - h * (0.10f + 0.08f * fabsf(sinf((float)i * 1.71f)));
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint(ctx, x + w * 0.035f, y + h * 0.045f);
        CGContextStrokePath(ctx);
    }

    /* Green field. */
    CGContextSetRGBFillColor(ctx, 0.08, 0.25, 0.10, 1.0);
    CGContextFillRect(ctx, CGRectMake(0, horizon, w, h - horizon));

    /* Field stripes create motion without textures. */
    CGContextSetRGBFillColor(ctx, 0.10, 0.29, 0.11, 1.0);
    CGFloat stripeH = 20.0f;
    for (CGFloat y = horizon; y < h; y += stripeH) {
        if (((int)((y - horizon) / stripeH)) & 1)
            CGContextFillRect(ctx, CGRectMake(0, y, w, stripeH * 0.5f));
    }
}

- (void)drawRoad:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h
{
    CGFloat horizon = h * 0.335f;
    CGFloat bottom = h;

    /* Road polygon using several slices so curves are visible. */
    int slices = 30;

    for (int i = 0; i < slices; i++) {
        CGFloat t0 = (CGFloat)i / slices;
        CGFloat t1 = (CGFloat)(i + 1) / slices;

        CGFloat y0 = horizon + (bottom - horizon) * t0;
        CGFloat y1 = horizon + (bottom - horizon) * t1;

        CGFloat c0 = [self roadCenterAtY:y0 width:w height:h];
        CGFloat c1 = [self roadCenterAtY:y1 width:w height:h];

        CGFloat hw0 = [self roadHalfWidthAtY:y0 width:w height:h];
        CGFloat hw1 = [self roadHalfWidthAtY:y1 width:w height:h];

        CGContextSetRGBFillColor(ctx, 0.075, 0.085, 0.09, 1.0);
        CGContextMoveToPoint(ctx, c0 - hw0, y0);
        CGContextAddLineToPoint(ctx, c0 + hw0, y0);
        CGContextAddLineToPoint(ctx, c1 + hw1, y1);
        CGContextAddLineToPoint(ctx, c1 - hw1, y1);
        CGContextClosePath(ctx);
        CGContextFillPath(ctx);

        /* Road center texture strips. */
        if (i & 1) {
            CGContextSetRGBFillColor(ctx, 0.085, 0.095, 0.10, 1.0);
            CGContextFillRect(ctx, CGRectMake(c1 - hw1, y1, hw1 * 2.0f, 1.0f));
        }

        /* Red/white curbs. */
        CGFloat curb = MAX(2.0f, hw1 * 0.045f);
        BOOL red = (((int)(_roadScroll * 8.0f) + i) & 1) == 0;

        if (red) CGContextSetRGBFillColor(ctx, 0.86, 0.03, 0.04, 1.0);
        else     CGContextSetRGBFillColor(ctx, 0.92, 0.92, 0.88, 1.0);

        CGContextFillRect(ctx, CGRectMake(c1 - hw1 - curb, y1, curb, MAX(2.0f, y1-y0)));
        CGContextFillRect(ctx, CGRectMake(c1 + hw1, y1, curb, MAX(2.0f, y1-y0)));
    }

    /* Lane markers. */
    for (int lane = 1; lane <= 2; lane++) {
        int markerCount = 8;
        for (int i = 0; i < markerCount; i++) {
            CGFloat z0 = fmodf(_roadScroll * 0.9f + (CGFloat)i / markerCount, 1.0f);
            CGFloat z1 = z0 + 0.055f;
            if (z1 > 1.0f) z1 = 1.0f;

            CGFloat y0 = horizon + powf(z0, 1.65f) * (bottom - horizon);
            CGFloat y1 = horizon + powf(z1, 1.65f) * (bottom - horizon);

            CGFloat c0 = [self roadCenterAtY:y0 width:w height:h];
            CGFloat c1 = [self roadCenterAtY:y1 width:w height:h];
            CGFloat hw0 = [self roadHalfWidthAtY:y0 width:w height:h];
            CGFloat hw1 = [self roadHalfWidthAtY:y1 width:w height:h];

            CGFloat lanePos0 = (lane == 1) ? c0 - hw0 * 0.33f : c0 + hw0 * 0.33f;
            CGFloat lanePos1 = (lane == 1) ? c1 - hw1 * 0.33f : c1 + hw1 * 0.33f;

            CGContextSetRGBFillColor(ctx, 0.88, 0.89, 0.84, 1.0);
            CGFloat markerW = MAX(1.5f, hw1 * 0.035f);

            CGContextMoveToPoint(ctx, lanePos0 - markerW, y0);
            CGContextAddLineToPoint(ctx, lanePos0 + markerW, y0);
            CGContextAddLineToPoint(ctx, lanePos1 + markerW, y1);
            CGContextAddLineToPoint(ctx, lanePos1 - markerW, y1);
            CGContextClosePath(ctx);
            CGContextFillPath(ctx);
        }
    }
}

- (void)drawTree:(CGContextRef)ctx x:(CGFloat)x y:(CGFloat)y scale:(CGFloat)s
{
    if (s <= 0.01f) return;

    CGContextSetRGBFillColor(ctx, 0.08, 0.12, 0.06, 1.0);
    CGContextFillRect(ctx, CGRectMake(x - 2*s, y, 4*s, 20*s));

    CGContextSetRGBFillColor(ctx, 0.02, 0.26, 0.08, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(x - 18*s, y - 45*s, 36*s, 42*s));
    CGContextSetRGBFillColor(ctx, 0.03, 0.34, 0.10, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(x - 12*s, y - 58*s, 24*s, 34*s));
}

- (void)drawArrowSign:(CGContextRef)ctx x:(CGFloat)x y:(CGFloat)y scale:(CGFloat)s right:(BOOL)right
{
    CGRect post = CGRectMake(x - 1.5f*s, y, 3*s, 35*s);
    CGContextSetRGBFillColor(ctx, 0.25, 0.25, 0.25, 1.0);
    CGContextFillRect(ctx, post);

    CGRect sign = CGRectMake(x - 18*s, y - 30*s, 36*s, 25*s);
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.88, 1.0);
    CGContextFillRect(ctx, sign);

    CGContextSetRGBStrokeColor(ctx, 0.15, 0.15, 0.12, 1.0);
    CGContextSetLineWidth(ctx, MAX(1.0f, s));
    CGContextStrokeRect(ctx, sign);

    CGContextSetRGBStrokeColor(ctx, 0.9, 0.05, 0.04, 1.0);
    CGContextSetLineWidth(ctx, MAX(1.5f, 2.0f*s));
    CGFloat cx = x;
    CGFloat cy = y - 17*s;

    CGContextMoveToPoint(ctx, cx - 8*s, cy);
    CGContextAddLineToPoint(ctx, cx + (right ? 7*s : -7*s), cy);
    CGContextAddLineToPoint(ctx, cx + (right ? 2*s : -2*s), cy - 5*s);
    CGContextMoveToPoint(ctx, cx + (right ? 7*s : -7*s), cy);
    CGContextAddLineToPoint(ctx, cx + (right ? 2*s : -2*s), cy + 5*s);
    CGContextStrokePath(ctx);
}

#pragma mark - Cars

- (void)drawPlayerCar:(CGContextRef)ctx centerX:(CGFloat)x bottomY:(CGFloat)y
                scale:(CGFloat)s steer:(CGFloat)steer
{
    /*
     * One low-memory vector sprite with seven visual states.
     * steer = -1 ... +1 changes the body angle and 3/4 perspective.
     */
    CGFloat bodyW = 178.0f * s;
    CGFloat bodyH = 78.0f * s;

    CGFloat topShift = steer * 15.0f * s;
    CGFloat left = x - bodyW * 0.5f;
    CGFloat right = x + bodyW * 0.5f;
    CGFloat top = y - bodyH;
    CGFloat shoulderY = top + bodyH * 0.28f;
    CGFloat bottom = y;

    /* Shadow. */
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.40);
    CGContextFillEllipseInRect(ctx, CGRectMake(x - bodyW*0.46f, y - 7*s,
                                               bodyW*0.92f, 16*s));

    /* Main body: wider at rear, shifted roof for turning. */
    CGMutablePathRef body = CGPathCreateMutable();
    CGPathMoveToPoint(body, NULL, left, y - 8*s);
    CGPathAddLineToPoint(body, NULL, left + 10*s, shoulderY);
    CGPathAddLineToPoint(body, NULL, left + 31*s + topShift, top + 7*s);
    CGPathAddLineToPoint(body, NULL, right - 31*s + topShift, top + 7*s);
    CGPathAddLineToPoint(body, NULL, right - 10*s, shoulderY);
    CGPathAddLineToPoint(body, NULL, right, y - 8*s);
    CGPathAddLineToPoint(body, NULL, right - 7*s, bottom);
    CGPathAddLineToPoint(body, NULL, left + 7*s, bottom);
    CGPathCloseSubpath(body);

    CGContextSetRGBFillColor(ctx, 0.82, 0.015, 0.025, 1.0);
    CGContextAddPath(ctx, body);
    CGContextFillPath(ctx);
    CGPathRelease(body);

    /* Dark lower bumper. */
    CGContextSetRGBFillColor(ctx, 0.20, 0.015, 0.02, 1.0);
    CGContextFillRect(ctx, CGRectMake(left + 8*s, y - 13*s, bodyW - 16*s, 13*s));

    /* Rear glass. */
    CGFloat glassW = bodyW * 0.46f;
    CGRect glass = CGRectMake(x - glassW*0.5f + topShift*0.72f,
                              top + 12*s,
                              glassW,
                              bodyH * 0.27f);

    CGContextSetRGBFillColor(ctx, 0.025, 0.055, 0.075, 1.0);
    MTFillRoundedRect(ctx, glass, 6*s);

    /* Glass highlight. */
    CGContextSetRGBFillColor(ctx, 0.12, 0.19, 0.22, 1.0);
    CGContextFillRect(ctx, CGRectMake(CGRectGetMinX(glass)+8*s,
                                      CGRectGetMinY(glass)+5*s,
                                      glassW*0.35f,
                                      3*s));

    /* Tail lights follow the angle. */
    CGFloat lampY = y - 34*s;
    CGFloat lampW = bodyW * 0.20f;

    CGContextSetRGBFillColor(ctx, 1.0, 0.03, 0.02, 1.0);
    CGContextFillRect(ctx, CGRectMake(left + 15*s, lampY, lampW, 9*s));
    CGContextFillRect(ctx, CGRectMake(right - 15*s - lampW, lampY, lampW, 9*s));

    CGContextSetRGBFillColor(ctx, 1.0, 0.35, 0.10, 1.0);
    CGContextFillRect(ctx, CGRectMake(left + 18*s, lampY+2*s, lampW*0.55f, 4*s));
    CGContextFillRect(ctx, CGRectMake(right - 18*s - lampW*0.55f, lampY+2*s,
                                      lampW*0.55f, 4*s));

    /* License/bumper detail. */
    CGContextSetRGBFillColor(ctx, 0.68, 0.02, 0.02, 1.0);
    CGContextFillRect(ctx, CGRectMake(x - 21*s + topShift*0.25f, y - 24*s,
                                      42*s, 8*s));

    CGContextSetRGBFillColor(ctx, 0.04, 0.04, 0.045, 1.0);
    CGContextFillRect(ctx, CGRectMake(x - 17*s + topShift*0.25f, y - 22*s,
                                      34*s, 4*s));

    /* Wheels / lower corners. */
    CGContextSetRGBFillColor(ctx, 0.025, 0.025, 0.025, 1.0);
    CGContextFillRect(ctx, CGRectMake(left + 3*s, y - 7*s, 19*s, 10*s));
    CGContextFillRect(ctx, CGRectMake(right - 22*s, y - 7*s, 19*s, 10*s));

    /* Thin outline. */
    CGContextSetRGBStrokeColor(ctx, 0.12, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(ctx, MAX(1.0f, 2*s));
    CGContextMoveToPoint(ctx, left + 10*s, shoulderY);
    CGContextAddLineToPoint(ctx, left + 31*s + topShift, top + 7*s);
    CGContextAddLineToPoint(ctx, right - 31*s + topShift, top + 7*s);
    CGContextAddLineToPoint(ctx, right - 10*s, shoulderY);
    CGContextStrokePath(ctx);

    /* Small center badge. */
    CGContextSetRGBFillColor(ctx, 0.95, 0.82, 0.16, 1.0);
    CGContextFillEllipseInRect(ctx, CGRectMake(x - 3*s + topShift*0.25f,
                                               y - 31*s, 6*s, 6*s));
}

- (void)drawRivalCar:(CGContextRef)ctx centerX:(CGFloat)x bottomY:(CGFloat)y
              scale:(CGFloat)s colorIndex:(int)colorIndex
{
    CGFloat w = 54.0f * s;
    CGFloat h = 28.0f * s;

    CGFloat r = 0.12f, g = 0.35f, b = 0.85f;
    if (colorIndex == 1) { r = 0.95f; g = 0.78f; b = 0.06f; }
    if (colorIndex == 2) { r = 0.88f; g = 0.88f; b = 0.88f; }

    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.35);
    CGContextFillEllipseInRect(ctx, CGRectMake(x-w*0.55f, y-2*s, w*1.1f, 5*s));

    CGContextSetRGBFillColor(ctx, r, g, b, 1.0);
    CGRect body = CGRectMake(x - w*0.5f, y - h*0.58f, w, h*0.58f);
    MTFillRoundedRect(ctx, body, 4*s);

    CGContextSetRGBFillColor(ctx, 0.03, 0.05, 0.07, 1.0);
    CGContextFillRect(ctx, CGRectMake(x - w*0.28f, y - h*0.58f,
                                      w*0.56f, h*0.20f));

    CGContextSetRGBFillColor(ctx, 0.95, 0.04, 0.03, 1.0);
    CGContextFillRect(ctx, CGRectMake(x - w*0.37f, y - h*0.28f, w*0.15f, 4*s));
    CGContextFillRect(ctx, CGRectMake(x + w*0.22f, y - h*0.28f, w*0.15f, 4*s));
}

#pragma mark - HUD

- (void)drawHUD:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h
{
    UIFont *big = [UIFont boldSystemFontOfSize:28.0f];
    UIFont *small = [UIFont boldSystemFontOfSize:18.0f];

    /* Top dark translucent strip. */
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.42);
    CGContextFillRect(ctx, CGRectMake(0, 0, w, 58));

    NSDictionary *shadow = nil;
    (void)shadow;

    NSString *speed = [NSString stringWithFormat:@"%d MPH", 165 + (int)(fabsf(_steer) * 18.0f)];
    NSString *score = [NSString stringWithFormat:@"%08d", _score];
    NSString *lap = [NSString stringWithFormat:@"LAP %d/3", _lap];

    CGContextSetRGBFillColor(ctx, 0.98, 0.98, 0.92, 1.0);
    [speed drawAtPoint:CGPointMake(18, 9) withFont:big];
    [score drawAtPoint:CGPointMake(w - 155, 10) withFont:big];

    CGContextSetRGBFillColor(ctx, 1.0, 0.25, 0.12, 1.0);
    [lap drawAtPoint:CGPointMake(w * 0.5f - 34, 12) withFont:small];

    /* Speed bar. */
    CGFloat barW = 150.0f;
    CGFloat fill = MTClamp((165.0f + fabsf(_steer) * 18.0f) / 200.0f, 0.0f, 1.0f);
    CGContextSetRGBFillColor(ctx, 0.12, 0.12, 0.12, 0.85);
    CGContextFillRect(ctx, CGRectMake(18, 39, barW, 10));

    CGContextSetRGBFillColor(ctx, 0.92, 0.05, 0.04, 1.0);
    CGContextFillRect(ctx, CGRectMake(18, 39, barW * fill, 10));

    CGContextSetRGBStrokeColor(ctx, 0.95, 0.95, 0.85, 1.0);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextStrokeRect(ctx, CGRectMake(18, 39, barW, 10));

    /* Bottom control hints: no giant instruction text over the car. */
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.24);
    CGContextFillRect(ctx, CGRectMake(0, h - 38, w, 38));

    UIFont *hint = [UIFont boldSystemFontOfSize:15.0f];
    CGContextSetRGBFillColor(ctx, 0.95, 0.95, 0.90, 0.75);
    [@"<  STEER" drawAtPoint:CGPointMake(18, h - 30) withFont:hint];
    [@"STEER  >" drawAtPoint:CGPointMake(w - 85, h - 30) withFont:hint];

    /* Tiny title, centered. */
    UIFont *title = [UIFont boldSystemFontOfSize:13.0f];
    CGContextSetRGBFillColor(ctx, 1.0, 0.35, 0.18, 0.85);
    [@"MEHMET TURBO" drawAtPoint:CGPointMake(w * 0.5f - 48, h - 29) withFont:title];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    (void)rect;

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;

    if (w <= 0 || h <= 0) return;

    [self drawSkyAndMountains:ctx width:w height:h];
    [self drawRoad:ctx width:w height:h];

    CGFloat horizon = h * 0.335f;

    /* Perspective roadside trees and signs. */
    for (int i = 0; i < 9; i++) {
        CGFloat z = fmodf((CGFloat)i / 9.0f + _roadScroll * 0.17f, 1.0f);
        CGFloat y = horizon + powf(z, 1.65f) * (h - horizon);
        CGFloat c = [self roadCenterAtY:y width:w height:h];
        CGFloat hw = [self roadHalfWidthAtY:y width:w height:h];
        CGFloat s = 0.22f + z * 1.35f;

        if (i & 1) {
            [self drawTree:ctx x:c - hw - 28*s y:y scale:s];
        } else {
            [self drawTree:ctx x:c + hw + 35*s y:y scale:s];
        }

        if (i == 2 || i == 6) {
            BOOL right = (i == 6);
            [self drawArrowSign:ctx
                              x:(right ? c + hw + 20*s : c - hw - 20*s)
                              y:y scale:s right:right];
        }
    }

    /* Two simple traffic cars at depth. */
    CGFloat z1 = fmodf(0.54f + _roadScroll * 0.08f, 1.0f);
    CGFloat y1 = horizon + powf(z1, 1.65f) * (h - horizon);
    CGFloat c1 = [self roadCenterAtY:y1 width:w height:h];
    CGFloat hw1 = [self roadHalfWidthAtY:y1 width:w height:h];
    [self drawRivalCar:ctx centerX:c1 - hw1*0.22f bottomY:y1 scale:(0.20f + z1*0.42f) colorIndex:0];

    CGFloat z2 = fmodf(0.77f + _roadScroll * 0.06f, 1.0f);
    CGFloat y2 = horizon + powf(z2, 1.65f) * (h - horizon);
    CGFloat c2 = [self roadCenterAtY:y2 width:w height:h];
    CGFloat hw2 = [self roadHalfWidthAtY:y2 width:w height:h];
    [self drawRivalCar:ctx centerX:c2 + hw2*0.20f bottomY:y2 scale:(0.16f + z2*0.38f) colorIndex:1];

    /* Player stays at the bottom of the perspective road. */
    CGFloat playerY = h - 62.0f;
    CGFloat roadC = [self roadCenterAtY:playerY width:w height:h];
    CGFloat roadHW = [self roadHalfWidthAtY:playerY width:w height:h];

    CGFloat px = roadC + _playerX * roadHW * 0.82f;
    CGFloat playerScale = MTClamp(w / 1100.0f, 0.72f, 0.92f);

    [self drawPlayerCar:ctx centerX:px bottomY:playerY
                  scale:playerScale steer:_steer];

    [self drawHUD:ctx width:w height:h];
}

@end
