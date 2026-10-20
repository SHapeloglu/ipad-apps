#import <UIKit/UIKit.h>

@interface FileInfoViewController : UITableViewController {
    NSString *_path;
    NSArray *_rows;
}

- (id)initWithPath:(NSString *)path;

@end
