#import "TicketViewController.h"

@implementation TicketViewController

- (UILabel *)labelWithFrame:(CGRect)frame size:(CGFloat)size bold:(BOOL)bold {
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumFontSize = 12.0f;
    return label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.96f alpha:1.0f];
    CGRect b = self.view.bounds;

    _apiClient = [[APIClient alloc] init];
    _apiClient.delegate = self;
    _qrScanner = [[QRScanner alloc] init];
    _qrScanner.delegate = self;

    _titleLabel = [[self labelWithFrame:CGRectMake(40, 32, b.size.width-80, 54) size:34 bold:YES] retain];
    _titleLabel.text = @"iPad1 Ticket";
    [self.view addSubview:_titleLabel];

    _statusLabel = [[self labelWithFrame:CGRectMake(80, 112, b.size.width-160, 72) size:32 bold:YES] retain];
    _statusLabel.text = @"QR kodunu okutun";
    [self.view addSubview:_statusLabel];

    _nameLabel = [[self labelWithFrame:CGRectMake(80, 210, b.size.width-160, 58) size:30 bold:YES] retain];
    [self.view addSubview:_nameLabel];

    _numberLabel = [[self labelWithFrame:CGRectMake(80, 280, b.size.width-160, 40) size:22 bold:NO] retain];
    [self.view addSubview:_numberLabel];
    _eventLabel = [[self labelWithFrame:CGRectMake(80, 330, b.size.width-160, 46) size:24 bold:YES] retain];
    [self.view addSubview:_eventLabel];
    _dateLabel = [[self labelWithFrame:CGRectMake(80, 385, b.size.width-160, 38) size:20 bold:NO] retain];
    [self.view addSubview:_dateLabel];
    _locationLabel = [[self labelWithFrame:CGRectMake(80, 430, b.size.width-160, 38) size:20 bold:NO] retain];
    [self.view addSubview:_locationLabel];

    _scanButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _scanButton.frame = CGRectMake((b.size.width-320)/2, b.size.height-190, 320, 64);
    _scanButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [_scanButton setTitle:@"QR KODU OKUT" forState:UIControlStateNormal];
    _scanButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [_scanButton addTarget:self action:@selector(scanPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanButton];

    _manualButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _manualButton.frame = CGRectMake((b.size.width-220)/2, b.size.height-110, 220, 44);
    _manualButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [_manualButton setTitle:@"Token Gir (Test)" forState:UIControlStateNormal];
    [_manualButton addTarget:self action:@selector(manualPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_manualButton];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.center = CGPointMake(b.size.width/2, 190);
    _spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:_spinner];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation { return YES; }

- (void)setBusy:(BOOL)busy {
    _scanButton.enabled = !busy;
    _manualButton.enabled = !busy;
    if (busy) [_spinner startAnimating]; else [_spinner stopAnimating];
}

- (void)clearDetails {
    _nameLabel.text = @""; _numberLabel.text = @""; _eventLabel.text = @"";
    _dateLabel.text = @""; _locationLabel.text = @"";
}

- (void)setStatusText:(NSString *)text color:(UIColor *)color {
    _statusLabel.text = text;
    _statusLabel.textColor = color;
}

- (void)scanPressed { [self clearDetails]; [_qrScanner presentScannerFromViewController:self]; }

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
- (void)qrScannerDidCancel {}

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
        _nameLabel.text = [self stringValue:[member objectForKey:@"name"] fallback:@"-"];
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
    _apiClient.delegate = nil; [_apiClient release];
    _qrScanner.delegate = nil; [_qrScanner release];
    [_titleLabel release]; [_statusLabel release]; [_nameLabel release]; [_numberLabel release];
    [_eventLabel release]; [_dateLabel release]; [_locationLabel release];
    [_scanButton release]; [_manualButton release]; [_spinner release];
    [super dealloc];
}
@end
