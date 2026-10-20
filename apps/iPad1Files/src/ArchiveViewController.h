#import <UIKit/UIKit.h>
#import "FolderPickerViewController.h"

@interface ArchiveViewController : UITableViewController
    <UIActionSheetDelegate, FolderPickerViewControllerDelegate> {
    NSString *_zipPath;
    NSArray *_entries;
}

- (id)initWithZipPath:(NSString *)zipPath;

@end
