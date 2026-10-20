#import <UIKit/UIKit.h>
#import "FolderPickerViewController.h"

@interface FileBrowserViewController : UITableViewController
    <UISearchBarDelegate, UIActionSheetDelegate, UIAlertViewDelegate, FolderPickerViewControllerDelegate> {
    NSString *_path;
    NSArray *_items;
    NSArray *_filteredItems;
    UISearchBar *_searchBar;
    BOOL _showHidden;
    BOOL _selectionMode;
    NSInteger _sortMode;
    NSMutableArray *_selectedPaths;
    NSString *_pendingOperation;
    NSString *_pendingDestination;
}

- (id)initWithPath:(NSString *)path;

@end
