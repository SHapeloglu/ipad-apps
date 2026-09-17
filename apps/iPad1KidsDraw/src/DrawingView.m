#import "DrawingView.h"
#import <math.h>
#import <stdlib.h>
#import <string.h>

#define MAX_HISTORY_STEPS 5

typedef struct { int x; int y; } KidsPixelPoint;

@implementation DrawingView

@synthesize strokeColor = _strokeColor;
@synthesize canvasColor = _canvasColor;
@synthesize lineWidth = _lineWidth;
@synthesize stampScale = _stampScale;
@synthesize sprayDensity = _sprayDensity;
@synthesize spraySize = _spraySize;
@synthesize neonStrength = _neonStrength;
@synthesize globalOpacity = _globalOpacity;
@synthesize eraserWidth = _eraserWidth;
@synthesize secondaryStrokeColor = _secondaryStrokeColor;
@synthesize secondaryBrushStyle = _secondaryBrushStyle;
@synthesize smudgeStrength = _smudgeStrength;
@synthesize mixerStrength = _mixerStrength;
@synthesize brushStyle = _brushStyle;
@synthesize stampType = _stampType;
@synthesize shapeType = _shapeType;
@synthesize bucketMode = _bucketMode;
@synthesize mirrorMode = _mirrorMode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.multipleTouchEnabled = YES;
        self.opaque = YES;
        self.strokeColor = [UIColor blackColor];
        self.canvasColor = [UIColor whiteColor];
        self.lineWidth = 7.0f;
        _strokeAlpha = 1.0f;
        _stampScale = 1.0f;
        _sprayDensity = 1.0f;
        _spraySize = 1.0f;
        _neonStrength = 1.0f;
        _globalOpacity = 1.0f;
        _eraserWidth = 28.0f;
        _secondaryStrokeColor = [[UIColor blueColor] retain];
        _secondaryBrushStyle = KidsBrushNormal;
        _smudgeStrength = 0.55f;
        _mixerStrength = 0.50f;
        _brushStyle = KidsBrushNormal;
        _stampType = KidsStampNone;
        _shapeType = KidsShapeNone;
        _bucketMode = NO;
        _mirrorMode = NO;
        _drawing = NO;
        _undoStack = [[NSMutableArray alloc] initWithCapacity:MAX_HISTORY_STEPS];
        _redoStack = [[NSMutableArray alloc] initWithCapacity:MAX_HISTORY_STEPS];
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
    [self.canvasColor setFill];
    UIRectFill(self.bounds);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_image release];
    _image = [newImage retain];
}

- (void)trimHistory:(NSMutableArray *)stack
{
    while ([stack count] > MAX_HISTORY_STEPS) [stack removeObjectAtIndex:0];
}

- (void)pushUndoSnapshot
{
    [self ensureImage];
    if (_image == nil) return;
    [_undoStack addObject:_image];
    [self trimHistory:_undoStack];
    [_redoStack removeAllObjects];
}

- (void)applyBrushStyle
{
    if (_brushStyle == KidsBrushPencil) _strokeAlpha = 0.90f;
    else if (_brushStyle == KidsBrushMarker) _strokeAlpha = 0.58f;
    else if (_brushStyle == KidsBrushPastel) _strokeAlpha = 0.52f;
    else if (_brushStyle == KidsBrushNeon) _strokeAlpha = 1.0f;
    else if (_brushStyle == KidsBrushChalk) _strokeAlpha = 0.72f;
    else if (_brushStyle == KidsBrushSpray) _strokeAlpha = 0.58f;
    else _strokeAlpha = 1.0f;
}

- (void)setStrokeInContext:(CGContextRef)ctx
{
    CGFloat r=0,g=0,b=0,a=1;
    [self applyBrushStyle];
    if ([self.strokeColor respondsToSelector:@selector(getRed:green:blue:alpha:)] && [self.strokeColor getRed:&r green:&g blue:&b alpha:&a]) {
        CGContextSetRGBStrokeColor(ctx,r,g,b,a*_strokeAlpha);
        CGContextSetRGBFillColor(ctx,r,g,b,a*_strokeAlpha);
    } else {
        CGContextSetStrokeColorWithColor(ctx,self.strokeColor.CGColor);
        CGContextSetFillColorWithColor(ctx,self.strokeColor.CGColor);
        CGContextSetAlpha(ctx,_strokeAlpha);
    }
}


- (void)notifyCanvasChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KidsDrawCanvasChanged" object:self];
}


- (void)setSelectedColorInContext:(CGContextRef)ctx alpha:(CGFloat)alpha fill:(BOOL)fill
{
    CGFloat r=0,g=0,b=0,a=1;
    if ([self.strokeColor respondsToSelector:@selector(getRed:green:blue:alpha:)] &&
        [self.strokeColor getRed:&r green:&g blue:&b alpha:&a]) {
        if(fill) CGContextSetRGBFillColor(ctx,r,g,b,a*alpha);
        else CGContextSetRGBStrokeColor(ctx,r,g,b,a*alpha);
    } else {
        if(fill) CGContextSetFillColorWithColor(ctx,self.strokeColor.CGColor);
        else CGContextSetStrokeColorWithColor(ctx,self.strokeColor.CGColor);
        CGContextSetAlpha(ctx,alpha);
    }
}

- (void)strokeSimpleFrom:(CGPoint)a to:(CGPoint)b context:(CGContextRef)ctx width:(CGFloat)width alpha:(CGFloat)alpha
{
    CGContextSetAlpha(ctx,1.0f);
    [self setSelectedColorInContext:ctx alpha:alpha*_globalOpacity fill:NO];
    CGContextSetLineWidth(ctx,width);
    CGContextSetLineCap(ctx,kCGLineCapRound);
    CGContextSetLineJoin(ctx,kCGLineJoinRound);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,a.x,a.y);
    CGContextAddLineToPoint(ctx,b.x,b.y);
    CGContextStrokePath(ctx);
}

