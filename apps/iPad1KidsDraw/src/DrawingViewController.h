#import <UIKit/UIKit.h>

@class DrawingView;

@interface DrawingViewController : UIViewController
{
    DrawingView *_drawingView;
    UIView *_toolbar;
    UIColor *_lastPaintColor;
}

@end
