#import <UIKit/UIKit.h>
@class VNCClient;

@interface VNCView : UIView {
    UIImage *_image;
    VNCClient *_client;
    CGPoint _lastPoint;
}
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) VNCClient *client;
- (void)updateImage:(UIImage *)image;
@end
