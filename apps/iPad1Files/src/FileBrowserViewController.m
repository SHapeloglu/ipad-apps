#import <objc/runtime.h>
#import "FileBrowserViewController.h"
#import "IP1FileManager.h"
#import "IP1FileItem.h"
#import "IP1FileTypeDetector.h"
#import "IP1AppLauncher.h"
#import "IP1AppRegistry.h"
#import "IP1FavoritesManager.h"
#import "IP1DiskInfo.h"
#import "FavoritesViewController.h"
#import "FileInfoViewController.h"
#import "TextViewerViewController.h"
#import "ImageViewerViewController.h"
#import "ArchiveViewController.h"
#import "ArchiveManager.h"

@implementation FileBrowserViewController

- (id)initWithPath:(NSString *)path {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _path = [path copy];
        _showHidden = NO;
        _selectionMode = NO;
        _selectedPaths = [[NSMutableArray alloc] init];
        self.title = ([[_path lastPathComponent] length] > 0) ? [_path lastPathComponent] : @"Files";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGFloat width = self.tableView.bounds.size.width;

    UIView *header =
        [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 68)] autorelease];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UILabel *pathLabel =
        [[[UILabel alloc] initWithFrame:CGRectMake(10, 2, width - 20, 22)] autorelease];
    pathLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    pathLabel.font = [UIFont systemFontOfSize:11.0];
    pathLabel.textColor = [UIColor grayColor];
    pathLabel.backgroundColor = [UIColor clearColor];
    pathLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    pathLabel.text = [_path length] ? _path : @"/";
    [header addSubview:pathLabel];

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 24, width, 44)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Bu klasörde ara";
    [header addSubview:_searchBar];

    self.tableView.tableHeaderView = header;

    [self configureNavigation];
    [self reloadFiles];
    [self updateFooter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadFiles];
    [self updateFooter];
}

- (void)configureNavigation {
    if (_selectionMode) {
        UIBarButtonItem *cancel =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                          target:self
                                                          action:@selector(cancelSelection)] autorelease];
        self.navigationItem.leftBarButtonItem = cancel;

        UIBarButtonItem *done =
            [[[UIBarButtonItem alloc] initWithTitle:@"İşlem"
                                             style:UIBarButtonItemStyleDone
                                            target:self
                                            action:@selector(showSelectionActions)] autorelease];

        if (![[IP1FileManager sharedManager] isProtectedSystemDirectory:_path]) {
            UIBarButtonItem *selectAll =
                [[[UIBarButtonItem alloc] initWithTitle:@"Tümünü Seç"
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(selectAllItems)] autorelease];
            self.navigationItem.rightBarButtonItems =
                [NSArray arrayWithObjects:done, selectAll, nil];
        } else {
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:done];
        }
    } else {
        self.navigationItem.leftBarButtonItem = nil;

        UIBarButtonItem *add =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                          target:self
                                                          action:@selector(addFolder)] autorelease];

        UIBarButtonItem *select =
            [[[UIBarButtonItem alloc] initWithTitle:@"Seç"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(beginSelection)] autorelease];

        UIBarButtonItem *actions =
            [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                          target:self
                                                          action:@selector(showFolderActions)] autorelease];

        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:add, select, actions, nil];
    }
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

