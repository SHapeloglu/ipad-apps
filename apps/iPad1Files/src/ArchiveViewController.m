#import "ArchiveViewController.h"
#import "ArchiveManager.h"

@implementation ArchiveViewController

- (id)initWithZipPath:(NSString *)zipPath {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _zipPath = [zipPath copy];
        self.title = [zipPath lastPathComponent];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error = nil;
    _entries = [[[ArchiveManager sharedManager] entriesInZipAtPath:_zipPath
                                                            error:&error] retain];

    if (!_entries) {
        UIAlertView *alert =
            [[[UIAlertView alloc] initWithTitle:@"ZIP Açılamadı"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Tamam"
                              otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }

    UIBarButtonItem *extract =
        [[[UIBarButtonItem alloc] initWithTitle:@"Tümünü Çıkar"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(showExtractOptions)] autorelease];
    self.navigationItem.rightBarButtonItem = extract;

    unsigned long long total = 0;
    NSUInteger fileCount = 0;

    for (NSDictionary *entry in _entries) {
        if (![[entry objectForKey:@"directory"] boolValue]) {
            total += [[entry objectForKey:@"size"] unsignedLongLongValue];
            fileCount++;
        }
    }

    UILabel *footer =
        [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)] autorelease];
    footer.textAlignment = UITextAlignmentCenter;
    footer.font = [UIFont systemFontOfSize:12.0];
    footer.textColor = [UIColor grayColor];
    footer.backgroundColor = [UIColor clearColor];
    footer.text = [NSString stringWithFormat:@"%lu dosya • %.1f MB",
                   (unsigned long)fileCount,
                   (double)total / (1024.0 * 1024.0)];
    self.tableView.tableFooterView = footer;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    (void)section;
    return [_entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ArchiveEntry";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:identifier] autorelease];
    }

    NSDictionary *entry = [_entries objectAtIndex:indexPath.row];
    NSString *name = [entry objectForKey:@"name"];

    cell.textLabel.text = name;

    if ([[entry objectForKey:@"directory"] boolValue]) {
        cell.detailTextLabel.text = @"Klasör";
    } else {
        unsigned long long size =
            [[entry objectForKey:@"size"] unsignedLongLongValue];
        cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%.1f KB", (double)size / 1024.0];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)showExtractOptions {
    UIActionSheet *sheet =
        [[[UIActionSheet alloc] initWithTitle:@"ZIP'i Çıkar"
                                     delegate:self
                            cancelButtonTitle:nil
                       destructiveButtonTitle:nil
                            otherButtonTitles:@"Buraya Çıkar",
                                              @"Başka Klasör Seç",
                                              nil] autorelease];

    [sheet addButtonWithTitle:@"Vazgeç"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
 clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([title isEqualToString:@"Buraya Çıkar"]) {
        [self extractToDirectory:[_zipPath stringByDeletingLastPathComponent]];
    } else if ([title isEqualToString:@"Başka Klasör Seç"]) {
        FolderPickerViewController *picker =
            [[[FolderPickerViewController alloc]
                initWithPath:@"/var/mobile/Media/iPad1Files"] autorelease];

        picker.delegate = self;
        picker.actionTitle = @"Buraya Çıkar";

        UINavigationController *nav =
            [[[UINavigationController alloc]
                initWithRootViewController:picker] autorelease];

        UIBarButtonItem *cancel =
            [[[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                     target:self
                                     action:@selector(dismissPicker)] autorelease];

        picker.navigationItem.leftBarButtonItem = cancel;
        [self presentModalViewController:nav animated:YES];
    }
}

- (void)dismissPicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)folderPicker:(FolderPickerViewController *)picker
       didChoosePath:(NSString *)path {
    (void)picker;
    [self dismissModalViewControllerAnimated:NO];
    [self extractToDirectory:path];
}

- (void)extractToDirectory:(NSString *)directory {
    NSError *error = nil;

    NSString *result =
        [[ArchiveManager sharedManager] extractZipAtPath:_zipPath
                                            toDirectory:directory
                                                  error:&error];

    UIAlertView *alert;

    if (result) {
        alert =
            [[[UIAlertView alloc] initWithTitle:@"ZIP Çıkarıldı"
                                        message:result
                                       delegate:nil
                              cancelButtonTitle:@"Tamam"
                              otherButtonTitles:nil] autorelease];
    } else {
        alert =
            [[[UIAlertView alloc] initWithTitle:@"Çıkarma Başarısız"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"Tamam"
                              otherButtonTitles:nil] autorelease];
    }

    [alert show];
}

- (void)dealloc {
    [_zipPath release];
    [_entries release];
    [super dealloc];
}

@end
