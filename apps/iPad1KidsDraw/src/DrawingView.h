#import <UIKit/UIKit.h>

typedef enum {
    KidsBrushNormal = 0,
    KidsBrushPastel = 1,
    KidsBrushNeon = 2,
    KidsBrushRainbow = 3
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
    CGPoint _lastPoint;
    CGPoint _shapeStartPoint;
    BOOL _drawing;
    BOOL _bucketMode;
    BOOL _mirrorMode;
    NSMutableArray *_undoStack;
    NSMutableArray *_redoStack;
    KidsBrushStyle _brushStyle;
    KidsStampType _stampType;
    KidsShapeType _shapeType;
}

@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *canvasColor;
@property (nonatomic, assign) CGFloat lineWidth;
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

@end