- (void)drawSprayAt:(CGPoint)p context:(CGContextRef)ctx
{
    int count=(int)MIN(36.0f,MAX(8.0f,self.lineWidth*(0.8f+_sprayDensity)));
    CGFloat radius=MAX(7.0f,self.lineWidth*(1.25f+0.75f*_sprayDensity)*_spraySize);
    [self setSelectedColorInContext:ctx alpha:0.58f*_globalOpacity fill:YES];
    int i;
    for(i=0;i<count;i++){
        CGFloat rx=((CGFloat)(rand()%2001)/1000.0f-1.0f)*radius;
        CGFloat ry=((CGFloat)(rand()%2001)/1000.0f-1.0f)*radius;
        if(rx*rx+ry*ry>radius*radius) continue;
        CGFloat dot=1.0f+(CGFloat)(rand()%3);
        CGContextFillEllipseInRect(ctx,CGRectMake(p.x+rx,p.y+ry,dot,dot));
    }
}


- (UIColor *)colorForTouch:(UITouch *)touch
{
    if(touch==_touchB && _secondaryStrokeColor) return _secondaryStrokeColor;
    return self.strokeColor;
}

- (KidsBrushStyle)brushForTouch:(UITouch *)touch
{
    if(touch==_touchB) return _secondaryBrushStyle;
    return _brushStyle;
}

- (void)drawSegmentFrom:(CGPoint)fromPoint
                     to:(CGPoint)toPoint
                context:(CGContextRef)ctx
                  touch:(UITouch *)touch
{
    UIColor *savedColor=[self.strokeColor retain];
    KidsBrushStyle savedBrush=_brushStyle;
    self.strokeColor=[self colorForTouch:touch];
    _brushStyle=[self brushForTouch:touch];

    [self drawSegmentFrom:fromPoint to:toPoint context:ctx];

    self.strokeColor=savedColor;
    _brushStyle=savedBrush;
    [savedColor release];
}


- (void)drawSmudgeFrom:(CGPoint)a to:(CGPoint)b context:(CGContextRef)ctx
{
    /*
     * iPad 1 için hafif smudge:
     * Tam convolution yok. Önceki çizgiden küçük yarı saydam örnekler
     * hareket yönüne doğru tekrar basılır.
     */
    CGFloat width=MAX(6.0f,self.lineWidth*1.8f);
    CGFloat dx=b.x-a.x, dy=b.y-a.y;
    int steps=4;
    int i;
    for(i=0;i<steps;i++){
        CGFloat t=(CGFloat)i/(CGFloat)steps;
        CGPoint p=CGPointMake(a.x+dx*t,a.y+dy*t);
        CGContextSetRGBFillColor(ctx,1,1,1,0.03f*_smudgeStrength*_globalOpacity);
        CGContextFillEllipseInRect(ctx,CGRectMake(p.x-width*0.5f,p.y-width*0.5f,width,width));
    }
    /* Renk taşıma hissi için mevcut seçili rengi çok düşük alfa ile sürükle. */
    [self strokeSimpleFrom:a to:b context:ctx width:width alpha:0.08f*_smudgeStrength];
}

- (void)drawMixerFrom:(CGPoint)a to:(CGPoint)b context:(CGContextRef)ctx
{
    /*
     * Gerçek pigment karışımı yerine düşük maliyetli overlay yaklaşımı.
     * İPad 1 CPU/RAM sınırında daha güvenli.
     */
    CGFloat wide=MAX(8.0f,self.lineWidth*1.45f);
    [self strokeSimpleFrom:a to:b context:ctx width:wide alpha:0.20f*_mixerStrength];
    [self strokeSimpleFrom:a to:b context:ctx width:MAX(2.0f,wide*0.45f) alpha:0.35f*_mixerStrength];
}

- (void)drawSegmentFrom:(CGPoint)fromPoint to:(CGPoint)toPoint context:(CGContextRef)ctx
{
    CGFloat width=self.lineWidth;

    if(_brushStyle==KidsBrushSpray){
        [self drawSprayAt:toPoint context:ctx];
        if(_mirrorMode) [self drawSprayAt:CGPointMake(self.bounds.size.width-toPoint.x,toPoint.y) context:ctx];
        return;
    }
    if(_brushStyle==KidsBrushSmudge){
        [self drawSmudgeFrom:fromPoint to:toPoint context:ctx];
        return;
    }
    if(_brushStyle==KidsBrushMixer){
        [self drawMixerFrom:fromPoint to:toPoint context:ctx];
        return;
    }

    if(_brushStyle==KidsBrushRainbow){
        CGFloat hue=fmodf((toPoint.x+toPoint.y)/(MAX(1.0f,self.bounds.size.width+self.bounds.size.height)),1.0f);
        UIColor *rain=[UIColor colorWithHue:hue saturation:0.95f brightness:1.0f alpha:1.0f];
        CGContextSetStrokeColorWithColor(ctx,rain.CGColor);
        CGContextSetLineWidth(ctx,width);
        CGContextSetLineCap(ctx,kCGLineCapRound);
        CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,fromPoint.x,fromPoint.y); CGContextAddLineToPoint(ctx,toPoint.x,toPoint.y); CGContextStrokePath(ctx);
        if(_mirrorMode){
            CGFloat w=self.bounds.size.width;
            CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,w-fromPoint.x,fromPoint.y); CGContextAddLineToPoint(ctx,w-toPoint.x,toPoint.y); CGContextStrokePath(ctx);
        }
        return;
    }

    if(_brushStyle==KidsBrushPencil){
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:MAX(1.0f,width*0.34f) alpha:0.86f];
        [self strokeSimpleFrom:CGPointMake(fromPoint.x+0.6f,fromPoint.y+0.4f)
                            to:CGPointMake(toPoint.x+0.6f,toPoint.y+0.4f)
                       context:ctx width:MAX(1.0f,width*0.16f) alpha:0.26f];
    } else if(_brushStyle==KidsBrushMarker){
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:width*1.65f alpha:0.52f];
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:MAX(1.0f,width*0.60f) alpha:0.18f];
    } else if(_brushStyle==KidsBrushPastel){
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:width*1.30f alpha:0.46f];
        [self strokeSimpleFrom:CGPointMake(fromPoint.x-1.0f,fromPoint.y)
                            to:CGPointMake(toPoint.x-1.0f,toPoint.y)
                       context:ctx width:MAX(1.0f,width*0.30f) alpha:0.14f];
    } else if(_brushStyle==KidsBrushNeon){
        CGFloat glowAlpha=MIN(0.38f,0.12f+0.18f*_neonStrength);
        CGFloat coreAlpha=MIN(1.0f,0.72f+0.20f*_neonStrength);
        CGFloat glowWidth=width*(1.65f+0.85f*_neonStrength);
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:glowWidth alpha:glowAlpha];
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:MAX(2.0f,width*(0.56f+0.24f*_neonStrength)) alpha:coreAlpha];
    } else if(_brushStyle==KidsBrushChalk){
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:width alpha:0.62f];
        int i;
        for(i=0;i<3;i++){
            CGFloat jx=(CGFloat)((rand()%7)-3);
            CGFloat jy=(CGFloat)((rand()%7)-3);
            [self strokeSimpleFrom:CGPointMake(fromPoint.x+jx,fromPoint.y+jy)
                                to:CGPointMake(toPoint.x+jx,toPoint.y+jy)
                           context:ctx width:MAX(1.0f,width*0.22f) alpha:0.16f];
        }
    } else {
        [self strokeSimpleFrom:fromPoint to:toPoint context:ctx width:width alpha:1.0f];
    }

    if(_mirrorMode){
        CGFloat w=self.bounds.size.width;
        CGPoint ma=CGPointMake(w-fromPoint.x,fromPoint.y);
        CGPoint mb=CGPointMake(w-toPoint.x,toPoint.y);
        if(_brushStyle==KidsBrushNeon){
            CGFloat glowAlpha=MIN(0.38f,0.12f+0.18f*_neonStrength);
            CGFloat coreAlpha=MIN(1.0f,0.72f+0.20f*_neonStrength);
            CGFloat glowWidth=width*(1.65f+0.85f*_neonStrength);
            [self strokeSimpleFrom:ma to:mb context:ctx width:glowWidth alpha:glowAlpha];
            [self strokeSimpleFrom:ma to:mb context:ctx width:MAX(2.0f,width*(0.56f+0.24f*_neonStrength)) alpha:coreAlpha];
        } else {
            [self strokeSimpleFrom:ma to:mb context:ctx width:width alpha:_strokeAlpha];
        }
    }
}

