#import "TicketViewController.h"

@implementation TicketViewController

- (UILabel *)labelWithFrame:(CGRect)frame size:(CGFloat)size bold:(BOOL)bold {
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.65f;
    label.numberOfLines = 2;
    return label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.96f alpha:1.0f];
    CGRect b = self.view.bounds;
    CGFloat w = b.size.width;

    _apiClient = [[APIClient alloc] init];
    _apiClient.delegate = self;
    _qrScanner = [[QRScanner alloc] init];
    _qrScanner.delegate = self;

    _titleLabel = [[self labelWithFrame:CGRectMake(20, 45, w-40, 42) size:28 bold:YES] retain];
    _titleLabel.text = @"iPhone 6s Ticket";
    [self.view addSubview:_titleLabel];

    _statusLabel = [[self labelWithFrame:CGRectMake(20, 100, w-40, 60) size:22 bold:YES] retain];
    _statusLabel.text = @"QR kodunu okutun";
    [self.view addSubview:_statusLabel];

    _nameLabel = [[self labelWithFrame:CGRectMake(20, 185, w-40, 52) size:25 bold:YES] retain];
    [self.view addSubview:_nameLabel];

    _numberLabel = [[self labelWithFrame:CGRectMake(20, 240, w-40, 36) size:18 bold:NO] retain];
    [self.view addSubview:_numberLabel];

    _eventLabel = [[self labelWithFrame:CGRectMake(20, 290, w-40, 56) size:21 bold:YES] retain];
    [self.view addSubview:_eventLabel];

    _dateLabel = [[self labelWithFrame:CGRectMake(20, 350, w-40, 38) size:17 bold:NO] retain];
    [self.view addSubview:_dateLabel];

    _locationLabel = [[self labelWithFrame:CGRectMake(20, 392, w-40, 42) size:17 bold:NO] retain];
    [self.view addSubview:_locationLabel];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.center = CGPointMake(w/2, 170);
    _spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:_spinner];

    _scanButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _scanButton.frame = CGRectMake(28, b.size.height-145, w-56, 58);
    _scanButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_scanButton setTitle:@"QR KODU TARA" forState:UIControlStateNormal];
    _scanButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [_scanButton addTarget:self action:@selector(scanPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanButton];

    _manualButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _manualButton.frame = CGRectMake(28, b.size.height-78, w-56, 44);
    _manualButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_manualButton setTitle:@"Token Gir (Test)" forState:UIControlStateNormal];
    [_manualButton addTarget:self action:@selector(manualPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_manualButton];
}

- (BOOL)shouldAutorotate { return NO; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskPortrait; }

- (void)setBusy:(BOOL)busy {
    _scanButton.enabled = !busy;
    _manualButton.enabled = !busy;
    if (busy) [_spinner startAnimating]; else [_spinner stopAnimating];
}

- (void)clearDetails {
    _nameLabel.text = @"";
    _numberLabel.text = @"";
    _eventLabel.text = @"";
    _dateLabel.text = @"";
    _locationLabel.text = @"";
}

- (void)setStatusText:(NSString *)text color:(UIColor *)color {
    _statusLabel.text = text;
    _statusLabel.textColor = color;
}

- (void)scanPressed {
    [self clearDetails];
    [self setStatusText:@"QR kodunu okutun" color:[UIColor darkGrayColor]];
    [_qrScanner presentScannerFromViewController:self];
}

- (void)manualPressed {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"QR / Token"
                                                    message:@"QR icindeki URL'yi veya tokeni girin."
                                                   delegate:self
                                          cancelButtonTitle:@"Vazgec"
                                          otherButtonTitles:@"Dogrula", nil] autorelease];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *text = [[alertView textFieldAtIndex:0] text];
        [self qrScannerDidReadText:text];
    }
}

- (void)qrScannerDidReadText:(NSString *)text {
    [self clearDetails];
    [self setStatusText:@"Dogrulaniyor..." color:[UIColor darkGrayColor]];
    [self setBusy:YES];
    [_apiClient verifyQRCodeText:text];
}

- (void)qrScannerDidCancel {
    [self setStatusText:@"Tarama iptal edildi" color:[UIColor darkGrayColor]];
}

- (NSString *)stringValue:(id)value fallback:(NSString *)fallback {
    if ([value isKindOfClass:[NSString class]] && [(NSString *)value length] > 0) return value;
    if ([value respondsToSelector:@selector(stringValue)]) return [value stringValue];
    return fallback;
}

- (void)apiClientDidReceiveResult:(NSDictionary *)result {
    [self setBusy:NO];
    NSString *status = [self stringValue:[result objectForKey:@"status"] fallback:@"error"];
    NSDictionary *member = [result objectForKey:@"member"];
    NSDictionary *event = [result objectForKey:@"event"];

    if ([status isEqualToString:@"checked_in"]) {
        [self setStatusText:@"✓ KATILIM ONAYLANDI" color:[UIColor colorWithRed:0.08f green:0.55f blue:0.18f alpha:1.0f]];
    } else if ([status isEqualToString:@"already_used"]) {
        [self setStatusText:@"! DAHA ONCE OKUTULDU" color:[UIColor colorWithRed:0.85f green:0.50f blue:0.05f alpha:1.0f]];
    } else {
        NSString *message = [self stringValue:[result objectForKey:@"message"] fallback:@"Gecersiz QR"];
        [self setStatusText:message color:[UIColor colorWithRed:0.75f green:0.08f blue:0.08f alpha:1.0f]];
    }

    if ([member isKindOfClass:[NSDictionary class]]) {
        NSString *fullName = [self stringValue:[member objectForKey:@"name"] fallback:nil];
        if (![fullName length]) {
            NSString *first = [self stringValue:[member objectForKey:@"first_name"] fallback:@""];
            NSString *last = [self stringValue:[member objectForKey:@"last_name"] fallback:@""];
            fullName = [NSString stringWithFormat:@"%@ %@", first, last];
        }
        _nameLabel.text = fullName;
        _numberLabel.text = [NSString stringWithFormat:@"Sira No: %@", [self stringValue:[member objectForKey:@"member_no"] fallback:@"-"]];
    }

    if ([event isKindOfClass:[NSDictionary class]]) {
        _eventLabel.text = [self stringValue:[event objectForKey:@"title"] fallback:@"-"];
        _dateLabel.text = [self stringValue:[event objectForKey:@"event_at"] fallback:@"-"];
        NSString *loc = [self stringValue:[event objectForKey:@"location"] fallback:@""];
        _locationLabel.text = [loc length] ? [NSString stringWithFormat:@"Konum: %@", loc] : @"";
    }
}

- (void)apiClientDidFailWithMessage:(NSString *)message {
    [self setBusy:NO];
    [self clearDetails];
    [self setStatusText:message color:[UIColor colorWithRed:0.75f green:0.08f blue:0.08f alpha:1.0f]];
}

- (void)dealloc {
    _apiClient.delegate = nil;
    [_apiClient release];
    _qrScanner.delegate = nil;
    [_qrScanner release];
    [_titleLabel release];
    [_statusLabel release];
    [_nameLabel release];
    [_numberLabel release];
    [_eventLabel release];
    [_dateLabel release];
    [_locationLabel release];
    [_scanButton release];
    [_manualButton release];
    [_spinner release];
    [super dealloc];
}
@end
