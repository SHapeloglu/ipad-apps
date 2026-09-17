#import <UIKit/UIKit.h>

@interface FileBrowserViewController : UITableViewController
    <UISearchBarDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    NSString *_path;
    NSArray *_items;
    NSArray *_filteredItems;
    UISearchBar *_searchBar;
    BOOL _showHidden;
}

- (id)initWithPath:(NSString *)path;

@end
