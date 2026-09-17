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

    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(40, 30, 688, 50)] autorelease];
    title.text = @"iPad 1 FTP Downloader";
    title.font = [UIFont boldSystemFontOfSize:28.0];
    title.textAlignment = UITextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    [vc.view addSubview:title];

    CGFloat x = 70.0;
    CGFloat w = 628.0;
    CGFloat h = 42.0;
    CGFloat y = 105.0;
    CGFloat gap = 54.0;

    _hostField = [[self fieldWithFrame:CGRectMake(x, y, w, h) placeholder:@"FTP Sunucusu / IP (örn. 95.111.242.96)"] retain];
    _hostField.keyboardType = UIKeyboardTypeURL;
    [vc.view addSubview:_hostField];

    y += gap;
    _portField = [[self fieldWithFrame:CGRectMake(x, y, w, h) placeholder:@"Port (varsayılan 21)"] retain];
    _portField.keyboardType = UIKeyboardTypeNumberPad;
    _portField.text = @"21";
    [vc.view addSubview:_portField];

    y += gap;
    _userField = [[self fieldWithFrame:CGRectMake(x, y, w, h) placeholder:@"Kullanıcı adı"] retain];
    [vc.view addSubview:_userField];

    y += gap;
    _passField = [[self fieldWithFrame:CGRectMake(x, y, w, h) placeholder:@"Şifre"] retain];
    _passField.secureTextEntry = YES;
    [vc.view addSubview:_passField];

    y += gap;
    _remotePathField = [[self fieldWithFrame:CGRectMake(x, y, w, h) placeholder:@"Uzak dosya yolu (örn. /files/video.mp4)"] retain];
    [vc.view addSubview:_remotePathField];

    y += gap;
    _localNameField = [[self fieldWithFrame:CGRectMake(x, y, w, h) placeholder:@"Kaydedilecek dosya adı (boşsa otomatik)"] retain];
    [vc.view addSubview:_localNameField];

    y += 66.0;
    _downloadButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _downloadButton.frame = CGRectMake(220, y, 328, 52);
    [_downloadButton setTitle:@"İNDİR" forState:UIControlStateNormal];
    _downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
    [_downloadButton addTarget:self action:@selector(downloadTapped:) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:_downloadButton];

    y += 70.0;
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, y, 628, 54)];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textAlignment = UITextAlignmentCenter;
    _statusLabel.numberOfLines = 2;
    _statusLabel.text = @"Hazır";
    [vc.view addSubview:_statusLabel];

    y += 56.0;
    _bytesLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, y, 628, 40)];
    _bytesLabel.backgroundColor = [UIColor clearColor];
    _bytesLabel.textAlignment = UITextAlignmentCenter;
    _bytesLabel.text = @"0 KB";
    [vc.view addSubview:_bytesLabel];

    UILabel *pathLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 925, 688, 30)] autorelease];
    pathLabel.text = @"Kayıt klasörü: /var/mobile/Media/iPad1FTPDownloads/";
    pathLabel.font = [UIFont systemFontOfSize:14.0];
    pathLabel.textAlignment = UITextAlignmentCenter;
    pathLabel.backgroundColor = [UIColor clearColor];
    [vc.view addSubview:pathLabel];

    _downloader = [[FTPDownloader alloc] init];
    _downloader.delegate = self;

    _window.rootViewController = vc;
    [_window makeKeyAndVisible];

    return YES;
}

- (void)downloadTapped:(id)sender {
    [self dismissKeyboard];

    NSString *host = [_hostField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *remote = [_remotePathField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([host length] == 0 || [remote length] == 0) {
        _statusLabel.text = @"Sunucu ve uzak dosya yolu zorunlu.";
        return;
    }

    NSInteger port = [_portField.text integerValue];
    if (port <= 0 || port > 65535) port = 21;

    NSString *name = [_localNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([name length] == 0) {
        name = [remote lastPathComponent];
        if ([name length] == 0) name = @"download.bin";
    }

    // Prevent path traversal through local filename.
    name = [name lastPathComponent];

    NSString *base = @"/var/mobile/Media/iPad1FTPDownloads";
    NSString *destination = [base stringByAppendingPathComponent:name];

    _downloadButton.enabled = NO;
    _statusLabel.text = @"Bağlanıyor...";
    _bytesLabel.text = @"0 KB";

    [_downloader downloadHost:host
                         port:port
                     username:_userField.text
                     password:_passField.text
                   remotePath:remote
              destinationPath:destination];
}

- (void)dismissKeyboard {
    [_hostField resignFirstResponder];
    [_portField resignFirstResponder];
    [_userField resignFirstResponder];
    [_passField resignFirstResponder];
    [_remotePathField resignFirstResponder];
    [_localNameField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)ftpDownloaderDidStart:(FTPDownloader *)downloader destination:(NSString *)destination {
    _statusLabel.text = @"İndiriliyor...";
}

- (void)ftpDownloader:(FTPDownloader *)downloader didReceiveBytes:(unsigned long long)totalBytes {
    double mb = ((double)totalBytes) / (1024.0 * 1024.0);
    if (mb >= 1.0) {
        _bytesLabel.text = [NSString stringWithFormat:@"%.2f MB indirildi", mb];
    } else {
        double kb = ((double)totalBytes) / 1024.0;
        _bytesLabel.text = [NSString stringWithFormat:@"%.1f KB indirildi", kb];
    }
}

- (void)ftpDownloaderDidFinish:(FTPDownloader *)downloader
                   destination:(NSString *)destination
                         bytes:(unsigned long long)totalBytes {
    _downloadButton.enabled = YES;
    _statusLabel.text = [NSString stringWithFormat:@"Tamamlandı:\n%@", destination];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"İndirme tamamlandı"
                                                    message:destination
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)ftpDownloader:(FTPDownloader *)downloader didFailWithError:(NSError *)error {
    _downloadButton.enabled = YES;
    _statusLabel.text = [NSString stringWithFormat:@"Hata: %@", [error localizedDescription]];

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"FTP Hatası"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)dealloc {
    _downloader.delegate = nil;
    [_downloader release];

    [_hostField release];
    [_portField release];
    [_userField release];
    [_passField release];
    [_remotePathField release];
    [_localNameField release];
    [_statusLabel release];
    [_bytesLabel release];
    [_downloadButton release];
    [_window release];

    [super dealloc];
}

@end
