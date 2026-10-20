#import <UIKit/UIKit.h>

@interface ImageViewerViewController : UIViewController <UIScrollViewDelegate> {
    NSString *_path;
    UIScrollView *_scrollView;
    UIImageView *_imageView;
}

- (id)initWithPath:(NSString *)path;

@end