- (void)drawLineFrom:(CGPoint)fromPoint to:(CGPoint)toPoint
{
    [self ensureImage];
    [self applyBrushStyle];
    UIGraphicsBeginImageContext(self.bounds.size);
    [_image drawInRect:self.bounds];
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    [self drawSegmentFrom:fromPoint to:toPoint context:ctx];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_image release]; _image=[newImage retain];
    [self setNeedsDisplay];
}

- (void)drawStarAt:(CGPoint)p context:(CGContextRef)ctx radius:(CGFloat)radius
{
    int i; CGFloat angle=-M_PI_2;
    CGContextBeginPath(ctx);
    for(i=0;i<10;i++) {
        CGFloat rr=(i%2==0)?radius:radius*0.42f;
        CGFloat x=p.x+cosf(angle)*rr, y=p.y+sinf(angle)*rr;
        if(i==0) CGContextMoveToPoint(ctx,x,y); else CGContextAddLineToPoint(ctx,x,y);
        angle+=(CGFloat)M_PI/5.0f;
    }
    CGContextClosePath(ctx); CGContextFillPath(ctx);
}

- (void)drawHeartAt:(CGPoint)p context:(CGContextRef)ctx size:(CGFloat)s
{
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx,p.x,p.y+s*0.55f);
    CGContextAddCurveToPoint(ctx,p.x-s,p.y-s*0.10f,p.x-s*0.55f,p.y-s,p.x,p.y-s*0.42f);
    CGContextAddCurveToPoint(ctx,p.x+s*0.55f,p.y-s,p.x+s,p.y-s*0.10f,p.x,p.y+s*0.55f);
    CGContextClosePath(ctx); CGContextFillPath(ctx);
}

- (void)drawSmileAt:(CGPoint)p context:(CGContextRef)ctx radius:(CGFloat)r
{
    CGContextSetLineWidth(ctx,4.0f);
    CGContextStrokeEllipseInRect(ctx,CGRectMake(p.x-r,p.y-r,r*2,r*2));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.42f,p.y-r*0.30f,6,8));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x+r*0.28f,p.y-r*0.30f,6,8));
    CGContextBeginPath(ctx); CGContextAddArc(ctx,p.x,p.y+1,r*0.52f,0.20f,(CGFloat)M_PI-0.20f,0); CGContextStrokePath(ctx);
}

- (void)drawFlowerAt:(CGPoint)p context:(CGContextRef)ctx radius:(CGFloat)r
{
    int i;
    for(i=0;i<6;i++) {
        CGFloat a=(CGFloat)i*(CGFloat)M_PI/3.0f;
        CGFloat x=p.x+cosf(a)*r*0.65f, y=p.y+sinf(a)*r*0.65f;
        CGContextFillEllipseInRect(ctx,CGRectMake(x-r*0.38f,y-r*0.38f,r*0.76f,r*0.76f));
    }
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.30f,p.y-r*0.30f,r*0.60f,r*0.60f));
}

- (void)drawCloudAt:(CGPoint)p context:(CGContextRef)ctx radius:(CGFloat)r
{
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r,p.y-r*0.15f,r*0.9f,r*0.7f));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.45f,p.y-r*0.65f,r,r));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x+r*0.05f,p.y-r*0.35f,r*0.9f,r*0.8f));
    CGContextFillRect(ctx,CGRectMake(p.x-r*0.65f,p.y,r*1.35f,r*0.35f));
}

- (void)drawCarAt:(CGPoint)p context:(CGContextRef)ctx radius:(CGFloat)r
{
    CGContextFillRect(ctx,CGRectMake(p.x-r,p.y-r*0.15f,r*2,r*0.65f));
    CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x-r*0.55f,p.y-r*0.15f); CGContextAddLineToPoint(ctx,p.x-r*0.22f,p.y-r*0.70f); CGContextAddLineToPoint(ctx,p.x+r*0.48f,p.y-r*0.70f); CGContextAddLineToPoint(ctx,p.x+r*0.75f,p.y-r*0.15f); CGContextClosePath(ctx); CGContextFillPath(ctx);
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.65f,p.y+r*0.28f,r*0.42f,r*0.42f));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x+r*0.28f,p.y+r*0.28f,r*0.42f,r*0.42f));
}

