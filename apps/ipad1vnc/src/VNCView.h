#import <UIKit/UIKit.h>
@class VNCClient;

@interface VNCView : UIView {
    UIImage *_image;
    VNCClient *_client;
    CGPoint _lastPoint;
    CGFloat _zoomScale;
    CGFloat _pinchStartScale;
    CGFloat _scrollAccumulator;
    CGFloat _pointerSensitivity;
}
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) VNCClient *client;
@property (nonatomic, assign) CGFloat pointerSensitivity;
- (void)updateImage:(UIImage *)image;
@end
