#import "AppDelegate.h"
#import "VNCClient.h"
#import "VNCView.h"

@interface RotationViewController : UIViewController
@end

@implementation RotationViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { (void)interfaceOrientation; return YES; }
- (BOOL)shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
@end

@interface AppDelegate () <VNCClientDelegate>
- (void)connectTapped;

- (void)profilesTapped {
    if(!_profiles){NSArray *saved=[[NSUserDefaults standardUserDefaults] arrayForKey:@"profiles"];_profiles=[[NSMutableArray alloc] initWithArray:(saved?saved:[NSArray array])];}
    UIActionSheet *sheet=[[[UIActionSheet alloc] initWithTitle:@"Connection Profiles" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    for(NSDictionary *p in _profiles)[sheet addButtonWithTitle:[p objectForKey:@"name"]];
    [sheet addButtonWithTitle:@"Save Current…"];
    sheet.cancelButtonIndex=[sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:_controller.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    (void)actionSheet;
    if(buttonIndex<0)return;
    if(buttonIndex<(NSInteger)[_profiles count]){[self loadProfileAtIndex:buttonIndex];return;}
    if(buttonIndex==(NSInteger)[_profiles count]){
        _savingProfilePrompt=YES;
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Save Profile" message:@"Profile name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil] autorelease];
        a.alertViewStyle=UIAlertViewStylePlainTextInput;[[a textFieldAtIndex:0] setText:_hostField.text];[a show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(!_savingProfilePrompt)return;_savingProfilePrompt=NO;if(buttonIndex==alertView.cancelButtonIndex)return;
    NSString *name=[[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(![name length])name=@"Server";[self saveProfileNamed:name];
}
- (void)saveProfileNamed:(NSString *)name {
    if(!_profiles)_profiles=[[NSMutableArray alloc] init];
    NSDictionary *p=[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",(_hostField.text?:@""),@"host",(_portField.text?:@"5901"),@"port",(_passwordField.text?:@""),@"password",[NSNumber numberWithInteger:_qualityControl.selectedSegmentIndex],@"quality",[NSNumber numberWithInteger:_inputModeControl.selectedSegmentIndex],@"input",[NSNumber numberWithFloat:_speedSlider.value],@"speed",nil];
    [_profiles addObject:p];[[NSUserDefaults standardUserDefaults] setObject:_profiles forKey:@"profiles"];[[NSUserDefaults standardUserDefaults] synchronize];_statusLabel.text=@"Profile saved";
}
- (void)loadProfileAtIndex:(NSInteger)index {
    if(index<0||index>=(NSInteger)[_profiles count])return;NSDictionary *p=[_profiles objectAtIndex:index];
    _hostField.text=[p objectForKey:@"host"];_portField.text=[p objectForKey:@"port"];_passwordField.text=[p objectForKey:@"password"];
    NSInteger q=[[p objectForKey:@"quality"] integerValue];if(q>=0&&q<=3)_qualityControl.selectedSegmentIndex=q;
    NSInteger im=[[p objectForKey:@"input"] integerValue];if(im>=0&&im<=1)_inputModeControl.selectedSegmentIndex=im;
    CGFloat sp=[[p objectForKey:@"speed"] floatValue];if(sp>=0.5&&sp<=1.5){_speedSlider.value=sp;_vncView.pointerSensitivity=sp;}
    _vncView.inputMode=(VNCInputMode)_inputModeControl.selectedSegmentIndex;[self saveConnectionSettings];_statusLabel.text=[NSString stringWithFormat:@"Loaded %@",[p objectForKey:@"name"]];
}

- (void)keyboardTapped;
- (void)filesTapped;
- (void)settingsTapped;
- (void)fullScreenTapped;
- (void)exitFullScreenTapped;
- (void)speedChanged;
- (void)qualityChanged;
- (void)inputModeChanged;
- (void)profilesTapped;
- (void)saveProfileNamed:(NSString *)name;
- (void)loadProfileAtIndex:(NSInteger)index;
- (void)setControlsCollapsed:(BOOL)collapsed animated:(BOOL)animated;
- (void)setFullScreen:(BOOL)fullScreen animated:(BOOL)animated;
- (void)saveConnectionSettings;
- (void)startConnection;
- (void)scheduleReconnect;
- (void)reconnectTimerFired:(NSTimer *)timer;
- (void)clipboardTimerFired:(NSTimer *)timer;
- (void)startClipboardTimer;
- (void)stopClipboardTimer;
- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;
- (void)specialKeyTapped:(UIButton *)sender;
- (void)sendKey:(uint32_t)keysym;
- (void)sendChordKey:(uint32_t)keysym ctrl:(BOOL)ctrl alt:(BOOL)alt;
- (void)refreshModifierButtons;
- (void)buildFilesPanel;
- (void)downloadTapped;
- (void)cancelDownloadTapped;
- (void)closeFilesTapped;
- (void)browseFilesTapped;
- (void)startDownloadFromURL:(NSURL *)url;
- (void)parseDirectoryHTML:(NSData *)data baseURL:(NSURL *)baseURL;
- (void)filesUpTapped;
- (void)startBrowseURL:(NSURL *)url;
- (void)refreshFileList;
- (NSString *)downloadsDirectory;
- (NSString *)uniqueDownloadPathForName:(NSString *)name;
@end

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)launchOptions;
    [application setStatusBarHidden:YES animated:NO];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    _controller = [[RotationViewController alloc] init];
    _controller.view.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];

    CGFloat w = _controller.view.bounds.size.width;
    CGFloat panelExpandedHeight = 260.0;
    _connectionPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, panelExpandedHeight)];
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

    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20,66,w-315,38)];
    _passwordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passwordField.borderStyle = UITextBorderStyleRoundedRect;
    _passwordField.placeholder = @"VNC password";
    _passwordField.secureTextEntry = YES;
    _passwordField.text = [defaults stringForKey:@"password"];
    [_connectionPanel addSubview:_passwordField];

    _profilesButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _profilesButton.frame = CGRectMake(w-285,66,75,38);
    _profilesButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_profilesButton setTitle:@"Profiles" forState:UIControlStateNormal];
    [_profilesButton addTarget:self action:@selector(profilesTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_profilesButton];

    _connectButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _connectButton.frame = CGRectMake(w-120,20,100,84);
    _connectButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [_connectButton addTarget:self action:@selector(connectTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_connectButton];

    CGFloat savedSpeed = [defaults floatForKey:@"pointerSpeed"];
    if (savedSpeed < 0.5 || savedSpeed > 1.5) savedSpeed = 1.0;
    _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,108,120,28)];
    _speedLabel.backgroundColor = [UIColor clearColor];
    _speedLabel.textColor = [UIColor whiteColor];
    _speedLabel.font = [UIFont systemFontOfSize:13];
    _speedLabel.text = [NSString stringWithFormat:@"Pointer %.1fx", savedSpeed];
    [_connectionPanel addSubview:_speedLabel];

    _speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(135,108,w-155,28)];
    _speedSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _speedSlider.minimumValue = 0.5f;
    _speedSlider.maximumValue = 1.5f;
    _speedSlider.value = savedSpeed;
    [_speedSlider addTarget:self action:@selector(speedChanged) forControlEvents:UIControlEventValueChanged];
    [_connectionPanel addSubview:_speedSlider];

    UILabel *qualityLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20,140,105,28)] autorelease];
    qualityLabel.backgroundColor = [UIColor clearColor];
    qualityLabel.textColor = [UIColor whiteColor];
    qualityLabel.font = [UIFont systemFontOfSize:13];
    qualityLabel.text = @"Quality"; qualityLabel.tag = 500;
    [_connectionPanel addSubview:qualityLabel];

    _qualityControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Auto",@"Fast",@"Balanced",@"Quality",nil]];
    _qualityControl.frame = CGRectMake(105,140,w-125,30);
    _qualityControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    NSInteger savedQuality;
    if ([defaults objectForKey:@"qualityMode"]) savedQuality=[defaults integerForKey:@"qualityMode"];
    else {
        NSInteger legacy=[defaults objectForKey:@"qualityProfile"]?[defaults integerForKey:@"qualityProfile"]:1;
        savedQuality=MIN(3,MAX(1,legacy+1));
    }
    if(savedQuality<0||savedQuality>3)savedQuality=0;
    _qualityControl.selectedSegmentIndex=savedQuality;
    [_qualityControl addTarget:self action:@selector(qualityChanged) forControlEvents:UIControlEventValueChanged];
    [_connectionPanel addSubview:_qualityControl];

    UILabel *inputLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20,176,105,28)] autorelease];
    inputLabel.backgroundColor=[UIColor clearColor]; inputLabel.textColor=[UIColor whiteColor];
    inputLabel.font=[UIFont systemFontOfSize:13]; inputLabel.text=@"Pointer Mode"; inputLabel.tag=501;
    [_connectionPanel addSubview:inputLabel];

    _inputModeControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Direct",@"Trackpad",nil]];
    _inputModeControl.frame=CGRectMake(105,176,220,30);
    NSInteger savedInput=[defaults objectForKey:@"inputMode"]?[defaults integerForKey:@"inputMode"]:0;
    if(savedInput<0||savedInput>1)savedInput=0;
    _inputModeControl.selectedSegmentIndex=savedInput;
    [_inputModeControl addTarget:self action:@selector(inputModeChanged) forControlEvents:UIControlEventValueChanged];
    [_connectionPanel addSubview:_inputModeControl];

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(335,176,w-760,30)];
    _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.font = [UIFont systemFontOfSize:13];
    _statusLabel.text = @"Ready";
    [_connectionPanel addSubview:_statusLabel];

    _keyboardButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _keyboardButton.frame = CGRectMake(w-425,218,80,32);
    _keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_keyboardButton setTitle:@"Keyboard" forState:UIControlStateNormal];
    [_keyboardButton addTarget:self action:@selector(keyboardTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_keyboardButton];

    _filesButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _filesButton.frame = CGRectMake(w-340,218,70,32);
    _filesButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_filesButton setTitle:@"Files" forState:UIControlStateNormal];
    [_filesButton addTarget:self action:@selector(filesTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_filesButton];

    _fullScreenButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _fullScreenButton.frame = CGRectMake(w-265,218,70,32);
    _fullScreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_fullScreenButton setTitle:@"Full" forState:UIControlStateNormal];
    [_fullScreenButton addTarget:self action:@selector(fullScreenTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_fullScreenButton];

    _settingsButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _settingsButton.frame = CGRectMake(w-190,218,170,32);
    _settingsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_settingsButton setTitle:@"Hide Setup" forState:UIControlStateNormal];
    [_settingsButton addTarget:self action:@selector(settingsTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_settingsButton];

    _keyboardField = [[UITextField alloc] initWithFrame:CGRectMake(-100,-100,10,10)];
    _keyboardField.delegate = self;
    _keyboardField.autocorrectionType = UITextAutocorrectionTypeNo;
    _keyboardField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _keyboardField.text = @" ";
    [_controller.view addSubview:_keyboardField];

    _vncView = [[VNCView alloc] initWithFrame:CGRectMake(0,panelExpandedHeight,w,_controller.view.bounds.size.height-panelExpandedHeight)];
    _vncView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _vncView.pointerSensitivity = savedSpeed;
    [_controller.view addSubview:_vncView];

    _exitFullScreenButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _exitFullScreenButton.frame = CGRectMake(w-78,6,70,34);
    _exitFullScreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    [_exitFullScreenButton setTitle:@"Menu" forState:UIControlStateNormal];
    [_exitFullScreenButton addTarget:self action:@selector(exitFullScreenTapped) forControlEvents:UIControlEventTouchUpInside];
    _exitFullScreenButton.alpha = 0.0;
    [_controller.view addSubview:_exitFullScreenButton];

    _keyBar = [[UIView alloc] initWithFrame:CGRectMake(4,_controller.view.bounds.size.height-42,w-8,38)];
    _keyBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    _keyBar.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.94];
    _keyBar.hidden = YES;
    NSArray *titles = [NSArray arrayWithObjects:@"Esc",@"Ctrl",@"Alt",@"Tab",@"←",@"↑",@"↓",@"→",@"⌫",@"Copy",@"Paste",nil];
    for (NSUInteger i=0;i<[titles count];i++) {
        UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        b.tag=100+(NSInteger)i;
        [b setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(specialKeyTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_keyBar addSubview:b];
    }
    [_controller.view addSubview:_keyBar];

    [self buildFilesPanel];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.window.rootViewController = _controller;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)layoutKeyBarButtons {
    CGFloat width = _keyBar.bounds.size.width;
    NSUInteger count = [[_keyBar subviews] count];
    if (!count) return;
    CGFloat bw = width/(CGFloat)count;
    for (NSUInteger i=0;i<count;i++) {
        UIView *v=[[_keyBar subviews] objectAtIndex:i];
        v.frame=CGRectMake(i*bw+1,2,bw-2,34);
    }
}