- (void)drawFishStampAt:(CGPoint)p context:(CGContextRef)ctx radius:(CGFloat)r
{
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r,p.y-r*0.55f,r*1.55f,r*1.1f));
    CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x-r*0.75f,p.y); CGContextAddLineToPoint(ctx,p.x-r*1.35f,p.y-r*0.65f); CGContextAddLineToPoint(ctx,p.x-r*1.35f,p.y+r*0.65f); CGContextClosePath(ctx); CGContextFillPath(ctx);
}

- (void)drawButterflyAt:(CGPoint)p context:(CGContextRef)ctx radius:(CGFloat)r
{
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r,p.y-r*0.75f,r*0.85f,r));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x+r*0.15f,p.y-r*0.75f,r*0.85f,r));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.85f,p.y+r*0.05f,r*0.70f,r*0.75f));
    CGContextFillEllipseInRect(ctx,CGRectMake(p.x+r*0.15f,p.y+r*0.05f,r*0.70f,r*0.75f));
    CGContextFillRect(ctx,CGRectMake(p.x-r*0.10f,p.y-r*0.7f,r*0.20f,r*1.5f));
}

- (void)placeStampAt:(CGPoint)p
{
    [self ensureImage]; [self pushUndoSnapshot];
    UIGraphicsBeginImageContext(self.bounds.size); [_image drawInRect:self.bounds];
    CGContextRef ctx=UIGraphicsGetCurrentContext(); [self setStrokeInContext:ctx]; CGContextSetLineWidth(ctx,4.0f);
    CGFloat r=30.0f*MAX(0.45f,MIN(2.2f,_stampScale));
    switch(_stampType) {
        case KidsStampStar: [self drawStarAt:p context:ctx radius:r]; break;
        case KidsStampHeart: [self drawHeartAt:p context:ctx size:r]; break;
        case KidsStampSmile: [self drawSmileAt:p context:ctx radius:r]; break;
        case KidsStampCircle: CGContextStrokeEllipseInRect(ctx,CGRectMake(p.x-r,p.y-r,r*2,r*2)); break;
        case KidsStampSquare: CGContextStrokeRect(ctx,CGRectMake(p.x-r,p.y-r,r*2,r*2)); break;
        case KidsStampTriangle: CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x,p.y-r); CGContextAddLineToPoint(ctx,p.x-r,p.y+r); CGContextAddLineToPoint(ctx,p.x+r,p.y+r); CGContextClosePath(ctx); CGContextStrokePath(ctx); break;
        case KidsStampFlower: [self drawFlowerAt:p context:ctx radius:r]; break;
        case KidsStampSun: CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.55f,p.y-r*0.55f,r*1.1f,r*1.1f)); { int i; for(i=0;i<8;i++){ CGFloat a=i*(CGFloat)M_PI/4.0f; CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x+cosf(a)*r*0.75f,p.y+sinf(a)*r*0.75f); CGContextAddLineToPoint(ctx,p.x+cosf(a)*r*1.25f,p.y+sinf(a)*r*1.25f); CGContextStrokePath(ctx);} } break;
        case KidsStampCloud: [self drawCloudAt:p context:ctx radius:r]; break;
        case KidsStampCar: [self drawCarAt:p context:ctx radius:r]; break;
        case KidsStampFish: [self drawFishStampAt:p context:ctx radius:r]; break;
        case KidsStampButterfly: [self drawButterflyAt:p context:ctx radius:r]; break;
        case KidsStampMoon: CGContextBeginPath(ctx); CGContextAddArc(ctx,p.x,p.y,r,0,(CGFloat)M_PI*2,0); CGContextAddArc(ctx,p.x+r*0.45f,p.y-r*0.12f,r*0.88f,0,(CGFloat)M_PI*2,1); CGContextFillPath(ctx); break;
        case KidsStampDiamond: CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x,p.y-r); CGContextAddLineToPoint(ctx,p.x+r,p.y); CGContextAddLineToPoint(ctx,p.x,p.y+r); CGContextAddLineToPoint(ctx,p.x-r,p.y); CGContextClosePath(ctx); CGContextFillPath(ctx); break;
        case KidsStampBalloon: CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.7f,p.y-r,r*1.4f,r*1.6f)); CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x,p.y+r*0.6f); CGContextAddLineToPoint(ctx,p.x-r*0.25f,p.y+r*1.45f); CGContextStrokePath(ctx); break;
        case KidsStampApple: CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.85f,p.y-r*0.65f,r*1.7f,r*1.5f)); CGContextFillRect(ctx,CGRectMake(p.x-2,p.y-r,4,r*0.35f)); break;
        case KidsStampTree: CGContextFillRect(ctx,CGRectMake(p.x-r*0.15f,p.y,r*0.30f,r)); CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r,p.y-r,r*2,r*1.5f)); break;
        case KidsStampHouse: CGContextStrokeRect(ctx,CGRectMake(p.x-r,p.y-r*0.2f,r*2,r*1.2f)); CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x-r*1.15f,p.y-r*0.2f); CGContextAddLineToPoint(ctx,p.x,p.y-r*1.2f); CGContextAddLineToPoint(ctx,p.x+r*1.15f,p.y-r*0.2f); CGContextStrokePath(ctx); break;
        case KidsStampRocket: CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.4f,p.y-r,r*0.8f,r*1.7f)); CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x-r*0.4f,p.y+r*0.3f); CGContextAddLineToPoint(ctx,p.x-r,p.y+r); CGContextAddLineToPoint(ctx,p.x-r*0.3f,p.y+r*0.65f); CGContextFillPath(ctx); break;
        case KidsStampCat: [self drawSmileAt:p context:ctx radius:r]; CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x-r*0.7f,p.y-r*0.7f); CGContextAddLineToPoint(ctx,p.x-r*0.45f,p.y-r*1.3f); CGContextAddLineToPoint(ctx,p.x-r*0.1f,p.y-r*0.85f); CGContextStrokePath(ctx); break;
        case KidsStampRobot: CGContextStrokeRect(ctx,CGRectMake(p.x-r,p.y-r*0.8f,r*2,r*1.6f)); CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.45f,p.y-r*0.25f,8,8)); CGContextFillEllipseInRect(ctx,CGRectMake(p.x+r*0.25f,p.y-r*0.25f,8,8)); break;
        case KidsStampCrown: CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x-r,p.y+r*0.5f); CGContextAddLineToPoint(ctx,p.x-r*0.7f,p.y-r); CGContextAddLineToPoint(ctx,p.x,p.y-r*0.25f); CGContextAddLineToPoint(ctx,p.x+r*0.7f,p.y-r); CGContextAddLineToPoint(ctx,p.x+r,p.y+r*0.5f); CGContextClosePath(ctx); CGContextFillPath(ctx); break;
        case KidsStampMusic: CGContextSetLineWidth(ctx,6); CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x,p.y+r*0.5f); CGContextAddLineToPoint(ctx,p.x,p.y-r); CGContextAddLineToPoint(ctx,p.x+r*0.7f,p.y-r*0.8f); CGContextStrokePath(ctx); CGContextFillEllipseInRect(ctx,CGRectMake(p.x-r*0.45f,p.y+r*0.3f,r*0.6f,r*0.45f)); break;
        case KidsStampLightning: CGContextBeginPath(ctx); CGContextMoveToPoint(ctx,p.x+r*0.15f,p.y-r); CGContextAddLineToPoint(ctx,p.x-r*0.65f,p.y+r*0.1f); CGContextAddLineToPoint(ctx,p.x-r*0.05f,p.y+r*0.05f); CGContextAddLineToPoint(ctx,p.x-r*0.35f,p.y+r); CGContextAddLineToPoint(ctx,p.x+r*0.75f,p.y-r*0.25f); CGContextAddLineToPoint(ctx,p.x+r*0.1f,p.y-r*0.15f); CGContextClosePath(ctx); CGContextFillPath(ctx); break;
        default: break;
    }
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext();
    [_image release]; _image=[newImage retain]; [self setNeedsDisplay];
}

