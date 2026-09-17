#import "AppDelegate.h"

@implementation AppDelegate
@synthesize window = _window;

- (UITextField *)fieldWithFrame:(CGRect)frame placeholder:(NSString *)placeholder {
    UITextField *field = [[[UITextField alloc] initWithFrame:frame] autorelease];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.placeholder = placeholder;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.delegate = self;
    return field;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[[UIViewController alloc] init] autorelease];
    vc.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.0];

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(30, 20, 708, 38)] autorelease];
    title.text = @"iPad 1 FTP Browser";
    title.font = [UIFont boldSystemFontOfSize:24.0];
    title.textAlignment = UITextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    [vc.view addSubview:title];

    CGFloat x = 40.0, y = 66.0, h = 38.0, gap = 46.0;

    _hostField = [[self fieldWithFrame:CGRectMake(x, y, 510, h) placeholder:@"FTP Sunucusu / IP"] retain];
    _hostField.keyboardType = UIKeyboardTypeURL;
    [vc.view addSubview:_hostField];

    _portField = [[self fieldWithFrame:CGRectMake(560, y, 168, h) placeholder:@"Port"] retain];
    _portField.text = @"21";
    _portField.keyboardType = UIKeyboardTypeNumberPad;
    [vc.view addSubview:_portField];

    y += gap;
    _userField = [[self fieldWithFrame:CGRectMake(x, y, 330, h) placeholder:@"Kullanıcı adı"] retain];
    [vc.view addSubview:_userField];

    _passField = [[self fieldWithFrame:CGRectMake(380, y, 348, h) placeholder:@"Şifre"] retain];
    _passField.secureTextEntry = YES;
    [vc.view addSubview:_passField];

    y += gap;
    _pathField = [[self fieldWithFrame:CGRectMake(x, y, 500, h) placeholder:@"Klasör yolu"] retain];
    _pathField.text = @"/";
    [vc.view addSubview:_pathField];

    _connectButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _connectButton.frame = CGRectMake(550, y, 178, h);
    [_connectButton setTitle:@"BAĞLAN / LİSTELE" forState:UIControlStateNormal];
    [_connectButton addTarget:self action:@selector(connectTapped:) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:_connectButton];

    y += 48;
    _upButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _upButton.frame = CGRectMake(40, y, 120, 36);
    [_upButton setTitle:@"← Üst Klasör" forState:UIControlStateNormal];
    [_upButton addTarget:self action:@selector(upTapped:) forControlEvents:UIControlEventTouchUpInside];
    _upButton.enabled = NO;
    [vc.view addSubview:_upButton];

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, y, 558, 36)];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.text = @"Hazır";
    [vc.view addSubview:_statusLabel];

    y += 42;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(40, y, 688, 620) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [vc.view addSubview:_tableView];

    y += 628;
    _bytesLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, y, 688, 32)];
    _bytesLabel.backgroundColor = [UIColor clearColor];
    _bytesLabel.textAlignment = UITextAlignmentCenter;
    _bytesLabel.text = @"Dosyaya dokununca indirme başlar.";
    [vc.view addSubview:_bytesLabel];

    _browser = [[FTPBrowser alloc] init];
    _browser.delegate = self;

    _downloader = [[FTPDownloader alloc] init];
    _downloader.delegate = self;

    _items = [[NSArray alloc] init];
    _currentPath = [@"/" copy];

    _window.rootViewController = vc;
    [_window makeKeyAndVisible];
    return YES;
}