- (void)updateFooter {
    unsigned long long free = [IP1DiskInfo freeBytesAtPath:_path];
    unsigned long long total = [IP1DiskInfo totalBytesAtPath:_path];

    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 36)] autorelease];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12.0];
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor clearColor];
    if ([[IP1FileManager sharedManager] isProtectedSystemDirectory:_path]) {
        label.text = [NSString stringWithFormat:@"Korumalı sistem alanı • Boş: %@ / Toplam: %@",
                      [IP1DiskInfo formattedBytes:free],
                      [IP1DiskInfo formattedBytes:total]];
    } else {
        label.text = [NSString stringWithFormat:@"Boş: %@ / Toplam: %@",
                      [IP1DiskInfo formattedBytes:free],
                      [IP1DiskInfo formattedBytes:total]];
    }
    self.tableView.tableFooterView = label;
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
    (void)tableView; (void)section;
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

    if (_selectionMode) {
        cell.accessoryType = [_selectedPaths containsObject:item.path]
            ? UITableViewCellAccessoryCheckmark
            : UITableViewCellAccessoryNone;
    } else {
        cell.accessoryType = item.isDirectory
            ? UITableViewCellAccessoryDisclosureIndicator
            : UITableViewCellAccessoryDetailDisclosureButton;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IP1FileItem *item = [[self displayItems] objectAtIndex:indexPath.row];

    if (_selectionMode) {
        if ([_selectedPaths containsObject:item.path]) [_selectedPaths removeObject:item.path];
        else [_selectedPaths addObject:item.path];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        self.title = [NSString stringWithFormat:@"%lu seçili", (unsigned long)[_selectedPaths count]];
        return;
    }

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

    if (type == IP1FileTypeArchive &&
        [[item.path pathExtension] caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
        ArchiveViewController *archive =
            [[[ArchiveViewController alloc] initWithZipPath:item.path] autorelease];
        [self.navigationController pushViewController:archive animated:YES];
        return;
    }

    if ([IP1AppRegistry registrationForPath:item.path] &&
        [IP1AppLauncher canOpenRegisteredAppForPath:item.path]) {
        [IP1AppLauncher openRegisteredAppForPath:item.path];
        return;
    }

    [self showActionsForItem:item];
}

- (void)tableView:(UITableView *)tableView
 accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    if (_selectionMode) return;
    IP1FileItem *item = [[self displayItems] objectAtIndex:indexPath.row];
    [self showActionsForItem:item];
}

- (void)beginSelection {
    _selectionMode = YES;
    [_selectedPaths removeAllObjects];
    self.title = @"0 seçili";
    [self configureNavigation];
    [self.tableView reloadData];
}

- (void)cancelSelection {
    _selectionMode = NO;
    [_selectedPaths removeAllObjects];
    self.title = ([[_path lastPathComponent] length] > 0) ? [_path lastPathComponent] : @"Files";
    [self configureNavigation];
    [self.tableView reloadData];
}

- (void)selectAllItems {
    if ([[IP1FileManager sharedManager] isProtectedSystemDirectory:_path]) return;

    [_selectedPaths removeAllObjects];
    for (IP1FileItem *item in [self displayItems]) {
        [_selectedPaths addObject:item.path];
    }
    self.title = [NSString stringWithFormat:@"%lu seçili", (unsigned long)[_selectedPaths count]];
    [self.tableView reloadData];
}

- (void)showSelectionActions {
    if ([_selectedPaths count] == 0) return;

    UIActionSheet *sheet =
        [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%lu öğe", (unsigned long)[_selectedPaths count]]
                                     delegate:self
                            cancelButtonTitle:nil
                       destructiveButtonTitle:@"Sil"
                            otherButtonTitles:@"Kopyala", @"Taşı", @"ZIP Oluştur", nil] autorelease];
    [sheet addButtonWithTitle:@"Vazgeç"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    objc_setAssociatedObject(sheet, "IP1SelectionSheet", @"YES", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

- (void)presentDestinationPicker {
    FolderPickerViewController *picker =
        [[[FolderPickerViewController alloc] initWithPath:@"/var/mobile/Media/iPad1Files"] autorelease];
    picker.delegate = self;
    picker.actionTitle = [_pendingOperation isEqualToString:@"copy"] ? @"Buraya Kopyala" : @"Buraya Taşı";

    UINavigationController *nav =
        [[[UINavigationController alloc] initWithRootViewController:picker] autorelease];

    UIBarButtonItem *cancel =
        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(dismissPicker)] autorelease];
    picker.navigationItem.leftBarButtonItem = cancel;

    [self presentModalViewController:nav animated:YES];
}