static int KidsColorDistance(unsigned char *a, unsigned char *b)
{
    return abs((int)a[0]-(int)b[0]) + abs((int)a[1]-(int)b[1]) + abs((int)a[2]-(int)b[2]);
}

- (void)floodFillAt:(CGPoint)point
{
    [self ensureImage];
    CGImageRef source=[_image CGImage];
    size_t width=CGImageGetWidth(source), height=CGImageGetHeight(source);
    if(width==0 || height==0) return;
    int sx=(int)(point.x*self.bounds.size.width/(self.bounds.size.width));
    int sy=(int)(point.y*self.bounds.size.height/(self.bounds.size.height));
    if(sx<0||sy<0||sx>=(int)width||sy>=(int)height) return;

    size_t bytesPerRow=width*4;
    unsigned char *data=(unsigned char *)calloc(height,bytesPerRow);
    if(!data) return;
    CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx=CGBitmapContextCreate(data,width,height,8,bytesPerRow,cs,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    if(!ctx){CGColorSpaceRelease(cs); free(data); return;}
    CGContextTranslateCTM(ctx,0,(CGFloat)height); CGContextScaleCTM(ctx,1,-1);
    CGContextDrawImage(ctx,CGRectMake(0,0,width,height),source);
    CGContextTranslateCTM(ctx,0,(CGFloat)height); CGContextScaleCTM(ctx,1,-1);

    int px=(int)(point.x*(CGFloat)width/self.bounds.size.width);
    int py=(int)(point.y*(CGFloat)height/self.bounds.size.height);
    unsigned char target[4]; memcpy(target,data+py*bytesPerRow+px*4,4);
    CGFloat rr=0,gg=0,bb=0,aa=1;
    if(![self.strokeColor getRed:&rr green:&gg blue:&bb alpha:&aa]){ rr=0;gg=0;bb=0;aa=1; }
    unsigned char replacement[4]={(unsigned char)(rr*255),(unsigned char)(gg*255),(unsigned char)(bb*255),255};
    if(KidsColorDistance(target,replacement)<18){ CGContextRelease(ctx); CGColorSpaceRelease(cs); free(data); return; }

    [self pushUndoSnapshot];
    size_t capacity=width*height;
    KidsPixelPoint *queue=(KidsPixelPoint *)malloc(sizeof(KidsPixelPoint)*capacity);
    unsigned char *visited=(unsigned char *)calloc(capacity,1);
    if(!queue || !visited){ if(queue) free(queue); if(visited) free(visited); CGContextRelease(ctx); CGColorSpaceRelease(cs); free(data); return; }
    size_t head=0,tail=0; queue[tail++]=(KidsPixelPoint){px,py}; visited[(size_t)py*width+(size_t)px]=1;
    const int tolerance=70;
    while(head<tail) {
        KidsPixelPoint q=queue[head++];
        unsigned char *cur=data+(size_t)q.y*bytesPerRow+(size_t)q.x*4;
        if(KidsColorDistance(cur,target)>tolerance) continue;
        cur[0]=replacement[0]; cur[1]=replacement[1]; cur[2]=replacement[2]; cur[3]=255;
        int nx[4]={q.x+1,q.x-1,q.x,q.x};
        int ny[4]={q.y,q.y,q.y+1,q.y-1};
        int k;
        for(k=0;k<4;k++) {
            if(nx[k]>=0 && ny[k]>=0 && nx[k]<(int)width && ny[k]<(int)height) {
                size_t vi=(size_t)ny[k]*width+(size_t)nx[k];
                if(!visited[vi] && tail<capacity) { visited[vi]=1; queue[tail++]=(KidsPixelPoint){nx[k],ny[k]}; }
            }
        }
    }
    free(visited);
    free(queue);
    CGImageRef out=CGBitmapContextCreateImage(ctx);
    UIImage *newImage=[UIImage imageWithCGImage:out];
    [_image release]; _image=[newImage retain]; [self setNeedsDisplay];
    CGImageRelease(out); CGContextRelease(ctx); CGColorSpaceRelease(cs); free(data);
}

- (void)drawShapeFrom:(CGPoint)a to:(CGPoint)b
{
    [self ensureImage];
    UIGraphicsBeginImageContext(self.bounds.size); [_image drawInRect:self.bounds];
    CGContextRef ctx=UIGraphicsGetCurrentContext(); CGContextSetLineWidth(ctx,MAX(2.0f,self.lineWidth)); CGContextSetLineCap(ctx,kCGLineCapRound); [self setStrokeInContext:ctx];
    CGRect r=CGRectMake(MIN(a.x,b.x),MIN(a.y,b.y),fabsf(b.x-a.x),fabsf(b.y-a.y));
    if(_shapeType==KidsShapeLine){CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,a.x,a.y);CGContextAddLineToPoint(ctx,b.x,b.y);CGContextStrokePath(ctx);}
    else if(_shapeType==KidsShapeRectangle) CGContextStrokeRect(ctx,r);
    else if(_shapeType==KidsShapeEllipse) CGContextStrokeEllipseInRect(ctx,r);
    else if(_shapeType==KidsShapeTriangle){CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,(a.x+b.x)/2.0f,a.y);CGContextAddLineToPoint(ctx,a.x,b.y);CGContextAddLineToPoint(ctx,b.x,b.y);CGContextClosePath(ctx);CGContextStrokePath(ctx);}
    if(_mirrorMode){
        CGFloat w=self.bounds.size.width; CGPoint ma=CGPointMake(w-a.x,a.y),mb=CGPointMake(w-b.x,b.y); CGRect mr=CGRectMake(MIN(ma.x,mb.x),MIN(ma.y,mb.y),fabsf(mb.x-ma.x),fabsf(mb.y-ma.y));
        if(_shapeType==KidsShapeLine){CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,ma.x,ma.y);CGContextAddLineToPoint(ctx,mb.x,mb.y);CGContextStrokePath(ctx);}
        else if(_shapeType==KidsShapeRectangle) CGContextStrokeRect(ctx,mr); else if(_shapeType==KidsShapeEllipse) CGContextStrokeEllipseInRect(ctx,mr);
    }
    UIImage *n=UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext(); [_image release]; _image=[n retain]; [self setNeedsDisplay]; [self notifyCanvasChanged];
}


