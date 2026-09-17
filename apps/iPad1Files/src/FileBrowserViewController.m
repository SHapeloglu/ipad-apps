#import <objc/runtime.h>
#import "FileBrowserViewController.h"
#import "IP1FileManager.h"
#import "IP1FileItem.h"
#import "IP1FileTypeDetector.h"
#import "IP1AppLauncher.h"
#import "FileInfoViewController.h"
#import "TextViewerViewController.h"
#import "ImageViewerViewController.h"

@implementation FileBrowserViewController

- (id)initWithPath:(NSString *)path {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _path = [path copy];
        _showHidden = NO;
        self.title = ([[_path lastPathComponent] length] > 0) ? [_path lastPathComponent] : @"Files";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Bu klasörde ara";
    self.tableView.tableHeaderView = _searchBar;

    UIBarButtonItem *add =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self
                                                      action:@selector(addFolder)] autorelease];

    UIBarButtonItem *actions =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(showFolderActions)] autorelease];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:add, actions, nil];

    [self reloadFiles];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadFiles];
}

- (NSArray *)displayItems {
    return ([_searchBar.text length] > 0) ? _filteredItems : _items;
}

- (void)reloadFiles {
    NSError *error = nil;
    NSArray *newItems =
        [[IP1FileManager sharedManager] contentsOfDirectory:_path showHidden:_showHidden error:&error];

    [_items release];
    _items = [newItems retain];

    [self filterWithText:_searchBar.text];
    [self.tableView reloadData];

    if (!_items && error) {
        UIAlertView *alert =
            [[[UIAlertView alloc] initWithTitle:@"Klasör açılamadı"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Tamam"
                              otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

- (void)filterWithText:(NSString *)text {
    [_filteredItems release];
    _filteredItems = nil;

    if ([text length] == 0) return;

    NSMutableArray *matches = [NSMutableArray array];
    for (IP1FileItem *item in _items) {
        if ([item.name rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [matches addObject:item];
        }
    }
    _filteredItems = [matches copy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    (void)section;
    return [[self displayItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:identifier] autorelease];
    }

    IP1FileItem *item = [[self displayItems] objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [item formattedSize];
    cell.accessoryType = item.isDirectory ? UITableViewCellAccessoryDisclosureIndicator
                                          : UITableViewCellAccessoryDetailDisclosureButton;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    IP1FileItem *item = [[self displayItems] objectAtIndex:indexPath.row];

    if (item.isDirectory) {
        FileBrowserViewController *browser =
            [[[FileBrowserViewController alloc] initWithPath:item.path] autorelease];
        [self.navigationController pushViewController:browser animated:YES];
        return;
    }

    IP1FileType type = [IP1FileTypeDetector typeForPath:item.path];

    if (type == IP1FileTypeText) {
        TextViewerViewController *viewer =
            [[[TextViewerViewController alloc] initWithPath:item.path] autorelease];
        [self.navigationController pushViewController:viewer animated:YES];
        return;
    }

    if (type == IP1FileTypeImage) {
        ImageViewerViewController *viewer =
            [[[ImageViewerViewController alloc] initWithPath:item.path] autorelease];
        [self.navigationController pushViewController:viewer animated:YES];
        return;
    }

    if (type == IP1FileTypePDF && [IP1AppLauncher canOpenPDFReader]) {
        [IP1AppLauncher openPDFReaderWithPath:item.path];
        return;
    }

    [self showActionsForItem:item];
}

- (void)tableView:(UITableView *)tableView
 accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    IP1FileItem *item = [[self displayItems] objectAtIndex:indexPath.row];
    [self showActionsForItem:item];
}

- (void)showActionsForItem:(IP1FileItem *)item {
    UIActionSheet *sheet =
        [[[UIActionSheet alloc] initWithTitle:item.name
                                     delegate:self
                            cancelButtonTitle:nil
                       destructiveButtonTitle:nil
                            otherButtonTitles:nil] autorelease];

    [sheet addButtonWithTitle:@"Bilgi"];
    [sheet addButtonWithTitle:@"Yeniden Adlandır"];

    if (![item.path isEqualToString:@"/var/mobile/Media/iPad1Files"]) {
        [sheet addButtonWithTitle:@"Sil"];
    }

    [sheet addButtonWithTitle:@"Vazgeç"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;

    objc_setAssociatedObject(sheet, "IP1FileItem", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    IP1FileItem *item = objc_getAssociatedObject(actionSheet, "IP1FileItem");
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([title isEqualToString:@"Bilgi"]) {
        FileInfoViewController *info =
            [[[FileInfoViewController alloc] initWithPath:item.path] autorelease];
        [self.navigationController pushViewController:info animated:YES];
    } else if ([title isEqualToString:@"Yeniden Adlandır"]) {
        [self promptRename:item];
    } else if ([title isEqualToString:@"Sil"]) {
        [self confirmDelete:item];
    } else if ([title isEqualToString:@"Gizli Dosyaları Göster"] ||
               [title isEqualToString:@"Gizli Dosyaları Gizle"]) {
        _showHidden = !_showHidden;
        [self reloadFiles];
    } else if ([title isEqualToString:@"Yenile"]) {
        [self reloadFiles];
    }
}

- (void)addFolder {
    UIAlertView *alert =
        [[[UIAlertView alloc] initWithTitle:@"Yeni Klasör"
                                    message:@"Klasör adını yazın"
                                   delegate:(id<UIAlertViewDelegate>)self
                          cancelButtonTitle:@"Vazgeç"
                          otherButtonTitles:@"Oluştur", nil] autorelease];

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [alert show];
}

- (void)promptRename:(IP1FileItem *)item {
    UIAlertView *alert =
        [[[UIAlertView alloc] initWithTitle:@"Yeniden Adlandır"
                                    message:nil
                                   delegate:(id<UIAlertViewDelegate>)self
                          cancelButtonTitle:@"Vazgeç"
                          otherButtonTitles:@"Kaydet", nil] autorelease];

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setText:item.name];
    alert.tag = 101;
    objc_setAssociatedObject(alert, "IP1RenameItem", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alert show];
}

- (void)confirmDelete:(IP1FileItem *)item {
    UIAlertView *alert =
        [[[UIAlertView alloc] initWithTitle:@"Sil"
                                    message:[NSString stringWithFormat:@"%@ silinsin mi?", item.name]
                                   delegate:(id<UIAlertViewDelegate>)self
                          cancelButtonTitle:@"Vazgeç"
                          otherButtonTitles:@"Sil", nil] autorelease];

    alert.tag = 102;
    objc_setAssociatedObject(alert, "IP1DeleteItem", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) return;

    NSError *error = nil;
    BOOL success = NO;

    if (alertView.tag == 100) {
        NSString *name = [[alertView textFieldAtIndex:0] text];
        success = [[IP1FileManager sharedManager] createFolderNamed:name inDirectory:_path error:&error];
    } else if (alertView.tag == 101) {
        IP1FileItem *item = objc_getAssociatedObject(alertView, "IP1RenameItem");
        NSString *name = [[alertView textFieldAtIndex:0] text];
        success = [[IP1FileManager sharedManager] renameItemAtPath:item.path toName:name error:&error];
    } else if (alertView.tag == 102) {
        IP1FileItem *item = objc_getAssociatedObject(alertView, "IP1DeleteItem");
        success = [[IP1FileManager sharedManager] deleteItemAtPath:item.path error:&error];
    }

    if (!success && error) {
        UIAlertView *errorAlert =
            [[[UIAlertView alloc] initWithTitle:@"İşlem başarısız"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Tamam"
                              otherButtonTitles:nil] autorelease];
        [errorAlert show];
    }

    [self reloadFiles];
}

- (void)showFolderActions {
    UIActionSheet *sheet =
        [[[UIActionSheet alloc] initWithTitle:_path
                                     delegate:(id<UIActionSheetDelegate>)self
                            cancelButtonTitle:nil
                       destructiveButtonTitle:nil
                            otherButtonTitles:nil] autorelease];

    [sheet addButtonWithTitle:_showHidden ? @"Gizli Dosyaları Gizle" : @"Gizli Dosyaları Göster"];
    [sheet addButtonWithTitle:@"Yenile"];
    [sheet addButtonWithTitle:@"Vazgeç"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:self.view];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    (void)searchBar;
    [self filterWithText:searchText];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)dealloc {
    _searchBar.delegate = nil;
    [_path release];
    [_items release];
    [_filteredItems release];
    [_searchBar release];
    [super dealloc];
}

@end
