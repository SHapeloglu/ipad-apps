#import <UIKit/UIKit.h>

typedef enum {
    KidsBrushNormal = 0,
    KidsBrushPencil,
    KidsBrushMarker,
    KidsBrushPastel,
    KidsBrushNeon,
    KidsBrushRainbow,
    KidsBrushSpray,
    KidsBrushChalk,
    KidsBrushSmudge,
    KidsBrushMixer,
    KidsBrushWatercolor
} KidsBrushStyle;

typedef enum {
    KidsStampNone = 0,
    KidsStampStar,
    KidsStampHeart,
    KidsStampSmile,
    KidsStampCircle,
    KidsStampSquare,
    KidsStampTriangle,
    KidsStampFlower,
    KidsStampSun,
    KidsStampCloud,
    KidsStampCar,
    KidsStampFish,
    KidsStampButterfly,
    KidsStampMoon,
    KidsStampDiamond,
    KidsStampBalloon,
    KidsStampApple,
    KidsStampTree,
    KidsStampHouse,
    KidsStampRocket,
    KidsStampCat,
    KidsStampRobot,
    KidsStampCrown,
    KidsStampMusic,
    KidsStampLightning
} KidsStampType;

typedef enum {
    KidsShapeNone = 0,
    KidsShapeLine,
    KidsShapeRectangle,
    KidsShapeEllipse,
    KidsShapeTriangle
} KidsShapeType;

@interface DrawingView : UIView
{
    UIImage *_image;
    UIColor *_strokeColor;
    UIColor *_canvasColor;
    CGFloat _lineWidth;
    CGFloat _strokeAlpha;
    CGFloat _stampScale;
    CGFloat _sprayDensity;
    CGFloat _spraySize;
    CGFloat _neonStrength;
    CGFloat _globalOpacity;
    CGFloat _eraserWidth;

    UIColor *_secondaryStrokeColor;
    KidsBrushStyle _secondaryBrushStyle;
    CGFloat _smudgeStrength;
    CGFloat _mixerStrength;
    CGFloat _stampRotation;
    BOOL _eyedropperMode;
    BOOL _smoothingEnabled;
    CGFloat _smoothingStrength;
    CGPoint _smoothPointA;
    CGPoint _smoothPointB;

    CGPoint _lastPoint;
    CGPoint _shapeStartPoint;
    BOOL _drawing;
    BOOL _bucketMode;
    BOOL _mirrorMode;

    /* iPad 1 için en fazla iki eşzamanlı serbest çizim dokunuşu. */
    UITouch *_touchA;
    UITouch *_touchB;
    CGPoint _lastPointA;
    CGPoint _lastPointB;

    NSMutableArray *_undoStack;
    NSMutableArray *_redoStack;

    KidsBrushStyle _brushStyle;
    KidsStampType _stampType;
    KidsShapeType _shapeType;
}

@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *canvasColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat stampScale;
@property (nonatomic, assign) CGFloat sprayDensity;
@property (nonatomic, assign) CGFloat spraySize;
@property (nonatomic, assign) CGFloat neonStrength;
@property (nonatomic, assign) CGFloat globalOpacity;
@property (nonatomic, assign) CGFloat eraserWidth;
@property (nonatomic, retain) UIColor *secondaryStrokeColor;
@property (nonatomic, assign) KidsBrushStyle secondaryBrushStyle;
@property (nonatomic, assign) CGFloat smudgeStrength;
@property (nonatomic, assign) CGFloat mixerStrength;
@property (nonatomic, assign) CGFloat stampRotation;
@property (nonatomic, assign) BOOL eyedropperMode;
@property (nonatomic, assign) BOOL smoothingEnabled;
@property (nonatomic, assign) CGFloat smoothingStrength;
@property (nonatomic, assign) KidsBrushStyle brushStyle;
@property (nonatomic, assign) KidsStampType stampType;
@property (nonatomic, assign) KidsShapeType shapeType;
@property (nonatomic, assign) BOOL bucketMode;
@property (nonatomic, assign) BOOL mirrorMode;

- (void)clearCanvas;
- (void)clearCanvasWithColor:(UIColor *)color;
- (void)undo;
- (void)redo;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (void)showColoringTemplate:(NSInteger)templateIndex;
- (void)addText:(NSString *)text;
- (UIImage *)renderedImage;
- (void)setRenderedImage:(UIImage *)image;
- (UIColor *)colorAtPoint:(CGPoint)point;

@end
