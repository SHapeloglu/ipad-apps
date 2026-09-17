#import <UIKit/UIKit.h>
@class VNCClient;

typedef enum {
    VNCInputModeDirect = 0,
    VNCInputModeTrackpad = 1
} VNCInputMode;

@interface VNCView : UIView {
    UIImage *_image;
    VNCClient *_client;
    CGPoint _lastPoint;
    CGPoint _lastTouchViewPoint;
    CGFloat _zoomScale;
    CGFloat _pinchStartScale;
    CGFloat _scrollAccumulator;
    CGFloat _pointerSensitivity;
    VNCInputMode _inputMode;
    BOOL _trackpadMoved;
}
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) VNCClient *client;
@property (nonatomic, assign) CGFloat pointerSensitivity;
@property (nonatomic, assign) VNCInputMode inputMode;
- (void)updateImage:(UIImage *)image;
@end
