#import "FileInfoViewController.h"
#import "IP1FileItem.h"
#import "IP1FileTypeDetector.h"
#import "IP1FileManager.h"

@implementation FileInfoViewController

- (id)initWithPath:(NSString *)path {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _path = [path copy];
        self.title = @"Bilgi";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    IP1FileItem *item = [IP1FileItem itemWithPath:_path];
    unsigned long long calculatedSize =
        item.isDirectory ? [[IP1FileManager sharedManager] recursiveSizeOfPath:_path] : item.size;

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];

    NSString *sizeString;
    if (calculatedSize < 1024ULL) {
        sizeString = [NSString stringWithFormat:@"%llu B", calculatedSize];
    } else if (calculatedSize < 1024ULL * 1024ULL) {
        sizeString = [NSString stringWithFormat:@"%.1f KB", calculatedSize / 1024.0];
    } else {
        sizeString = [NSString stringWithFormat:@"%.1f MB", calculatedSize / (1024.0 * 1024.0)];
    }

    NSString *type = item.isDirectory
        ? @"Klasör"
        : [IP1FileTypeDetector displayNameForType:[IP1FileTypeDetector typeForPath:_path]];

    _rows = [[NSArray alloc] initWithObjects:
        [NSArray arrayWithObjects:@"Ad", item.name ?: @"", nil],
        [NSArray arrayWithObjects:@"Tür", type ?: @"", nil],
        [NSArray arrayWithObjects:@"Boyut", sizeString ?: @"", nil],
        [NSArray arrayWithObjects:@"Değiştirilme", item.modifiedDate ? [formatter stringFromDate:item.modifiedDate] : @"-", nil],
        [NSArray arrayWithObjects:@"Yol", _path ?: @"", nil],
        nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    (void)section;
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                      reuseIdentifier:identifier] autorelease];
    }

    NSArray *row = [_rows objectAtIndex:indexPath.row];
    cell.textLabel.text = [row objectAtIndex:0];
    cell.detailTextLabel.text = [row objectAtIndex:1];
    cell.detailTextLabel.numberOfLines = 3;
    return cell;
}

- (void)dealloc {
    [_path release];
    [_rows release];
    [super dealloc];
}

@end
