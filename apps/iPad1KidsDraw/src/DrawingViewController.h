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
    UIButton *_modeButton;
    NSUInteger _stars;
    BOOL _simpleMode;
}
- (void)openExternalImageAtPath:(NSString *)path;
@end