- (BOOL)hasActiveFreehandTouch
{
    return (_touchA!=nil || _touchB!=nil);
}

- (void)assignFreehandTouch:(UITouch *)touch point:(CGPoint)p
{
    if(_touchA==nil){ _touchA=touch; _lastPointA=p; }
    else if(_touchB==nil){ _touchB=touch; _lastPointB=p; }
}

- (void)removeFreehandTouch:(UITouch *)touch
{
    if(touch==_touchA) _touchA=nil;
    if(touch==_touchB) _touchB=nil;
}

- (void)renderFreehandTouches:(NSSet *)touches drawDots:(BOOL)drawDots
{
    [self ensureImage];
    [self applyBrushStyle];
    UIGraphicsBeginImageContext(self.bounds.size);
    [_image drawInRect:self.bounds];
    CGContextRef ctx=UIGraphicsGetCurrentContext();

    for(UITouch *touch in touches){
        CGPoint p=[touch locationInView:self];
        if(touch==_touchA){
            CGPoint from=drawDots?p:_lastPointA;
            CGFloat dx=p.x-from.x, dy=p.y-from.y;
            if(drawDots || dx*dx+dy*dy>=1.0f){
                [self drawSegmentFrom:from to:p context:ctx touch:touch];
                _lastPointA=p;
            }
        } else if(touch==_touchB){
            CGPoint from=drawDots?p:_lastPointB;
            CGFloat dx=p.x-from.x, dy=p.y-from.y;
            if(drawDots || dx*dx+dy*dy>=1.0f){
                [self drawSegmentFrom:from to:p context:ctx touch:touch];
                _lastPointB=p;
            }
        }
    }

    UIImage *n=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_image release]; _image=[n retain];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *first=[touches anyObject];
    CGPoint firstPoint=[first locationInView:self];

    /* Dolgu, damga ve şekil tek dokunuşlu araçlardır. Çift kalem serbest çizimde aktiftir. */
    if(_bucketMode){ [self floodFillAt:firstPoint]; [self notifyCanvasChanged]; return; }
    if(_stampType!=KidsStampNone){ [self placeStampAt:firstPoint]; [self notifyCanvasChanged]; return; }
    if(_shapeType!=KidsShapeNone){
        _shapeStartPoint=firstPoint; _drawing=YES; [self pushUndoSnapshot]; return;
    }

    BOOL hadTouch=[self hasActiveFreehandTouch];
    if(!hadTouch) [self pushUndoSnapshot];

    for(UITouch *touch in touches){
        if(_touchA!=nil && _touchB!=nil) break;
        CGPoint p=[touch locationInView:self];
        [self assignFreehandTouch:touch point:p];
    }
    [self renderFreehandTouches:touches drawDots:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_shapeType!=KidsShapeNone) return;
    if(![self hasActiveFreehandTouch]) return;
    [self renderFreehandTouches:touches drawDots:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_drawing && _shapeType!=KidsShapeNone){
        UITouch *t=[touches anyObject];
        CGPoint p=[t locationInView:self];
        [self drawShapeFrom:_shapeStartPoint to:p];
        _drawing=NO;
        return;
    }

    for(UITouch *touch in touches) [self removeFreehandTouch:touch];
    if(![self hasActiveFreehandTouch]) [self notifyCanvasChanged];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) [self removeFreehandTouch:touch];
    _drawing=NO;
    if(![self hasActiveFreehandTouch]) [self notifyCanvasChanged];
}

- (BOOL)canUndo { return [_undoStack count]>0; }
- (BOOL)canRedo { return [_redoStack count]>0; }
- (void)undo
{
    if(![self canUndo]) return; [self ensureImage]; [_redoStack addObject:_image]; [self trimHistory:_redoStack];
    UIImage *prev=[[_undoStack lastObject] retain]; [_undoStack removeLastObject]; [_image release]; _image=prev; [self setNeedsDisplay]; [self notifyCanvasChanged];
}
- (void)redo
{
    if(![self canRedo]) return; [self ensureImage]; [_undoStack addObject:_image]; [self trimHistory:_undoStack];
    UIImage *next=[[_redoStack lastObject] retain]; [_redoStack removeLastObject]; [_image release]; _image=next; [self setNeedsDisplay]; [self notifyCanvasChanged];
}

