#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ThumbnailViewController.h"
@class PDFPageView,AnnotationOverlayView;
@interface PDFReaderViewController:UIViewController<UIScrollViewDelegate,UIActionSheetDelegate,ThumbnailViewControllerDelegate,UIAlertViewDelegate>{NSString*_pdfPath;CGPDFDocumentRef _document;NSUInteger _currentPage,_pageCount;UIScrollView*_scrollView;PDFPageView*_pageView;AnnotationOverlayView*_overlay;UIToolbar*_toolbar;UILabel*_pageLabel;UIBarButtonItem*_previousButton,*_nextButton,*_bookmarkButton;BOOL _chromeHidden;}
- (id)initWithPDFPath:(NSString*)path;
@end
