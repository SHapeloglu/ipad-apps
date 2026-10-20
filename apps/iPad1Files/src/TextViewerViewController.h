#import <UIKit/UIKit.h>

@interface TextViewerViewController : UIViewController {
    NSString *_path;
    UITextView *_textView;
}

- (id)initWithPath:(NSString *)path;

@end
