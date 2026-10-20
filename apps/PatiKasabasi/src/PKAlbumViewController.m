#import "PKAlbumViewController.h"
#import "PKGameState.h"
#import "PKTheme.h"

@interface PKAlbumViewController ()
- (NSString *)collectionDisplayName:(NSString *)identifier;
@end

@implementation PKAlbumViewController

- (id)initWithGameState:(PKGameState *)gameState {
    self = [super init];
    if (self) {
        _gameState = [gameState retain];
        self.title = @"Anı Albümü";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *title = [self labelWithFrame:CGRectMake(30.0f, 12.0f, 560.0f, 44.0f) text:@"Birlikte Biriktirdiklerimiz" fontSize:28.0f bold:YES];
    title.textAlignment = UITextAlignmentLeft;
    [self.view addSubview:title];
    UILabel *count = [self labelWithFrame:CGRectMake(610.0f, 12.0f, 380.0f, 44.0f) text:[NSString stringWithFormat:@"%lu anı • %lu koleksiyon", (unsigned long)[_gameState.memories count], (unsigned long)[_gameState.collections count]] fontSize:18.0f bold:YES];
    [self.view addSubview:count];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(30.0f, 68.0f, 964.0f, 590.0f) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 92.0f;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { (void)tableView; return 2; }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    (void)tableView;
    return section == 0 ? @"Anılar ve Fotoğraflar" : @"Kasaba Koleksiyonu";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    if (section == 0) return MAX(1, (NSInteger)[_gameState.memories count]);
    return MAX(1, (NSInteger)[_gameState.collections count]);
}

- (NSString *)collectionDisplayName:(NSString *)identifier {
    if ([identifier isEqualToString:@"event_0"]) return @"Çiçek Pikniği Rozeti";
    if ([identifier isEqualToString:@"event_1"]) return @"Müzik Günü Rozeti";
    if ([identifier isEqualToString:@"event_2"]) return @"Renk Şenliği Rozeti";
    if ([identifier isEqualToString:@"event_3"]) return @"Yıldız Gecesi Rozeti";
    if ([identifier isEqualToString:@"friend_luna"]) return @"Luna'nın Dostluk Patisi";
    if ([identifier isEqualToString:@"friend_zeytin"]) return @"Zeytin'in Dostluk Patisi";
    if ([identifier isEqualToString:@"friend_mira"]) return @"Mira'nın Dostluk Patisi";
    if ([identifier isEqualToString:@"friend_findik"]) return @"Fındık'ın Dostluk Patisi";
    return @"Kasaba Hatırası";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
    if (indexPath.section == 0) {
        if ([_gameState.memories count] == 0) {
            cell.textLabel.text = @"Henüz anı yok";
            cell.detailTextLabel.text = @"Ev ekranındaki Fotoğraf düğmesini kullanabilirsin.";
            return cell;
        }
        NSDictionary *memory = [_gameState.memories objectAtIndex:(NSUInteger)indexPath.row];
        cell.textLabel.text = [memory objectForKey:@"title"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Gün %@", [memory objectForKey:@"day"]];
        NSString *filename = [memory objectForKey:@"filename"];
        if ([filename length] > 0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            if ([paths count] > 0) {
                NSString *path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"PatiMemories"] stringByAppendingPathComponent:filename];
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                if (image) cell.imageView.image = image;
            }
        } else {
            cell.imageView.image = [UIImage imageNamed:@"Icon-72.png"];
        }
    } else {
        if ([_gameState.collections count] == 0) {
            cell.textLabel.text = @"Koleksiyon rafın boş";
            cell.detailTextLabel.text = @"Kasaba etkinliklerine ve komşu ziyaretlerine katıl.";
            return cell;
        }
        NSString *identifier = [_gameState.collections objectAtIndex:(NSUInteger)indexPath.row];
        cell.textLabel.text = [self collectionDisplayName:identifier];
        cell.detailTextLabel.text = @"Pati Kasabası koleksiyonuna eklendi ✓";
        cell.imageView.image = [UIImage imageNamed:@"Icon-72.png"];
    }
    return cell;
}

- (void)dealloc {
    [_gameState release];
    [_tableView release];
    [super dealloc];
}

@end
