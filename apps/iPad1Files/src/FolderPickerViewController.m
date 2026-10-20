#import "FolderPickerViewController.h"
#import "IP1FileManager.h"
#import "IP1FileItem.h"

@implementation FolderPickerViewController

@synthesize delegate = _delegate;
@synthesize actionTitle = _actionTitle;

- (id)initWithPath:(NSString *)path {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _path = [path copy];
        self.title = [path lastPathComponent];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *choose =
        [[[UIBarButtonItem alloc] initWithTitle:self.actionTitle ?: @"Burayı Seç"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(chooseCurrent)] autorelease];
    self.navigationItem.rightBarButtonItem = choose;
    [self reloadFolders];
}

- (void)reloadFolders {
    NSError *error = nil;
    NSArray *all = [[IP1FileManager sharedManager] contentsOfDirectory:_path
                                                            showHidden:NO
                                                                 error:&error];
    NSMutableArray *dirs = [NSMutableArray array];
    for (IP1FileItem *item in all) {
        if (item.isDirectory) [dirs addObject:item];
    }

    [_items release];
    _items = [dirs copy];
    [self.tableView reloadData];
}

- (void)chooseCurrent {
    if ([_delegate respondsToSelector:@selector(folderPicker:didChoosePath:)]) {
        [_delegate folderPicker:self didChoosePath:_path];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView; (void)section;
    return [_items count] + ([_path isEqualToString:@"/"] ? 0 : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FolderPickerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier] autorelease];
    }

    if (![_path isEqualToString:@"/"] && indexPath.row == 0) {
        cell.textLabel.text = @"..  Üst Dizin";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    NSInteger itemIndex = indexPath.row - ([_path isEqualToString:@"/"] ? 0 : 1);
    IP1FileItem *item = [_items objectAtIndex:itemIndex];
    cell.textLabel.text = item.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![_path isEqualToString:@"/"] && indexPath.row == 0) {
        NSString *parentPath = [_path stringByDeletingLastPathComponent];
        if ([parentPath length] == 0) parentPath = @"/";
        FolderPickerViewController *parent =
            [[[FolderPickerViewController alloc] initWithPath:parentPath] autorelease];
        parent.delegate = _delegate;
        parent.actionTitle = _actionTitle;
        [self.navigationController pushViewController:parent animated:YES];
        return;
    }

    NSInteger itemIndex = indexPath.row - ([_path isEqualToString:@"/"] ? 0 : 1);
    IP1FileItem *item = [_items objectAtIndex:itemIndex];
    FolderPickerViewController *child =
        [[[FolderPickerViewController alloc] initWithPath:item.path] autorelease];
    child.delegate = _delegate;
    child.actionTitle = _actionTitle;
    [self.navigationController pushViewController:child animated:YES];
}

- (void)dealloc {
    [_path release];
    [_items release];
    [_actionTitle release];
    [super dealloc];
}

@end
