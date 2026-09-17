#import "AppDelegate.h"
#import "VNCClient.h"
#import "VNCView.h"

@interface AppDelegate () <VNCClientDelegate>
- (void)connectTapped;
- (void)keyboardTapped;
- (void)settingsTapped;
- (void)setControlsCollapsed:(BOOL)collapsed animated:(BOOL)animated;
- (void)saveConnectionSettings;
@end

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)application; (void)launchOptions;
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    _controller = [[UIViewController alloc] init];
    _controller.view.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];

    CGFloat w = _controller.view.bounds.size.width;
    _connectionPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 142)];
    _connectionPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _connectionPanel.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    [_controller.view addSubview:_connectionPanel];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    _hostField = [[UITextField alloc] initWithFrame:CGRectMake(20,20,w-230,38)];
    _hostField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _hostField.borderStyle = UITextBorderStyleRoundedRect;
    _hostField.placeholder = @"VNC host";
    _hostField.text = [defaults stringForKey:@"host"];
    _hostField.autocorrectionType = UITextAutocorrectionTypeNo;
    _hostField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_connectionPanel addSubview:_hostField];

    _portField = [[UITextField alloc] initWithFrame:CGRectMake(w-200,20,70,38)];
    _portField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _portField.borderStyle = UITextBorderStyleRoundedRect;
    _portField.keyboardType = UIKeyboardTypeNumberPad;
    NSString *savedPort = [defaults stringForKey:@"port"];
    _portField.text = ([savedPort length] ? savedPort : @"5901");
    [_connectionPanel addSubview:_portField];

    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20,66,w-230,38)];
    _passwordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passwordField.borderStyle = UITextBorderStyleRoundedRect;
    _passwordField.placeholder = @"VNC password";
    _passwordField.secureTextEntry = YES;
    _passwordField.text = [defaults stringForKey:@"password"];
    [_connectionPanel addSubview:_passwordField];

    _connectButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _connectButton.frame = CGRectMake(w-120,20,100,84);
    _connectButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_connectButton addTarget:self action:@selector(connectTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_connectButton];

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,108,w-190,28)];
    _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.font = [UIFont systemFontOfSize:13];
    _statusLabel.text = @"Ready";
    [_connectionPanel addSubview:_statusLabel];

    _keyboardButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _keyboardButton.frame = CGRectMake(w-165,106,75,32);
    _keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_keyboardButton setTitle:@"Keyboard" forState:UIControlStateNormal];
    [_keyboardButton addTarget:self action:@selector(keyboardTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_keyboardButton];

    _settingsButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _settingsButton.frame = CGRectMake(w-85,106,65,32);
    _settingsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_settingsButton setTitle:@"Hide" forState:UIControlStateNormal];
    [_settingsButton addTarget:self action:@selector(settingsTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_settingsButton];

    _keyboardField = [[UITextField alloc] initWithFrame:CGRectMake(-100,-100,10,10)];
    _keyboardField.delegate = self;
    _keyboardField.autocorrectionType = UITextAutocorrectionTypeNo;
    _keyboardField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_controller.view addSubview:_keyboardField];

    _vncView = [[VNCView alloc] initWithFrame:CGRectMake(0,142,w,_controller.view.bounds.size.height-142)];
    _vncView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_controller.view addSubview:_vncView];

    self.window.rootViewController = _controller;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)saveConnectionSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(_hostField.text ?: @"") forKey:@"host"];
    [defaults setObject:(_portField.text ?: @"5901") forKey:@"port"];
    [defaults setObject:(_passwordField.text ?: @"") forKey:@"password"];
    [defaults synchronize];
}