- (void)saveConnectionSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:(_hostField.text ?: @"") forKey:@"host"];
    [defaults setObject:(_portField.text ?: @"5901") forKey:@"port"];
    [defaults setObject:(_passwordField.text ?: @"") forKey:@"password"];
    [defaults setFloat:_speedSlider.value forKey:@"pointerSpeed"];
    [defaults setInteger:_qualityControl.selectedSegmentIndex forKey:@"qualityMode"];
    [defaults setInteger:_inputModeControl.selectedSegmentIndex forKey:@"inputMode"];
    [defaults synchronize];
}

- (void)connectTapped {
    [_hostField resignFirstResponder]; [_portField resignFirstResponder]; [_passwordField resignFirstResponder];
    NSString *host = [_hostField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger port = [_portField.text integerValue];
    if ([host length] == 0) { _statusLabel.text = @"Enter host"; return; }
    if (port <= 0) _portField.text = @"5901";
    _shouldAutoReconnect = YES;
    [self saveConnectionSettings];
    [self startConnection];
}

- (void)startConnection {
    if (_reconnectTimer) { [_reconnectTimer invalidate]; [_reconnectTimer release]; _reconnectTimer = nil; }
    if (_client) { _client.delegate=nil; [_client disconnect]; [_client release]; _client=nil; _vncView.client=nil; }
    NSString *host=[_hostField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger port=[_portField.text integerValue]; if(port<=0)port=5901;
    _statusLabel.text=@"Connecting…";
    _client=[[VNCClient alloc] initWithHost:host port:port password:_passwordField.text ?: @""];
    NSInteger qm=_qualityControl.selectedSegmentIndex;
    _client.adaptiveQualityEnabled=(qm==0);
    _client.qualityProfile=(qm==0?VNCQualityBalanced:(VNCQualityProfile)(qm-1));
    _vncView.inputMode=(VNCInputMode)_inputModeControl.selectedSegmentIndex;
    _client.delegate=self; _vncView.client=_client; [_client connect];
}

- (void)scheduleReconnect {
    if (!_shouldAutoReconnect || _reconnectTimer) return;
    _statusLabel.text=@"Disconnected — reconnecting in 3s…";
    _reconnectTimer=[[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(reconnectTimerFired:) userInfo:nil repeats:NO] retain];
}
- (void)reconnectTimerFired:(NSTimer *)timer { (void)timer; [_reconnectTimer release]; _reconnectTimer=nil; if(_shouldAutoReconnect)[self startConnection]; }

- (void)keyboardTapped {
    if ([_keyboardField isFirstResponder]) { [_keyboardField resignFirstResponder]; [_keyboardButton setTitle:@"Keyboard" forState:UIControlStateNormal]; }
    else { _keyboardField.text=@" "; [_keyboardField becomeFirstResponder]; [_keyboardButton setTitle:@"Hide KB" forState:UIControlStateNormal]; }
}
- (void)filesTapped { _filesPanel.hidden=NO; if(![_downloadURLField.text length]&&[_hostField.text length])_downloadURLField.text=[NSString stringWithFormat:@"http://%@:8085/",_hostField.text]; [self refreshFileList]; }
- (void)settingsTapped { [self setControlsCollapsed:!_controlsCollapsed animated:YES]; }
- (void)fullScreenTapped { [self setFullScreen:YES animated:YES]; }
- (void)exitFullScreenTapped { [self setFullScreen:NO animated:YES]; }
- (void)speedChanged { _vncView.pointerSensitivity=_speedSlider.value; _speedLabel.text=[NSString stringWithFormat:@"Pointer %.1fx",_speedSlider.value]; [self saveConnectionSettings]; }
- (void)qualityChanged { [self saveConnectionSettings]; _statusLabel.text = _client ? @"Quality mode saved — reconnect to apply" : @"Quality mode saved"; }
- (void)inputModeChanged { _vncView.inputMode=(VNCInputMode)_inputModeControl.selectedSegmentIndex; [self saveConnectionSettings]; _statusLabel.text=(_inputModeControl.selectedSegmentIndex?@"Trackpad mode":@"Direct touch mode"); }

- (void)setFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    _fullScreen=fullScreen; CGFloat w=_controller.view.bounds.size.width,h=_controller.view.bounds.size.height;
    if(animated){[UIView beginAnimations:@"fullScreen" context:NULL];[UIView setAnimationDuration:0.20];}
    _connectionPanel.alpha=fullScreen?0.0:1.0; _connectionPanel.userInteractionEnabled=!fullScreen; _exitFullScreenButton.alpha=fullScreen?0.82:0.0;
    if(fullScreen)_vncView.frame=CGRectMake(0,0,w,h); else [self setControlsCollapsed:YES animated:NO];
    if(animated)[UIView commitAnimations];
}

- (void)setControlsCollapsed:(BOOL)collapsed animated:(BOOL)animated {
    _controlsCollapsed=collapsed; CGFloat panelHeight=collapsed?42.0:260.0; CGFloat w=_controller.view.bounds.size.width,h=_controller.view.bounds.size.height;
    if(animated){[UIView beginAnimations:@"connectionPanel" context:NULL];[UIView setAnimationDuration:0.20];}
    CGRect pf=_connectionPanel.frame;pf.size.height=panelHeight;_connectionPanel.frame=pf;
    _hostField.alpha=collapsed?0:1;_portField.alpha=collapsed?0:1;_passwordField.alpha=collapsed?0:1;_connectButton.alpha=collapsed?0:1;_speedLabel.alpha=collapsed?0:1;_speedSlider.alpha=collapsed?0:1;_qualityControl.alpha=collapsed?0:1;_inputModeControl.alpha=collapsed?0:1;_profilesButton.alpha=collapsed?0:1;[_connectionPanel viewWithTag:500].alpha=collapsed?0:1;[_connectionPanel viewWithTag:501].alpha=collapsed?0:1;
    _statusLabel.frame=CGRectMake(12,collapsed?7:176,collapsed?w-445:w-360,28);
    _keyboardButton.frame=CGRectMake(w-425,collapsed?5:218,80,32);
    _filesButton.frame=CGRectMake(w-340,collapsed?5:218,70,32);
    _fullScreenButton.frame=CGRectMake(w-265,collapsed?5:218,70,32);
    _settingsButton.frame=CGRectMake(w-190,collapsed?5:218,170,32);
    [_settingsButton setTitle:(collapsed?@"Setup":@"Hide Setup") forState:UIControlStateNormal];
    _vncView.frame=CGRectMake(0,panelHeight,w,h-panelHeight);
    if(animated)[UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary *u=[note userInfo]; NSValue *value=[u objectForKey:UIKeyboardFrameEndUserInfoKey]; CGRect r=[value CGRectValue];
    r=[_controller.view convertRect:r fromView:nil]; CGFloat w=_controller.view.bounds.size.width;
    _keyBar.frame=CGRectMake(4,MAX(0,r.origin.y-40),w-8,38); _keyBar.hidden=NO; [self layoutKeyBarButtons];
}
- (void)keyboardWillHide:(NSNotification *)note { (void)note; _keyBar.hidden=YES; _ctrlArmed=NO; _altArmed=NO; [self refreshModifierButtons]; }

- (void)refreshModifierButtons {
    for(UIButton *b in [_keyBar subviews]) {
        if(b.tag==101)[b setTitle:(_ctrlArmed?@"Ctrl*":@"Ctrl") forState:UIControlStateNormal];
        if(b.tag==102)[b setTitle:(_altArmed?@"Alt*":@"Alt") forState:UIControlStateNormal];
    }
}
- (void)sendChordKey:(uint32_t)keysym ctrl:(BOOL)ctrl alt:(BOOL)alt {
    if(!_client)return; if(ctrl)[_client sendKeySym:0xFFE3 down:YES]; if(alt)[_client sendKeySym:0xFFE9 down:YES];
    [_client sendKeySym:keysym down:YES]; [_client sendKeySym:keysym down:NO];
    if(alt)[_client sendKeySym:0xFFE9 down:NO]; if(ctrl)[_client sendKeySym:0xFFE3 down:NO];
}
- (void)sendKey:(uint32_t)keysym { [self sendChordKey:keysym ctrl:_ctrlArmed alt:_altArmed]; _ctrlArmed=NO;_altArmed=NO;[self refreshModifierButtons]; }
- (void)specialKeyTapped:(UIButton *)sender {
    switch(sender.tag){
        case 100:[self sendKey:0xFF1B];break; case 101:_ctrlArmed=!_ctrlArmed;[self refreshModifierButtons];break; case 102:_altArmed=!_altArmed;[self refreshModifierButtons];break;
        case 103:[self sendKey:0xFF09];break; case 104:[self sendKey:0xFF51];break; case 105:[self sendKey:0xFF52];break; case 106:[self sendKey:0xFF54];break; case 107:[self sendKey:0xFF53];break;
        case 108:[self sendKey:0xFF08];break;
        case 109:[self sendChordKey:'c' ctrl:YES alt:NO];break;
        case 110:{ NSString *clip=[[UIPasteboard generalPasteboard] string]; if([clip length])[_client sendClipboardText:clip]; [self sendChordKey:'v' ctrl:YES alt:NO]; break; }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    (void)range; if(textField!=_keyboardField||!_client)return YES;
    if([string length]==0){
        [self sendKey:0xFF08];
    } else {
        for(NSUInteger i=0;i<[string length];i++){
            unichar c=[string characterAtIndex:i];
            [self sendKey:(c=='\n'?0xFF0D:(uint32_t)c)];
        }
    }
    /* Keep one invisible sentinel character so iOS 5 continues to emit delete events. */
    textField.text=@" ";
    return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField { if(textField==_keyboardField&&_client)[self sendKey:0xFF0D]; return NO; }

- (void)startClipboardTimer {
    [self stopClipboardTimer]; _lastPasteboardChangeCount=[[UIPasteboard generalPasteboard] changeCount];
    _clipboardTimer=[[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clipboardTimerFired:) userInfo:nil repeats:YES] retain];
}
- (void)stopClipboardTimer { if(_clipboardTimer){[_clipboardTimer invalidate];[_clipboardTimer release];_clipboardTimer=nil;} }
- (void)clipboardTimerFired:(NSTimer *)timer { (void)timer; UIPasteboard *pb=[UIPasteboard generalPasteboard]; NSInteger cc=[pb changeCount]; if(cc!=_lastPasteboardChangeCount){_lastPasteboardChangeCount=cc;NSString *s=[pb string];if([s length]&&_client)[_client sendClipboardText:s];} }

- (void)vncClientStatus:(NSString *)status {
    _statusLabel.text=status;
    if([status isEqualToString:@"Connected"]){if(_reconnectTimer){[_reconnectTimer invalidate];[_reconnectTimer release];_reconnectTimer=nil;}[self setControlsCollapsed:YES animated:YES];[self startClipboardTimer];}
}
- (void)vncClientFramebuffer:(UIImage *)image width:(NSUInteger)width height:(NSUInteger)height { (void)width;(void)height;[_vncView updateImage:image]; }
- (void)vncClientClipboardText:(NSString *)text { if(![text length])return; UIPasteboard *pb=[UIPasteboard generalPasteboard]; pb.string=text; _lastPasteboardChangeCount=[pb changeCount]; _statusLabel.text=@"Clipboard received"; }
- (void)vncClientDisconnected:(NSString *)reason {
    _statusLabel.text=reason;[self stopClipboardTimer];
    if(_client){_client.delegate=nil;[_client release];_client=nil;_vncView.client=nil;}
    if(!_fullScreen)[self setControlsCollapsed:YES animated:YES];[self scheduleReconnect];
}

- (NSString *)downloadsDirectory {
    NSString *dir=@"/var/mobile/Documents/iPad1VNC"; NSError *err=nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
    if(err){ NSString *fallback=[NSTemporaryDirectory() stringByAppendingPathComponent:@"iPad1VNC"]; [[NSFileManager defaultManager] createDirectoryAtPath:fallback withIntermediateDirectories:YES attributes:nil error:nil]; return fallback; }
    return dir;
}
- (NSString *)uniqueDownloadPathForName:(NSString *)name {
    NSString *safe=[name lastPathComponent]; if(![safe length])safe=@"download.bin";
    NSString *dir=[self downloadsDirectory]; NSString *path=[dir stringByAppendingPathComponent:safe];
    NSString *base=[safe stringByDeletingPathExtension],*ext=[safe pathExtension]; NSInteger n=2;
    while([[NSFileManager defaultManager] fileExistsAtPath:path]){NSString *candidate=[ext length]?[NSString stringWithFormat:@"%@-%ld.%@",base,(long)n,ext]:[NSString stringWithFormat:@"%@-%ld",base,(long)n];path=[dir stringByAppendingPathComponent:candidate];n++;}
    return path;
}
- (void)buildFilesPanel {
    CGFloat w=_controller.view.bounds.size.width,h=_controller.view.bounds.size.height,pw=MIN(760.0,w-20),ph=MIN(620.0,h-20);
    _filesPanel=[[UIView alloc] initWithFrame:CGRectMake((w-pw)/2,(h-ph)/2,pw,ph)];_filesPanel.autoresizingMask=(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin);_filesPanel.backgroundColor=[UIColor colorWithWhite:0.10 alpha:0.98];_filesPanel.hidden=YES;
    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(15,8,pw-220,30)] autorelease];title.backgroundColor=[UIColor clearColor];title.textColor=[UIColor whiteColor];title.text=@"Remote Files";title.font=[UIFont boldSystemFontOfSize:16];[_filesPanel addSubview:title];
    _filesUpButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];_filesUpButton.frame=CGRectMake(pw-190,6,80,32);[_filesUpButton setTitle:@"Up" forState:UIControlStateNormal];[_filesUpButton addTarget:self action:@selector(filesUpTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:_filesUpButton];
    UIButton *close=[UIButton buttonWithType:UIButtonTypeRoundedRect];close.frame=CGRectMake(pw-95,6,80,32);[close setTitle:@"Close" forState:UIControlStateNormal];[close addTarget:self action:@selector(closeFilesTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:close];
    _downloadURLField=[[UITextField alloc] initWithFrame:CGRectMake(15,44,pw-115,36)];_downloadURLField.borderStyle=UITextBorderStyleRoundedRect;_downloadURLField.placeholder=@"http://server:8085/";_downloadURLField.autocorrectionType=UITextAutocorrectionTypeNo;_downloadURLField.autocapitalizationType=UITextAutocapitalizationTypeNone;NSString *saved=[[NSUserDefaults standardUserDefaults] stringForKey:@"filesBaseURL"];if([saved length])_downloadURLField.text=saved;[_filesPanel addSubview:_downloadURLField];
    _browseFilesButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];_browseFilesButton.frame=CGRectMake(pw-95,44,80,36);[_browseFilesButton setTitle:@"Browse" forState:UIControlStateNormal];[_browseFilesButton addTarget:self action:@selector(browseFilesTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:_browseFilesButton];
    _remoteEntries=[[NSMutableArray alloc] init];_remoteFilesTable=[[UITableView alloc] initWithFrame:CGRectMake(15,88,pw-30,ph-250) style:UITableViewStylePlain];_remoteFilesTable.delegate=self;_remoteFilesTable.dataSource=self;[_filesPanel addSubview:_remoteFilesTable];
    _downloadProgress=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];_downloadProgress.frame=CGRectMake(15,ph-152,pw-120,18);[_filesPanel addSubview:_downloadProgress];
    UIButton *cancel=[UIButton buttonWithType:UIButtonTypeRoundedRect];cancel.frame=CGRectMake(pw-95,ph-163,80,34);[cancel setTitle:@"Cancel" forState:UIControlStateNormal];[cancel addTarget:self action:@selector(cancelDownloadTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:cancel];
    _downloadStatusLabel=[[UILabel alloc] initWithFrame:CGRectMake(15,ph-132,pw-30,22)];_downloadStatusLabel.backgroundColor=[UIColor clearColor];_downloadStatusLabel.textColor=[UIColor whiteColor];_downloadStatusLabel.font=[UIFont systemFontOfSize:12];_downloadStatusLabel.text=@"Tap Browse to list remote files.";[_filesPanel addSubview:_downloadStatusLabel];
    UILabel *local=[[[UILabel alloc] initWithFrame:CGRectMake(15,ph-108,pw-30,20)] autorelease];local.backgroundColor=[UIColor clearColor];local.textColor=[UIColor lightGrayColor];local.font=[UIFont boldSystemFontOfSize:12];local.text=@"Downloaded to /var/mobile/Documents/iPad1VNC";[_filesPanel addSubview:local];
    _fileListView=[[UITextView alloc] initWithFrame:CGRectMake(15,ph-86,pw-30,72)];_fileListView.editable=NO;_fileListView.font=[UIFont systemFontOfSize:11];[_filesPanel addSubview:_fileListView];[_controller.view addSubview:_filesPanel];
}
- (void)browseFilesTapped {NSString*u=[_downloadURLField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];if(![u length]&&[_hostField.text length])u=[NSString stringWithFormat:@"http://%@:8085/",_hostField.text];if(![u hasPrefix:@"http://"]&&![u hasPrefix:@"https://"])u=[@"http://" stringByAppendingString:u];if(![u hasSuffix:@"/"])u=[u stringByAppendingString:@"/"];NSURL*url=[NSURL URLWithString:u];if(!url){_downloadStatusLabel.text=@"Invalid server address";return;}_downloadURLField.text=u;[[NSUserDefaults standardUserDefaults] setObject:u forKey:@"filesBaseURL"];[[NSUserDefaults standardUserDefaults] synchronize];[_downloadURLField resignFirstResponder];[self startBrowseURL:url];}
- (void)startBrowseURL:(NSURL*)url {if(_browseConnection){[_browseConnection cancel];[_browseConnection release];_browseConnection=nil;}[_browseData release];_browseData=[[NSMutableData alloc]init];[_remoteBaseURL release];_remoteBaseURL=[url retain];_downloadStatusLabel.text=@"Loading remote files…";NSURLRequest*req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];_browseConnection=[[NSURLConnection alloc]initWithRequest:req delegate:self startImmediately:YES];}
- (void)filesUpTapped {if(!_remoteBaseURL)return;NSURL*up=[[NSURL URLWithString:@"../" relativeToURL:_remoteBaseURL] absoluteURL];[self startBrowseURL:up];}
- (void)parseDirectoryHTML:(NSData*)data baseURL:(NSURL*)baseURL {NSString*html=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];if(!html)html=[[[NSString alloc]initWithData:data encoding:NSISOLatin1StringEncoding]autorelease];[_remoteEntries removeAllObjects];if(!html){_downloadStatusLabel.text=@"Could not read directory.";[_remoteFilesTable reloadData];return;}NSRange search=NSMakeRange(0,[html length]);while(search.location<[html length]){NSRange href=[html rangeOfString:@"href=\"" options:NSCaseInsensitiveSearch range:search];if(href.location==NSNotFound)break;NSUInteger s=href.location+href.length;NSRange q=[html rangeOfString:@"\"" options:0 range:NSMakeRange(s,[html length]-s)];if(q.location==NSNotFound)break;NSString*link=[html substringWithRange:NSMakeRange(s,q.location-s)];search=NSMakeRange(q.location+1,[html length]-(q.location+1));if(![link length]||[link hasPrefix:@"?"]||[link hasPrefix:@"#"]||[link isEqualToString:@"../"])continue;NSString*name=[link stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];if(!name)name=link;BOOL dir=[name hasSuffix:@"/"];if(dir&&[name length]>1)name=[name substringToIndex:[name length]-1];NSURL*item=[[NSURL URLWithString:link relativeToURL:baseURL] absoluteURL];if(item)[_remoteEntries addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",item,@"url",[NSNumber numberWithBool:dir],@"dir",nil]];}[_remoteFilesTable reloadData];_downloadStatusLabel.text=([_remoteEntries count]?@"Tap folder to open or file to download.":@"Remote folder is empty.");}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {(void)section;return(tableView==_remoteFilesTable?[_remoteEntries count]:0);}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {static NSString*CID=@"RemoteFile";UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:CID];if(!cell)cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CID]autorelease];NSDictionary*e=[_remoteEntries objectAtIndex:indexPath.row];BOOL dir=[[e objectForKey:@"dir"] boolValue];cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",dir?@"[DIR]":@"↓",[e objectForKey:@"name"]];cell.accessoryType=dir?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;return cell;}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {if(tableView!=_remoteFilesTable)return;[tableView deselectRowAtIndexPath:indexPath animated:YES];NSDictionary*e=[_remoteEntries objectAtIndex:indexPath.row];if([[e objectForKey:@"dir"] boolValue])[self startBrowseURL:[e objectForKey:@"url"]];else[self startDownloadFromURL:[e objectForKey:@"url"]];}
- (void)startDownloadFromURL:(NSURL*)url {if(_downloadConnection||!url)return;NSString*name=[[url path] lastPathComponent];if(![name length])name=@"download.bin";_downloadPath=[[self uniqueDownloadPathForName:name] retain];[[NSFileManager defaultManager] createFileAtPath:_downloadPath contents:nil attributes:nil];_downloadHandle=[[NSFileHandle fileHandleForWritingAtPath:_downloadPath] retain];NSURLRequest*req=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];_downloadConnection=[[NSURLConnection alloc]initWithRequest:req delegate:self startImmediately:YES];_downloadExpected=0;_downloadReceived=0;_downloadProgress.progress=0;_downloadStatusLabel.text=[NSString stringWithFormat:@"Downloading %@…",name];}
- (void)refreshFileList {
    NSArray *items=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self downloadsDirectory] error:nil]; NSMutableString *s=[NSMutableString string];
    for(NSString *name in [items sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]){NSString *p=[[self downloadsDirectory] stringByAppendingPathComponent:name];NSDictionary *a=[[NSFileManager defaultManager] attributesOfItemAtPath:p error:nil];unsigned long long bytes=[[a objectForKey:NSFileSize] unsignedLongLongValue];[s appendFormat:@"%@   %.1f KB\n",name,(double)bytes/1024.0];}
    if(![s length])[s appendString:@"No downloaded files yet."];_fileListView.text=s;
}
- (void)downloadTapped {
    NSString *u=[_downloadURLField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self startDownloadFromURL:[NSURL URLWithString:u]];
}
- (void)cancelDownloadTapped { if(_downloadConnection){[_downloadConnection cancel];[_downloadConnection release];_downloadConnection=nil;}if(_downloadHandle){[_downloadHandle closeFile];[_downloadHandle release];_downloadHandle=nil;}if(_downloadPath){[[NSFileManager defaultManager] removeItemAtPath:_downloadPath error:nil];[_downloadPath release];_downloadPath=nil;}_downloadStatusLabel.text=@"Cancelled";_downloadProgress.progress=0; }
- (void)closeFilesTapped { [_downloadURLField resignFirstResponder]; _filesPanel.hidden=YES; }
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {if(connection==_browseConnection){[_browseData setLength:0];return;}if(connection==_downloadConnection){_downloadExpected=[response expectedContentLength];_downloadStatusLabel.text=[NSString stringWithFormat:@"Downloading %@",[_downloadPath lastPathComponent]];}}
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {if(connection==_browseConnection){[_browseData appendData:data];return;}if(connection==_downloadConnection){[_downloadHandle writeData:data];_downloadReceived+=[data length];if(_downloadExpected>0)_downloadProgress.progress=(float)((double)_downloadReceived/(double)_downloadExpected);_downloadStatusLabel.text=[NSString stringWithFormat:@"%.1f / %.1f MB",(double)_downloadReceived/1048576.0,(_downloadExpected>0?(double)_downloadExpected/1048576.0:0.0)];}}
- (void)connectionDidFinishLoading:(NSURLConnection*)connection {if(connection==_browseConnection){[self parseDirectoryHTML:_browseData baseURL:_remoteBaseURL];[_browseConnection release];_browseConnection=nil;[_browseData release];_browseData=nil;return;}if(connection==_downloadConnection){[_downloadHandle closeFile];[_downloadHandle release];_downloadHandle=nil;[_downloadConnection release];_downloadConnection=nil;_downloadProgress.progress=1.0;_downloadStatusLabel.text=[NSString stringWithFormat:@"Saved: %@",[_downloadPath lastPathComponent]];[_downloadPath release];_downloadPath=nil;[self refreshFileList];}}
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {if(connection==_browseConnection){[_browseConnection release];_browseConnection=nil;[_browseData release];_browseData=nil;_downloadStatusLabel.text=[NSString stringWithFormat:@"Browse failed: %@",[error localizedDescription]];return;}if(connection==_downloadConnection){if(_downloadHandle){[_downloadHandle closeFile];[_downloadHandle release];_downloadHandle=nil;}[_downloadConnection release];_downloadConnection=nil;if(_downloadPath){[[NSFileManager defaultManager] removeItemAtPath:_downloadPath error:nil];[_downloadPath release];_downloadPath=nil;}_downloadStatusLabel.text=[NSString stringWithFormat:@"Failed: %@",[error localizedDescription]];_downloadProgress.progress=0;}}
- (void)applicationDidEnterBackground:(UIApplication *)application { (void)application;if(_reconnectTimer){[_reconnectTimer invalidate];[_reconnectTimer release];_reconnectTimer=nil;}[self stopClipboardTimer]; }
- (void)applicationWillEnterForeground:(UIApplication *)application { (void)application;if(_shouldAutoReconnect&&!_client)[self scheduleReconnect];else if(_client)[self startClipboardTimer]; }

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];_shouldAutoReconnect=NO;[self stopClipboardTimer];
    if(_reconnectTimer){[_reconnectTimer invalidate];[_reconnectTimer release];}
    if(_downloadConnection){[_downloadConnection cancel];[_downloadConnection release];}if(_downloadHandle){[_downloadHandle closeFile];[_downloadHandle release];}[_downloadPath release];
    _client.delegate=nil;[_client disconnect];[_client release];
    [_filesPanel release];[_downloadURLField release];[_remoteFilesTable release];[_browseFilesButton release];[_filesUpButton release];[_remoteEntries release];[_remoteBaseURL release];[_browseData release];[_downloadStatusLabel release];[_downloadProgress release];[_fileListView release];[_keyBar release];
    [_exitFullScreenButton release];[_fullScreenButton release];[_settingsButton release];[_filesButton release];[_keyboardButton release];[_qualityControl release];[_inputModeControl release];[_profilesButton release];[_profiles release];[_speedSlider release];[_speedLabel release];
    [_vncView release];[_keyboardField release];[_statusLabel release];[_connectButton release];[_passwordField release];[_portField release];[_hostField release];[_connectionPanel release];[_controller release];[_window release];[super dealloc];
}
@end
