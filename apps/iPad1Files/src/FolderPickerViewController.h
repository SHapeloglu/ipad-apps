#import <UIKit/UIKit.h>

@protocol FolderPickerViewControllerDelegate;

@interface FolderPickerViewController : UITableViewController {
    NSString *_path;
    NSArray *_items;
    id<FolderPickerViewControllerDelegate> _delegate;
    NSString *_actionTitle;
}

@property(nonatomic, assign) id<FolderPickerViewControllerDelegate> delegate;
@property(nonatomic, copy) NSString *actionTitle;

- (id)initWithPath:(NSString *)path;

@end

@protocol FolderPickerViewControllerDelegate <NSObject>
- (void)folderPicker:(FolderPickerViewController *)picker didChoosePath:(NSString *)path;
@end