- (void)connectTapped {
    [_hostField resignFirstResponder];
    [_portField resignFirstResponder];
    [_passwordField resignFirstResponder];

    if (_client) { [_client disconnect]; [_client release]; _client=nil; }
    NSString *host = [_hostField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger port = [_portField.text integerValue];
    if ([host length]==0) { _statusLabel.text=@"Enter host"; return; }
    if (port<=0) { port=5901; _portField.text=@"5901"; }
    [self saveConnectionSettings];

    _client = [[VNCClient alloc] initWithHost:host port:port password:_passwordField.text ?: @""];
    _client.delegate = self;
    _vncView.client = _client;
    [_client connect];
}

- (void)keyboardTapped {
    if ([_keyboardField isFirstResponder]) {
        [_keyboardField resignFirstResponder];
        [_keyboardButton setTitle:@"Keyboard" forState:UIControlStateNormal];
    } else {
        [_keyboardField becomeFirstResponder];
        [_keyboardButton setTitle:@"Hide KB" forState:UIControlStateNormal];
    }
}

- (void)settingsTapped {
    [self setControlsCollapsed:!_controlsCollapsed animated:YES];
}

- (void)setControlsCollapsed:(BOOL)collapsed animated:(BOOL)animated {
    _controlsCollapsed = collapsed;
    CGFloat panelHeight = collapsed ? 42.0 : 142.0;
    CGFloat w = _controller.view.bounds.size.width;
    CGFloat h = _controller.view.bounds.size.height;

    if (animated) {
        [UIView beginAnimations:@"connectionPanel" context:NULL];
        [UIView setAnimationDuration:0.20];
    }

    CGRect pf = _connectionPanel.frame;
    pf.size.height = panelHeight;
    _connectionPanel.frame = pf;
    _hostField.alpha = collapsed ? 0.0 : 1.0;
    _portField.alpha = collapsed ? 0.0 : 1.0;
    _passwordField.alpha = collapsed ? 0.0 : 1.0;
    _connectButton.alpha = collapsed ? 0.0 : 1.0;

    _statusLabel.frame = CGRectMake(12, collapsed ? 7 : 108, w-190, 28);
    _keyboardButton.frame = CGRectMake(w-165, collapsed ? 5 : 106, 75, 32);
    _settingsButton.frame = CGRectMake(w-85, collapsed ? 5 : 106, 65, 32);
    [_settingsButton setTitle:(collapsed ? @"Setup" : @"Hide") forState:UIControlStateNormal];
    _vncView.frame = CGRectMake(0,panelHeight,w,h-panelHeight);

    if (animated) [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    (void)range;
    if (textField != _keyboardField || !_client) return YES;
    if ([string length]==0) {
        [_client sendKeySym:0xFF08 down:YES]; [_client sendKeySym:0xFF08 down:NO];
    } else {
        for (NSUInteger i=0;i<[string length];i++) {
            unichar c=[string characterAtIndex:i];
            uint32_t ks = (c=='\n') ? 0xFF0D : (uint32_t)c;
            [_client sendKeySym:ks down:YES]; [_client sendKeySym:ks down:NO];
        }
    }
    textField.text=@"";
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField==_keyboardField && _client) {
        [_client sendKeySym:0xFF0D down:YES]; [_client sendKeySym:0xFF0D down:NO];
    }
    return NO;
}

- (void)vncClientStatus:(NSString *)status {
    _statusLabel.text=status;
    if ([status isEqualToString:@"Connected"]) [self setControlsCollapsed:YES animated:YES];
}
- (void)vncClientFramebuffer:(UIImage *)image width:(NSUInteger)width height:(NSUInteger)height {
    (void)width;(void)height; [_vncView updateImage:image];
}
- (void)vncClientDisconnected:(NSString *)reason {
    _statusLabel.text=reason;
    [self setControlsCollapsed:NO animated:YES];
}

- (void)dealloc {
    [_client disconnect]; [_client release];
    [_vncView release]; [_keyboardField release]; [_settingsButton release]; [_keyboardButton release]; [_statusLabel release];
    [_connectButton release]; [_passwordField release]; [_portField release]; [_hostField release]; [_connectionPanel release];
    [_controller release]; [_window release];
    [super dealloc];
}
@end
