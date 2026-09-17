#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@protocol ThumbnailViewControllerDelegate <NSObject>
- (void)thumbnailControllerSelectedPage:(NSUInteger)p;
@end
@interface ThumbnailViewController : UITableViewController { NSString *_pdfPath; CGPDFDocumentRef _doc; NSUInteger _count; id<ThumbnailViewControllerDelegate> _delegate; }
@property(nonatomic,assign) id<ThumbnailViewControllerDelegate> delegate;
- (id)initWithPDFPath:(NSString*)path;
@end
