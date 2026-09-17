#import <UIKit/UIKit.h>

@interface DrawingView : UIView
{
    UIImage *_image;
    UIColor *_strokeColor;
    CGFloat _lineWidth;
    CGPoint _lastPoint;
    BOOL _drawing;
}

@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;

- (void)clearCanvas;
- (UIImage *)renderedImage;

@end
