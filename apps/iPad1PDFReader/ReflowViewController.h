#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@interface ReflowViewController : UIViewController {
    NSString *_pdfPath; UITextView *_textView; UISegmentedControl *_fontControl; CGPDFDocumentRef _document;
}
- (id)initWithPDFPath:(NSString *)path;
@end
