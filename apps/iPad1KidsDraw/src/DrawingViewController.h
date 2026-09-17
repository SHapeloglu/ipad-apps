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
}
- (void)openExternalImageAtPath:(NSString *)path;
@end