- (void)dismissKeyboard {
    [_hostField resignFirstResponder];
    [_portField resignFirstResponder];
    [_userField resignFirstResponder];
    [_passField resignFirstResponder];
    [_pathField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)captureConnectionFields {
    [_host release]; [_username release]; [_password release];
    _host = [[_hostField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy];
    _username = [_userField.text copy];
    _password = [_passField.text copy];
    _port = [_portField.text integerValue];
    if (_port <= 0 || _port > 65535) _port = 21;
}

- (void)connectTapped:(id)sender {
    [self dismissKeyboard];
    [self captureConnectionFields];

    if ([_host length] == 0) {
        _statusLabel.text = @"FTP sunucusu gerekli.";
        return;
    }

    NSString *path = [_pathField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([path length] == 0) path = @"/";
    if (![path hasPrefix:@"/"]) path = [@"/" stringByAppendingString:path];

    [_currentPath release];
    _currentPath = [path copy];

    [_browser listHost:_host port:_port username:_username password:_password path:_currentPath];
}

- (void)upTapped:(id)sender {
    if ([_currentPath isEqualToString:@"/"]) return;
    NSString *parent = [_currentPath stringByDeletingLastPathComponent];
    if ([parent length] == 0) parent = @"/";

    [_currentPath release];
    _currentPath = [parent copy];
    _pathField.text = _currentPath;

    [_browser listHost:_host port:_port username:_username password:_password path:_currentPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FTPCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    NSDictionary *item = [_items objectAtIndex:indexPath.row];
    NSString *name = [item objectForKey:@"name"];
    BOOL isDirectory = [[item objectForKey:@"isDirectory"] boolValue];
    NSString *size = [item objectForKey:@"size"];

    cell.textLabel.text = name;
    cell.detailTextLabel.text = isDirectory ? @"Klasör" :
        ([size length] > 0 ? [NSString stringWithFormat:@"%@ bytes", size] : @"Dosya");
    cell.accessoryType = isDirectory ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}

- (NSString *)joinedRemotePathWithName:(NSString *)name {
    if ([_currentPath isEqualToString:@"/"]) return [@"/" stringByAppendingString:name];
    return [_currentPath stringByAppendingPathComponent:name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *item = [_items objectAtIndex:indexPath.row];
    NSString *name = [item objectForKey:@"name"];
    BOOL isDirectory = [[item objectForKey:@"isDirectory"] boolValue];
    NSString *remote = [self joinedRemotePathWithName:name];

    if (isDirectory) {
        [_currentPath release];
        _currentPath = [remote copy];
        _pathField.text = _currentPath;
        [_browser listHost:_host port:_port username:_username password:_password path:_currentPath];
        return;
    }

    NSString *safeName = [name lastPathComponent];
    NSString *destination = [@"/var/mobile/Media/iPad1FTPDownloads" stringByAppendingPathComponent:safeName];

    _statusLabel.text = [NSString stringWithFormat:@"İndiriliyor: %@", name];
    _bytesLabel.text = @"0 KB";

    [_downloader downloadHost:_host port:_port username:_username password:_password remotePath:remote destinationPath:destination];
}

- (void)ftpBrowserDidStart:(FTPBrowser *)browser path:(NSString *)path {
    _statusLabel.text = [NSString stringWithFormat:@"Listeleniyor: %@", path];
    _connectButton.enabled = NO;
}

- (void)ftpBrowser:(FTPBrowser *)browser didFinishWithItems:(NSArray *)items path:(NSString *)path {
    [_items release];
    _items = [items copy];

    _pathField.text = path;
    _statusLabel.text = [NSString stringWithFormat:@"%lu öğe - %@", (unsigned long)[_items count], path];
    _connectButton.enabled = YES;
    _upButton.enabled = ![path isEqualToString:@"/"];
    [_tableView reloadData];
}

- (void)ftpBrowser:(FTPBrowser *)browser didFailWithError:(NSError *)error {
    _connectButton.enabled = YES;
    _statusLabel.text = [NSString stringWithFormat:@"Listeleme hatası: %@", [error localizedDescription]];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"FTP Listeleme Hatası"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)ftpDownloaderDidStart:(FTPDownloader *)downloader destination:(NSString *)destination {
    _bytesLabel.text = @"İndirme başladı...";
}

- (void)ftpDownloader:(FTPDownloader *)downloader didReceiveBytes:(unsigned long long)totalBytes {
    double mb = ((double)totalBytes) / (1024.0 * 1024.0);
    if (mb >= 1.0)
        _bytesLabel.text = [NSString stringWithFormat:@"%.2f MB indirildi", mb];
    else
        _bytesLabel.text = [NSString stringWithFormat:@"%.1f KB indirildi", ((double)totalBytes) / 1024.0];
}

- (void)ftpDownloaderDidFinish:(FTPDownloader *)downloader destination:(NSString *)destination bytes:(unsigned long long)totalBytes {
    _statusLabel.text = @"İndirme tamamlandı";
    _bytesLabel.text = destination;

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"İndirme tamamlandı"
                                                    message:destination
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)ftpDownloader:(FTPDownloader *)downloader didFailWithError:(NSError *)error {
    _statusLabel.text = [NSString stringWithFormat:@"İndirme hatası: %@", [error localizedDescription]];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"FTP İndirme Hatası"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)dealloc {
    _browser.delegate = nil; [_browser release];
    _downloader.delegate = nil; [_downloader release];
    [_items release]; [_currentPath release];
    [_host release]; [_username release]; [_password release];
    [_hostField release]; [_portField release]; [_userField release]; [_passField release]; [_pathField release];
    [_connectButton release]; [_upButton release];
    [_statusLabel release]; [_bytesLabel release]; [_tableView release];
    [_window release];
    [super dealloc];
}
@end
