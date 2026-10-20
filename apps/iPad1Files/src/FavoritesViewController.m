#import "FavoritesViewController.h"
#import "IP1FavoritesManager.h"
#import "FileBrowserViewController.h"

@implementation FavoritesViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) self.title = @"Favoriler";
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_favorites release];
    _favorites = [[[IP1FavoritesManager sharedManager] favorites] retain];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView; (void)section;
    return [_favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:identifier] autorelease];
    }

    NSString *path = [_favorites objectAtIndex:indexPath.row];
    cell.textLabel.text = [path lastPathComponent];
    cell.detailTextLabel.text = path;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *path = [_favorites objectAtIndex:indexPath.row];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        FileBrowserViewController *browser =
            [[[FileBrowserViewController alloc] initWithPath:path] autorelease];
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *path = [_favorites objectAtIndex:indexPath.row];
        [[IP1FavoritesManager sharedManager] removeFavorite:path];
        [self viewWillAppear:NO];
    }
}

- (void)dealloc {
    [_favorites release];
    [super dealloc];
}

@end