- (void)clearCanvas { [self clearCanvasWithColor:self.canvasColor]; }
- (void)clearCanvasWithColor:(UIColor *)color
{
    [self pushUndoSnapshot]; self.canvasColor=color;
    UIGraphicsBeginImageContext(self.bounds.size); [color setFill]; UIRectFill(self.bounds); UIImage *n=UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext();
    [_image release]; _image=[n retain]; [self setNeedsDisplay]; [self notifyCanvasChanged];
}

- (void)templateStrokeSetup:(CGContextRef)ctx
{
    CGContextSetStrokeColorWithColor(ctx,[UIColor colorWithWhite:0.18f alpha:1].CGColor); CGContextSetLineWidth(ctx,5); CGContextSetLineCap(ctx,kCGLineCapRound); CGContextSetLineJoin(ctx,kCGLineJoinRound);
}

- (void)showColoringTemplate:(NSInteger)t
{
    [self pushUndoSnapshot]; self.canvasColor=[UIColor whiteColor];
    UIGraphicsBeginImageContext(self.bounds.size); [[UIColor whiteColor] setFill]; UIRectFill(self.bounds); CGContextRef ctx=UIGraphicsGetCurrentContext(); [self templateStrokeSetup:ctx];
    CGFloat w=self.bounds.size.width,h=self.bounds.size.height,cx=w*0.5f,cy=h*0.5f; int i;
    if(t==0){ CGPoint c=CGPointMake(cx,cy-20); for(i=0;i<8;i++){CGFloat a=i*M_PI/4.0f,px=c.x+cosf(a)*90,py=c.y+sinf(a)*90; CGContextStrokeEllipseInRect(ctx,CGRectMake(px-50,py-36,100,72));} CGContextStrokeEllipseInRect(ctx,CGRectMake(c.x-50,c.y-50,100,100)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,c.x,c.y+50);CGContextAddLineToPoint(ctx,c.x,h-45);CGContextStrokePath(ctx); }
    else if(t==1){ CGFloat x=w*.28f,y=h*.34f,ww=w*.44f,hh=h*.40f; CGContextStrokeRect(ctx,CGRectMake(x,y,ww,hh)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,x-25,y);CGContextAddLineToPoint(ctx,cx,y-145);CGContextAddLineToPoint(ctx,x+ww+25,y);CGContextStrokePath(ctx); CGContextStrokeRect(ctx,CGRectMake(cx-35,y+hh*.48f,70,hh*.52f)); CGContextStrokeRect(ctx,CGRectMake(x+50,y+65,85,75));CGContextStrokeRect(ctx,CGRectMake(x+ww-135,y+65,85,75)); }
    else if(t==2){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-180,cy-100,360,200)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-180,cy);CGContextAddLineToPoint(ctx,cx-300,cy-110);CGContextAddLineToPoint(ctx,cx-300,cy+110);CGContextClosePath(ctx);CGContextStrokePath(ctx); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx+105,cy-32,15,15)); }
    else if(t==3){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-25,cy-120,50,240)); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-190,cy-115,170,150)); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx+20,cy-115,170,150)); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-165,cy+15,145,125)); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx+20,cy+15,145,125)); }
    else if(t==4){ CGContextStrokeRect(ctx,CGRectMake(cx-220,cy-40,440,120)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-125,cy-40);CGContextAddLineToPoint(ctx,cx-60,cy-120);CGContextAddLineToPoint(ctx,cx+100,cy-120);CGContextAddLineToPoint(ctx,cx+165,cy-40);CGContextStrokePath(ctx); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-150,cy+55,70,70));CGContextStrokeEllipseInRect(ctx,CGRectMake(cx+80,cy+55,70,70)); }
    else if(t==5){ CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx,cy-180);CGContextAddCurveToPoint(ctx,cx+105,cy-100,cx+105,cy+95,cx,cy+165);CGContextAddCurveToPoint(ctx,cx-105,cy+95,cx-105,cy-100,cx,cy-180);CGContextStrokePath(ctx); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-35,cy-80,70,70)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-60,cy+120);CGContextAddLineToPoint(ctx,cx-135,cy+190);CGContextAddLineToPoint(ctx,cx-65,cy+15);CGContextStrokePath(ctx);CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+60,cy+120);CGContextAddLineToPoint(ctx,cx+135,cy+190);CGContextAddLineToPoint(ctx,cx+65,cy+15);CGContextStrokePath(ctx); }
    else if(t==6){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-130,cy-115,260,230)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-105,cy-80);CGContextAddLineToPoint(ctx,cx-155,cy-175);CGContextAddLineToPoint(ctx,cx-55,cy-125);CGContextStrokePath(ctx); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+105,cy-80);CGContextAddLineToPoint(ctx,cx+155,cy-175);CGContextAddLineToPoint(ctx,cx+55,cy-125);CGContextStrokePath(ctx); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-65,cy-25,20,20));CGContextStrokeEllipseInRect(ctx,CGRectMake(cx+45,cy-25,20,20)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx,cy+20);CGContextAddLineToPoint(ctx,cx-20,cy+45);CGContextAddLineToPoint(ctx,cx+20,cy+45);CGContextClosePath(ctx);CGContextStrokePath(ctx); }
    else if(t==7){ CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx,cy+180);CGContextAddLineToPoint(ctx,cx,cy-30);CGContextStrokePath(ctx); for(i=0;i<5;i++){CGFloat a=i*1.2f;CGFloat bx=cx+cosf(a)*90,by=cy-80+sinf(a)*70;CGContextStrokeEllipseInRect(ctx,CGRectMake(bx-80,by-60,160,120));} }
    else if(t==8){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-90,cy-145,180,180)); for(i=0;i<12;i++){CGFloat a=i*M_PI/6.0f;CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+cosf(a)*110,cy-55+sinf(a)*110);CGContextAddLineToPoint(ctx,cx+cosf(a)*155,cy-55+sinf(a)*155);CGContextStrokePath(ctx);} CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,40,h-120);CGContextAddCurveToPoint(ctx,w*.28,h-220,w*.40,h-60,w*.55,h-130);CGContextAddCurveToPoint(ctx,w*.72,h-210,w*.82,h-85,w-40,h-145);CGContextStrokePath(ctx); }
    else if(t==9){ CGContextStrokeRect(ctx,CGRectMake(cx-125,cy-135,250,240)); CGContextStrokeRect(ctx,CGRectMake(cx-75,cy-205,150,70)); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-65,cy-75,30,30));CGContextStrokeEllipseInRect(ctx,CGRectMake(cx+35,cy-75,30,30)); CGContextStrokeRect(ctx,CGRectMake(cx-65,cy+20,130,55)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-125,cy-70);CGContextAddLineToPoint(ctx,cx-220,cy);CGContextStrokePath(ctx);CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+125,cy-70);CGContextAddLineToPoint(ctx,cx+220,cy);CGContextStrokePath(ctx); }
    else if(t==10){ CGContextStrokeRect(ctx,CGRectMake(cx-190,cy-30,300,100)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+110,cy-30);CGContextAddLineToPoint(ctx,cx+210,cy+20);CGContextAddLineToPoint(ctx,cx+110,cy+70);CGContextClosePath(ctx);CGContextStrokePath(ctx); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-120,cy-30);CGContextAddLineToPoint(ctx,cx-70,cy-120);CGContextAddLineToPoint(ctx,cx-20,cy-30);CGContextStrokePath(ctx); }
    else if(t==11){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-100,cy-160,200,190)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-100,cy+20);CGContextAddLineToPoint(ctx,cx+100,cy+20);CGContextAddLineToPoint(ctx,cx,cy+190);CGContextClosePath(ctx);CGContextStrokePath(ctx); }
    else if(t==12){ CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx,cy-170);CGContextAddLineToPoint(ctx,cx-140,cy+20);CGContextAddLineToPoint(ctx,cx,cy+150);CGContextAddLineToPoint(ctx,cx+140,cy+20);CGContextClosePath(ctx);CGContextStrokePath(ctx); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx,cy+150);CGContextAddLineToPoint(ctx,cx,cy+210);CGContextStrokePath(ctx); }
    else if(t==13){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-145,cy-120,290,220)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-120,cy-80);CGContextAddLineToPoint(ctx,cx-30,cy-190);CGContextAddLineToPoint(ctx,cx+20,cy-100);CGContextAddLineToPoint(ctx,cx+105,cy-190);CGContextAddLineToPoint(ctx,cx+120,cy-70);CGContextStrokePath(ctx); }
    else if(t==14){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-170,cy-90,340,190)); CGContextStrokeEllipseInRect(ctx,CGRectMake(cx+90,cy-150,100,100)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx-140,cy+80);CGContextAddLineToPoint(ctx,cx-160,cy+160);CGContextStrokePath(ctx);CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+110,cy+80);CGContextAddLineToPoint(ctx,cx+130,cy+160);CGContextStrokePath(ctx); }
    else if(t==15){ for(i=0;i<3;i++){CGFloat xx=cx-220+i*170;CGContextStrokeRect(ctx,CGRectMake(xx,cy-60,150,100));CGContextStrokeEllipseInRect(ctx,CGRectMake(xx+15,cy+25,45,45));CGContextStrokeEllipseInRect(ctx,CGRectMake(xx+90,cy+25,45,45));} }
    else if(t==16){ CGContextBeginPath(ctx);CGContextAddArc(ctx,cx,cy,170,(CGFloat)M_PI,(CGFloat)M_PI*2,0);CGContextStrokePath(ctx); for(i=-3;i<=3;i++){CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+i*45,cy);CGContextAddLineToPoint(ctx,cx+i*38,cy+190);CGContextStrokePath(ctx);} }
    else if(t==17){ CGContextStrokeRect(ctx,CGRectMake(cx-160,cy-100,320,220)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx,cy-100);CGContextAddLineToPoint(ctx,cx,cy+120);CGContextMoveToPoint(ctx,cx-160,cy);CGContextAddLineToPoint(ctx,cx+160,cy);CGContextStrokePath(ctx); }
    else if(t==18){ CGContextStrokeEllipseInRect(ctx,CGRectMake(cx-120,cy-100,240,180)); CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx+105,cy-45);CGContextAddLineToPoint(ctx,cx+190,cy-120);CGContextMoveToPoint(ctx,cx+105,cy+10);CGContextAddLineToPoint(ctx,cx+195,cy+85);CGContextStrokePath(ctx); }
    else { CGContextBeginPath(ctx);CGContextMoveToPoint(ctx,cx,cy+170);CGContextAddCurveToPoint(ctx,cx-260,cy,cx-170,cy-180,cx,cy-50);CGContextAddCurveToPoint(ctx,cx+170,cy-180,cx+260,cy,cx,cy+170);CGContextClosePath(ctx);CGContextStrokePath(ctx); }
    UIImage *n=UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext(); [_image release]; _image=[n retain]; [self setNeedsDisplay]; [self notifyCanvasChanged];
}