- (void)startDestinationOperation:(NSString *)operation {
    [_pendingOperation release];
    _pendingOperation = [operation copy];

    if ([operation isEqualToString:@"move"] &&
        [[IP1FileManager sharedManager] isProtectedSystemDirectory:_path]) {
        UIAlertView *alert =
            [[[UIAlertView alloc] initWithTitle:@"Sistem Alanından Taşıma"
                                        message:@"Bu işlem seçilen sistem öğelerini mevcut konumlarından kaldırır. Devam etmek istediğinizden emin olun."
                                       delegate:self
                              cancelButtonTitle:@"Vazgeç"
                              otherButtonTitles:@"Devam", nil] autorelease];
        alert.tag = 201;
        [alert show];
        return;
    }

    [self presentDestinationPicker];
}

- (void)dismissPicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)pendingTransferHasCollisionAtPath:(NSString *)path {
    for (NSString *source in _selectedPaths) {
        if ([[IP1FileManager sharedManager] itemExistsAtDestinationForSource:source
                                                                   directory:path]) {
            return YES;
        }
    }
    return NO;
}

- (void)performPendingTransferToPath:(NSString *)path
                      conflictPolicy:(IP1FileConflictPolicy)policy {
    NSError *error = nil;
    BOOL ok = YES;

    for (NSString *source in _selectedPaths) {
        BOOL itemOK;
        if ([_pendingOperation isEqualToString:@"copy"]) {
            itemOK = [[IP1FileManager sharedManager] copyItemAtPath:source
                                                       toDirectory:path
                                                    conflictPolicy:policy
                                                             error:&error];
        } else {
            itemOK = [[IP1FileManager sharedManager] moveItemAtPath:source
                                                       toDirectory:path
                                                    conflictPolicy:policy
                                                             error:&error];
        }
        if (!itemOK) {
            ok = NO;
            break;
        }
    }

    [self dismissModalViewControllerAnimated:YES];

    if (!ok) {
        UIAlertView *alert =
            [[[UIAlertView alloc] initWithTitle:@"İşlem tamamlanamadı"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Tamam"
                              otherButtonTitles:nil] autorelease];
        [alert show];
    }

    [self cancelSelection];
    [self reloadFiles];
    [self updateFooter];
}

- (void)folderPicker:(FolderPickerViewController *)picker didChoosePath:(NSString *)path {
    (void)picker;

    [_pendingDestination release];
    _pendingDestination = [path copy];

    if (![self pendingTransferHasCollisionAtPath:path]) {
        [self performPendingTransferToPath:path conflictPolicy:IP1FileConflictPolicyUnique];
        return;
    }

    BOOL protectedDestination =
        [[IP1FileManager sharedManager] isProtectedSystemDirectory:path];

    UIAlertView *alert;
    if (protectedDestination) {
        alert = [[[UIAlertView alloc] initWithTitle:@"Korumalı Sistem Alanı"
                                           message:@"Aynı isimli öğe var. Sistem alanında üzerine yazma kapalıdır; yalnızca yeni adla oluşturabilirsiniz."
                                          delegate:self
                                 cancelButtonTitle:@"Vazgeç"
                                 otherButtonTitles:@"Yeni Adla Oluştur", nil] autorelease];
        alert.tag = 301;
    } else {
        alert = [[[UIAlertView alloc] initWithTitle:@"Aynı İsimli Öğe Var"
                                           message:@"Mevcut öğenin üzerine yazabilir veya (2), (3)… şeklinde yeni bir ad oluşturabilirsiniz."
                                          delegate:self
                                 cancelButtonTitle:@"Vazgeç"
                                 otherButtonTitles:@"Yeni Adla Oluştur", @"Üzerine Yaz", nil] autorelease];
        alert.tag = 300;
    }
    [alert show];
}

