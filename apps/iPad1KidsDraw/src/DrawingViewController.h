#import <UIKit/UIKit.h>
@class DrawingView;

@interface DrawingViewController : UIViewController <UIAlertViewDelegate>
{
    DrawingView *_drawingView;
    UIView *_topToolbar;
    UIView *_bottomToolbar;
    UIView *_galleryOverlay;
    UIColor *_lastPaintColor;
    NSArray *_galleryFiles;
    NSTimer *_autosaveTimer;

    NSMutableArray *_replayFrames;
    NSTimer *_replayTimer;
    NSInteger _replayIndex;
    UIImageView *_replayOverlay;

    UILabel *_starLabel;
    NSUInteger _stars;
    BOOL _soundEnabled;
    UIView *_rewardOverlay;
    UILabel *_rewardTitle;

    NSInteger _lineSizeIndex;
    NSInteger _stampSizeIndex;
    NSInteger _sprayDensityIndex;
    NSInteger _spraySizeIndex;
    NSInteger _neonStrengthIndex;
    NSInteger _opacityIndex;
    NSInteger _eraserSizeIndex;

    UIColor *_secondaryPaintColor;
    NSInteger _secondaryBrushIndex;

    UIPinchGestureRecognizer *_stampPinch;
    NSInteger _smudgeStrengthIndex;
    NSInteger _mixerStrengthIndex;
    NSInteger _stampRotationIndex;
    UIView *_brushPreview;
    UILabel *_brushPreviewLabel;
    NSInteger _smoothingIndex;
    NSMutableSet *_favoriteDrawings;
    NSMutableArray *_favoriteBrushes;
    NSMutableArray *_recentBrushes;
    NSInteger _galleryFilter;
}
- (void)openExternalImageAtPath:(NSString *)path;
@end