- (void)addText:(NSString *)text
{
    if(!text || [text length]==0) return; [self ensureImage]; [self pushUndoSnapshot];
    UIGraphicsBeginImageContext(self.bounds.size); [_image drawInRect:self.bounds];
    CGContextRef ctx=UIGraphicsGetCurrentContext(); CGContextSetFillColorWithColor(ctx,self.strokeColor.CGColor);
    UIFont *font=[UIFont boldSystemFontOfSize:42.0f]; CGSize sz=[text sizeWithFont:font constrainedToSize:CGSizeMake(self.bounds.size.width-40,120) lineBreakMode:UILineBreakModeTailTruncation];
    [text drawInRect:CGRectMake((self.bounds.size.width-sz.width)/2.0f,(self.bounds.size.height-sz.height)/2.0f,sz.width,sz.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
    UIImage *n=UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext(); [_image release]; _image=[n retain]; [self setNeedsDisplay]; [self notifyCanvasChanged];
}

- (UIImage *)renderedImage { [self ensureImage]; return _image; }
- (void)setRenderedImage:(UIImage *)image
{
    if(!image) return; [_image release]; _image=[image retain]; [_undoStack removeAllObjects]; [_redoStack removeAllObjects]; [self setNeedsDisplay];
}

- (void)dealloc
{
    [_image release]; [_strokeColor release]; [_canvasColor release]; [_undoStack release]; [_redoStack release]; [super dealloc];
}
@end