- (NSString *)suggestedSharedFolderForItem:(IP1FileItem *)item {
    NSString *ext = [[item.path pathExtension] lowercaseString];
    if ([ext isEqualToString:@"pdf"]) return @"/var/mobile/Media/iPad1Files/PDFs";
    if ([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"png"] || [ext isEqualToString:@"gif"]) return @"/var/mobile/Media/iPad1Files/Images";
    if ([ext isEqualToString:@"mp3"] || [ext isEqualToString:@"m4a"] || [ext isEqualToString:@"aac"] || [ext isEqualToString:@"wav"]) return @"/var/mobile/Media/iPad1Files/Music";
    if ([ext isEqualToString:@"zip"] || [ext isEqualToString:@"rar"] || [ext isEqualToString:@"7z"] || [ext isEqualToString:@"tar"] || [ext isEqualToString:@"gz"]) return @"/var/mobile/Media/iPad1Files/Archives";
    return nil;
}

- (void)showActionsForItem:(IP1FileItem *)item {
    BOOL favorite = [[IP1FavoritesManager sharedManager] isFavorite:item.path];

    UIActionSheet *sheet =
        [[[UIActionSheet alloc] initWithTitle:item.name
                                     delegate:self
                            cancelButtonTitle:nil
                       destructiveButtonTitle:nil
                            otherButtonTitles:@"Bilgi",
                                              favorite ? @"Favorilerden Çıkar" : @"Favorilere Ekle",
                                              @"Yeniden Adlandır",
                                              @"Sil",
                                              nil] autorelease];

    NSDictionary *registration = [IP1AppRegistry registrationForPath:item.path];
    NSString *appName = [registration objectForKey:@"name"];
    if (appName) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@ ile Aç", appName]];
        objc_setAssociatedObject(sheet, "IP1OpenRegistration", registration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if ([_path isEqualToString:@"/var/mobile/Media/iPad1Files/Downloads"]) {
        NSString *destination = [self suggestedSharedFolderForItem:item];
        if (destination) {
            [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@ klasörüne taşı", [destination lastPathComponent]]];
            objc_setAssociatedObject(sheet, "IP1SuggestedFolder", destination, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    [sheet addButtonWithTitle:@"Vazgeç"];
    sheet.destructiveButtonIndex = 3;
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;

    objc_setAssociatedObject(sheet, "IP1FileItem", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    if (objc_getAssociatedObject(actionSheet, "IP1SelectionSheet")) {
        if ([title isEqualToString:@"Sil"]) {
            BOOL protectedArea =
                [[IP1FileManager sharedManager] isProtectedSystemDirectory:_path];
            NSString *message = protectedArea
                ? [NSString stringWithFormat:@"UYARI: Korumalı sistem alanındaki %lu öğe kalıcı olarak silinecek. Bu işlem cihazın çalışmasını etkileyebilir.",
                   (unsigned long)[_selectedPaths count]]
                : [NSString stringWithFormat:@"%lu öğe kalıcı olarak silinsin mi?",
                   (unsigned long)[_selectedPaths count]];
            UIAlertView *alert =
                [[[UIAlertView alloc] initWithTitle:protectedArea ? @"SİSTEM ALANI — Toplu Silme" : @"Toplu Silme"
                                            message:message
                                           delegate:self
                                  cancelButtonTitle:@"Vazgeç"
                                  otherButtonTitles:@"Sil", nil] autorelease];
            alert.tag = 200;
            [alert show];
        } else if ([title isEqualToString:@"Kopyala"]) {
            [self startDestinationOperation:@"copy"];
        } else if ([title isEqualToString:@"Taşı"]) {
            [self startDestinationOperation:@"move"];
        } else if ([title isEqualToString:@"ZIP Oluştur"]) {
            UIAlertView *alert =
                [[[UIAlertView alloc] initWithTitle:@"ZIP Oluştur"
                                            message:@"Arşiv adını yazın"
                                           delegate:self
                                  cancelButtonTitle:@"Vazgeç"
                                  otherButtonTitles:@"Oluştur", nil] autorelease];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [[alert textFieldAtIndex:0] setText:@"Archive.zip"];
            alert.tag = 400;
            [alert show];
        }
        return;
    }

    IP1FileItem *item = objc_getAssociatedObject(actionSheet, "IP1FileItem");

    if ([title isEqualToString:@"Bilgi"]) {
        FileInfoViewController *info =
            [[[FileInfoViewController alloc] initWithPath:item.path] autorelease];
        [self.navigationController pushViewController:info animated:YES];
    } else if ([title hasSuffix:@" ile Aç"]) {
        NSDictionary *registration = objc_getAssociatedObject(actionSheet, "IP1OpenRegistration");
        if (![IP1AppLauncher openPath:item.path withRegistration:registration]) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Uygulama açılamadı" message:@"Eşleşen uygulama kurulu değil veya URL scheme kullanılamıyor." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
            [alert show];
        }
    } else if ([title hasSuffix:@" klasörüne taşı"]) {
        NSString *destination = objc_getAssociatedObject(actionSheet, "IP1SuggestedFolder");
        NSError *moveError = nil;
        if (![[IP1FileManager sharedManager] moveItemAtPath:item.path toDirectory:destination error:&moveError]) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Taşıma başarısız" message:[moveError localizedDescription] delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
            [alert show];
        }
        [self reloadFiles];
        [self updateFooter];
    } else if ([title isEqualToString:@"Favorilere Ekle"] ||
               [title isEqualToString:@"Favorilerden Çıkar"]) {
        [[IP1FavoritesManager sharedManager] toggleFavorite:item.path];
    } else if ([title isEqualToString:@"Yeniden Adlandır"]) {
        [self promptRename:item];
    } else if ([title isEqualToString:@"Sil"]) {
        [self confirmDelete:item];
    } else if ([title isEqualToString:@"Gizli Dosyaları Göster"] ||
               [title isEqualToString:@"Gizli Dosyaları Gizle"]) {
        _showHidden = !_showHidden;
        [self reloadFiles];
    } else if ([title isEqualToString:@"Favoriler"]) {
        FavoritesViewController *favorites = [[[FavoritesViewController alloc] init] autorelease];
        [self.navigationController pushViewController:favorites animated:YES];
    } else if ([title isEqualToString:@"Yenile"]) {
        [self reloadFiles];
        [self updateFooter];
    } else if ([title isEqualToString:@"Üst Dizine Git"]) {
        NSString *parentPath = [_path stringByDeletingLastPathComponent];
        if ([parentPath length] == 0) parentPath = @"/";
        FileBrowserViewController *browser =
            [[[FileBrowserViewController alloc] initWithPath:parentPath] autorelease];
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)addFolder {
    UIAlertView *alert =
        [[[UIAlertView alloc] initWithTitle:@"Yeni Klasör"
                                    message:@"Klasör adını yazın"
                                   delegate:self
                          cancelButtonTitle:@"Vazgeç"
                          otherButtonTitles:@"Oluştur", nil] autorelease];

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [alert show];
}

- (void)promptRename:(IP1FileItem *)item {
    BOOL protectedArea = [[IP1FileManager sharedManager] isProtectedSystemDirectory:_path];
    UIAlertView *alert =
        [[[UIAlertView alloc] initWithTitle:protectedArea ? @"Sistem Öğesini Yeniden Adlandır" : @"Yeniden Adlandır"
                                    message:protectedArea ? @"Dikkat: Sistem alanındaki bir öğenin adını değiştirmek cihazın çalışmasını etkileyebilir." : nil
                                   delegate:self
                          cancelButtonTitle:@"Vazgeç"
                          otherButtonTitles:@"Kaydet", nil] autorelease];

    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setText:item.name];
    alert.tag = 101;
    objc_setAssociatedObject(alert, "IP1RenameItem", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [alert show];
}

- (void)confirmDelete:(IP1FileItem *)item {
    BOOL protectedArea = [[IP1FileManager sharedManager] isProtectedSystemDirectory:_path];
    NSString *message = protectedArea
        ? [NSString stringWithFormat:@"UYARI: %@ bir sistem alanı öğesidir. Silmek cihazın çalışmasını etkileyebilir. Yine de silinsin mi?", item.name]
        : [NSString stringWithFormat:@"%@ silinsin mi?", item.name];
    UIAlertView *alert =
        [[[UIAlertView alloc] initWithTitle:protectedArea ? @"SİSTEM ALANI — Sil" : @"Sil"
                                    message:message
                                   delegate:self
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

    if (alertView.tag == 400) {
        NSString *name = [[alertView textFieldAtIndex:0] text];
        NSError *zipError = nil;

        NSString *created =
            [[ArchiveManager sharedManager] createZipNamed:name
                                                 fromPaths:_selectedPaths
                                               inDirectory:_path
                                                     error:&zipError];

        UIAlertView *resultAlert;

        if (created) {
            resultAlert =
                [[[UIAlertView alloc] initWithTitle:@"ZIP Oluşturuldu"
                                            message:[created lastPathComponent]
                                           delegate:nil
                                  cancelButtonTitle:@"Tamam"
                                  otherButtonTitles:nil] autorelease];
        } else {
            resultAlert =
                [[[UIAlertView alloc] initWithTitle:@"ZIP Oluşturulamadı"
                                            message:[zipError localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:@"Tamam"
                                  otherButtonTitles:nil] autorelease];
        }

        [resultAlert show];
        [self cancelSelection];
        [self reloadFiles];
        [self updateFooter];
        return;

    } else if (alertView.tag == 201) {
        [self presentDestinationPicker];
        return;
    } else if (alertView.tag == 300) {
        IP1FileConflictPolicy policy =
            (buttonIndex == 2) ? IP1FileConflictPolicyOverwrite : IP1FileConflictPolicyUnique;
        [self performPendingTransferToPath:_pendingDestination conflictPolicy:policy];
        return;
    } else if (alertView.tag == 301) {
        [self performPendingTransferToPath:_pendingDestination
                           conflictPolicy:IP1FileConflictPolicyUnique];
        return;
    } else if (alertView.tag == 100) {
        NSString *name = [[alertView textFieldAtIndex:0] text];
        success = [[IP1FileManager sharedManager] createFolderNamed:name inDirectory:_path error:&error];
    } else if (alertView.tag == 101) {
        IP1FileItem *item = objc_getAssociatedObject(alertView, "IP1RenameItem");
        NSString *name = [[alertView textFieldAtIndex:0] text];
        success = [[IP1FileManager sharedManager] renameItemAtPath:item.path toName:name error:&error];
    } else if (alertView.tag == 102) {
        IP1FileItem *item = objc_getAssociatedObject(alertView, "IP1DeleteItem");
        success = [[IP1FileManager sharedManager] deleteItemAtPath:item.path error:&error];
    } else if (alertView.tag == 200) {
        success = YES;
        for (NSString *path in _selectedPaths) {
            if (![[IP1FileManager sharedManager] deleteItemAtPath:path error:&error]) {
                success = NO;
                break;
            }
        }
        [self cancelSelection];
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
    [self updateFooter];
}

- (void)showFolderActions {
    UIActionSheet *sheet =
        [[[UIActionSheet alloc] initWithTitle:_path
                                     delegate:self
                            cancelButtonTitle:nil
                       destructiveButtonTitle:nil
                            otherButtonTitles:
                              [[IP1FavoritesManager sharedManager] isFavorite:_path]
                                ? @"Favorilerden Çıkar"
                                : @"Favorilere Ekle",
                              @"Favoriler",
                              _showHidden ? @"Gizli Dosyaları Gizle" : @"Gizli Dosyaları Göster",
                              @"Yenile",
                              nil] autorelease];

    if (![_path isEqualToString:@"/"]) {
        [sheet addButtonWithTitle:@"Üst Dizine Git"];
    }
    [sheet addButtonWithTitle:@"Vazgeç"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    objc_setAssociatedObject(sheet, "IP1FileItem",
                             [IP1FileItem itemWithPath:_path],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    [_selectedPaths release];
    [_pendingOperation release];
    [_pendingDestination release];
    [super dealloc];
}

@end
