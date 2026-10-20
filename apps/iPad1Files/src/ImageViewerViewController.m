#import "ImageViewerViewController.h"

@implementation ImageViewerViewController

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = [path copy];
        self.title = [path lastPathComponent];
    }
    return self;
}

- (void)loadView {
    UIView *view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    view.backgroundColor = [UIColor blackColor];

    _scrollView = [[UIScrollView alloc] initWithFrame:view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.minimumZoomScale = 0.25;
    _scrollView.maximumZoomScale = 4.0;
    _scrollView.delegate = self;
    [view addSubview:_scrollView];

    UIImage *image = [UIImage imageWithContentsOfFile:_path];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.frame = _scrollView.bounds;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_scrollView addSubview:_imageView];

    self.view = view;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    (void)scrollView;
    return _imageView;
}

- (void)dealloc {
    _scrollView.delegate = nil;
    [_path release];
    [_imageView release];
    [_scrollView release];
    [super dealloc];
}

@end
