#import "AppDelegate.h"
#import "VNCClient.h"
#import "VNCView.h"
#import "TerminalSession.h"

@interface RotationViewController : UIViewController
@end

@implementation RotationViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { (void)interfaceOrientation; return YES; }
- (BOOL)shouldAutorotate { return YES; }
- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAll; }
@end

@interface AppDelegate () <VNCClientDelegate, TerminalSessionDelegate>
- (void)connectTapped;
- (void)terminalTapped;
- (void)closeTerminalTapped;
- (void)terminalSendTapped;
- (void)buildTerminalPanel;
- (void)tightChanged;
- (void)manageProfilesTapped;
- (void)deleteProfileAtIndex:(NSInteger)index;
- (void)renameRemoteEntry:(NSDictionary *)entry;
- (void)deleteRemoteEntry:(NSDictionary *)entry;
- (void)mkdirRemote;
- (void)uploadLocalFile;
- (void)performFileAPIPath:(NSString *)path method:(NSString *)method body:(NSData *)body contentType:(NSString *)contentType;


- (void)tightChanged { [self saveConnectionSettings]; _statusLabel.text=@"Tight preference saved — reconnect to apply"; }
- (void)vncClientStatsFPS:(CGFloat)fps kbps:(CGFloat)kbps encoding:(NSString*)encoding quality:(NSString*)quality {
    _statsLabel.text=[NSString stringWithFormat:@"%.1f FPS | %.0f kbps | %@ | %@",fps,kbps,encoding,quality];
}

- (void)buildTerminalPanel {
    if(_terminalPanel)return;
    CGFloat w=_controller.view.bounds.size.width,h=_controller.view.bounds.size.height,pw=MIN(900.0,w-20),ph=MIN(680.0,h-20);
    _terminalPanel=[[UIView alloc] initWithFrame:CGRectMake((w-pw)/2,(h-ph)/2,pw,ph)];
    _terminalPanel.autoresizingMask=(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);_terminalPanel.backgroundColor=[UIColor colorWithWhite:0.06 alpha:0.98];_terminalPanel.hidden=YES;
    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(14,8,180,30)] autorelease];title.backgroundColor=[UIColor clearColor];title.textColor=[UIColor whiteColor];title.text=@"SSH Terminal";title.font=[UIFont boldSystemFontOfSize:16];[_terminalPanel addSubview:title];
    UIButton *close=[UIButton buttonWithType:UIButtonTypeRoundedRect];close.frame=CGRectMake(pw-90,6,76,32);[close setTitle:@"Close" forState:UIControlStateNormal];[close addTarget:self action:@selector(closeTerminalTapped) forControlEvents:UIControlEventTouchUpInside];[_terminalPanel addSubview:close];

    _sshUserField=[[UITextField alloc] initWithFrame:CGRectMake(14,44,120,34)];_sshUserField.borderStyle=UITextBorderStyleRoundedRect;_sshUserField.placeholder=@"SSH user";_sshUserField.text=[[NSUserDefaults standardUserDefaults] stringForKey:@"sshUser"];[_terminalPanel addSubview:_sshUserField];
    _sshPortField=[[UITextField alloc] initWithFrame:CGRectMake(140,44,70,34)];_sshPortField.borderStyle=UITextBorderStyleRoundedRect;_sshPortField.keyboardType=UIKeyboardTypeNumberPad;_sshPortField.placeholder=@"22";NSString*sp=[[NSUserDefaults standardUserDefaults]stringForKey:@"sshPort"];_sshPortField.text=([sp length]?sp:@"22");[_terminalPanel addSubview:_sshPortField];
    _sshKeyField=[[UITextField alloc] initWithFrame:CGRectMake(216,44,pw-430,34)];_sshKeyField.borderStyle=UITextBorderStyleRoundedRect;_sshKeyField.placeholder=@"/var/mobile/.ssh/id_rsa";_sshKeyField.text=[[NSUserDefaults standardUserDefaults]stringForKey:@"sshKey"];[_terminalPanel addSubview:_sshKeyField];
    UILabel *tl=[[[UILabel alloc]initWithFrame:CGRectMake(pw-205,46,90,30)]autorelease];tl.backgroundColor=[UIColor clearColor];tl.textColor=[UIColor whiteColor];tl.font=[UIFont systemFontOfSize:12];tl.text=@"VNC Tunnel";[_terminalPanel addSubview:tl];
    _sshTunnelSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(pw-105,44,90,30)];_sshTunnelSwitch.on=[[NSUserDefaults standardUserDefaults] boolForKey:@"sshTunnel"];[_terminalPanel addSubview:_sshTunnelSwitch];

    _terminalView=[[UITextView alloc] initWithFrame:CGRectMake(14,84,pw-28,ph-150)];_terminalView.backgroundColor=[UIColor blackColor];_terminalView.textColor=[UIColor whiteColor];_terminalView.font=[UIFont fontWithName:@"Courier" size:13];_terminalView.editable=NO;[_terminalPanel addSubview:_terminalView];
    _terminalInput=[[UITextField alloc] initWithFrame:CGRectMake(14,ph-58,pw-110,40)];_terminalInput.borderStyle=UITextBorderStyleRoundedRect;_terminalInput.placeholder=@"Command…";_terminalInput.delegate=self;[_terminalPanel addSubview:_terminalInput];
    UIButton *send=[UIButton buttonWithType:UIButtonTypeRoundedRect];send.frame=CGRectMake(pw-90,ph-58,76,40);[send setTitle:@"Send" forState:UIControlStateNormal];[send addTarget:self action:@selector(terminalSendTapped) forControlEvents:UIControlEventTouchUpInside];[_terminalPanel addSubview:send];
    [_controller.view addSubview:_terminalPanel];
}
- (void)terminalTapped {
    [self buildTerminalPanel];_terminalPanel.hidden=NO;[_controller.view bringSubviewToFront:_terminalPanel];
    if(!_terminalSession)_terminalSession=[[TerminalSession alloc] init];_terminalSession.delegate=self;
    if(!_terminalSession.running && [_hostField.text length]){
        NSInteger port=[_sshPortField.text integerValue];if(port<=0)port=22;
        [[NSUserDefaults standardUserDefaults] setObject:_sshUserField.text forKey:@"sshUser"];
        [[NSUserDefaults standardUserDefaults] setObject:_sshPortField.text forKey:@"sshPort"];
        [[NSUserDefaults standardUserDefaults] setObject:_sshKeyField.text forKey:@"sshKey"];
        [[NSUserDefaults standardUserDefaults] setBool:_sshTunnelSwitch.on forKey:@"sshTunnel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [_terminalSession startSSHHost:_hostField.text port:port user:_sshUserField.text keyPath:_sshKeyField.text command:nil];
    }
}
- (void)closeTerminalTapped {_terminalPanel.hidden=YES;}
- (void)terminalSendTapped {NSString *s=_terminalInput.text;if(![s length])return;[_terminalSession sendText:[s stringByAppendingString:@"\n"]];_terminalInput.text=@"";}
- (void)terminalSessionOutput:(NSString*)text {if(![text length])return;_terminalView.text=[_terminalView.text stringByAppendingString:text];NSRange r=NSMakeRange([_terminalView.text length],0);[_terminalView scrollRangeToVisible:r];}
- (void)terminalSessionEnded:(NSString*)reason {if(_terminalView)_terminalView.text=[_terminalView.text stringByAppendingFormat:@"\n[%@]\n",reason];}

- (void)keyboardTapped;
- (void)filesTapped;
- (void)settingsTapped {
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"SSH / Security" message:@"SSH user, port and key can be edited in the Terminal panel. Enable tunnel there before connecting. Tight can be toggled in Setup." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [a show];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex<0)return;
    if(actionSheet.tag==920){
        if(_selectedRemoteIndex<0||_selectedRemoteIndex>=(NSInteger)[_remoteEntries count])return;
        NSDictionary *e=[_remoteEntries objectAtIndex:_selectedRemoteIndex];
        if(buttonIndex==0){[self deleteRemoteEntry:e];return;}
        if(buttonIndex==1){[self startDownloadFromURL:[self downloadURLForEntry:e]];return;}
        if(buttonIndex==2){[self renameRemoteEntry:e];return;}
        return;
    }
    if(actionSheet.tag==921){
        NSArray *files=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self downloadsDirectory] error:nil];
        if(buttonIndex>=0&&buttonIndex<(NSInteger)[files count]){
            NSString *name=[files objectAtIndex:buttonIndex],*lp=[[self downloadsDirectory] stringByAppendingPathComponent:name];
            NSData *body=[NSData dataWithContentsOfFile:lp];if(!body)return;
            NSString *rp=([_remoteRelativePath length]?[_remoteRelativePath stringByAppendingPathComponent:name]:name);
            NSString *esc=[rp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self performFileAPIPath:[NSString stringWithFormat:@"/api/upload?path=%@",esc] method:@"POST" body:body contentType:@"application/octet-stream"];
        }
        return;
    }
    (void)actionSheet;
    if(buttonIndex<(NSInteger)[_profiles count]){[self loadProfileAtIndex:buttonIndex];return;}
    if(_profileManageMode){
        _profileManageMode=NO;
        if(buttonIndex<(NSInteger)[_profiles count]){
            _selectedProfileIndex=buttonIndex;
            UIActionSheet *m=[[[UIActionSheet alloc] initWithTitle:[[ _profiles objectAtIndex:buttonIndex] objectForKey:@"name"] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Load",nil] autorelease];
            m.tag=901;[m showInView:_controller.view];
        }
        return;
    }
    if(actionSheet.tag==901){
        if(buttonIndex==0){[self deleteProfileAtIndex:_selectedProfileIndex];return;}
        if(buttonIndex==1){[self loadProfileAtIndex:_selectedProfileIndex];return;}
        return;
    }
    if(buttonIndex==(NSInteger)[_profiles count]){
        _savingProfilePrompt=YES;
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Save Profile" message:@"Profile name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil] autorelease];
        a.alertViewStyle=UIAlertViewStylePlainTextInput;[[a textFieldAtIndex:0] setText:_hostField.text];[a show];
        return;
    }
    if(buttonIndex==(NSInteger)[_profiles count]+1){
        _profileManageMode=YES;
        UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Choose profile to manage" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
        for(NSDictionary *p in _profiles)[s addButtonWithTitle:[p objectForKey:@"name"]];
        s.cancelButtonIndex=[s addButtonWithTitle:@"Cancel"];[s showInView:_controller.view];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag==930){
        if(buttonIndex==alertView.cancelButtonIndex)return;NSString *name=[[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];if(![name length])return;
        NSString *rp=([_remoteRelativePath length]?[_remoteRelativePath stringByAppendingPathComponent:name]:name);NSData*b=[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObject:rp forKey:@"path"] options:0 error:nil];[self performFileAPIPath:@"/api/mkdir" method:@"POST" body:b contentType:@"application/json"];return;
    }
    if(alertView.tag==931){
        if(buttonIndex==alertView.cancelButtonIndex||_selectedRemoteIndex<0||_selectedRemoteIndex>=(NSInteger)[_remoteEntries count])return;
        NSDictionary *e=[_remoteEntries objectAtIndex:_selectedRemoteIndex];NSString *newName=[[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];if(![newName length])return;
        NSString *from=[self remotePathForEntry:e];NSString *to=([_remoteRelativePath length]?[_remoteRelativePath stringByAppendingPathComponent:newName]:newName);
        NSDictionary *o=[NSDictionary dictionaryWithObjectsAndKeys:from,@"from",to,@"to",nil];NSData*b=[NSJSONSerialization dataWithJSONObject:o options:0 error:nil];[self performFileAPIPath:@"/api/rename" method:@"POST" body:b contentType:@"application/json"];return;
    }
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

- (void)deleteProfileAtIndex:(NSInteger)index {
    if(index<0||index>=(NSInteger)[_profiles count])return;
    NSString *name=[[_profiles objectAtIndex:index] objectForKey:@"name"];
    [_profiles removeObjectAtIndex:index];
    [[NSUserDefaults standardUserDefaults] setObject:_profiles forKey:@"profiles"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _statusLabel.text=[NSString stringWithFormat:@"Deleted %@",name];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    (void)launchOptions;
    [application setStatusBarHidden:YES animated:NO];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    _controller = [[RotationViewController alloc] init];
    _controller.view.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];

    CGFloat w = _controller.view.bounds.size.width;
    CGFloat panelExpandedHeight = 292.0;
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
    _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,112,120,26)];
    _speedLabel.backgroundColor = [UIColor clearColor];
    _speedLabel.textColor = [UIColor whiteColor];
    _speedLabel.font = [UIFont systemFontOfSize:13];
    _speedLabel.text = [NSString stringWithFormat:@"Pointer %.1fx", savedSpeed];
    [_connectionPanel addSubview:_speedLabel];

    _speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(135,112,w-155,26)];
    _speedSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _speedSlider.minimumValue = 0.5f;
    _speedSlider.maximumValue = 1.5f;
    _speedSlider.value = savedSpeed;
    [_speedSlider addTarget:self action:@selector(speedChanged) forControlEvents:UIControlEventValueChanged];
    [_connectionPanel addSubview:_speedSlider];

    UILabel *qualityLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20,146,80,28)] autorelease];
    qualityLabel.backgroundColor = [UIColor clearColor];
    qualityLabel.textColor = [UIColor whiteColor];
    qualityLabel.font = [UIFont systemFontOfSize:13];
    qualityLabel.text = @"Quality"; qualityLabel.tag = 500;
    [_connectionPanel addSubview:qualityLabel];

    _qualityControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Auto",@"Fast",@"Balanced",@"Quality",nil]];
    _qualityControl.frame = CGRectMake(105,146,w-125,30);
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

    UILabel *inputLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20,184,80,28)] autorelease];
    inputLabel.backgroundColor=[UIColor clearColor]; inputLabel.textColor=[UIColor whiteColor];
    inputLabel.font=[UIFont systemFontOfSize:13]; inputLabel.text=@"Pointer Mode"; inputLabel.tag=501;
    [_connectionPanel addSubview:inputLabel];

    _inputModeControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Direct",@"Trackpad",nil]];
    _inputModeControl.frame=CGRectMake(105,184,220,30);
    NSInteger savedInput=[defaults objectForKey:@"inputMode"]?[defaults integerForKey:@"inputMode"]:0;
    if(savedInput<0||savedInput>1)savedInput=0;
    _inputModeControl.selectedSegmentIndex=savedInput;
    [_inputModeControl addTarget:self action:@selector(inputModeChanged) forControlEvents:UIControlEventValueChanged];
    [_connectionPanel addSubview:_inputModeControl];

    UILabel *tightLabel=[[[UILabel alloc] initWithFrame:CGRectMake(20,216,80,28)] autorelease];
    tightLabel.backgroundColor=[UIColor clearColor];tightLabel.textColor=[UIColor whiteColor];tightLabel.font=[UIFont systemFontOfSize:13];tightLabel.text=@"Tight";tightLabel.tag=502;[_connectionPanel addSubview:tightLabel];
    _tightSwitch=[[UISwitch alloc] initWithFrame:CGRectMake(105,216,80,28)];
    _tightSwitch.on=[defaults objectForKey:@"preferTight"]?[defaults boolForKey:@"preferTight"]:NO;
    [_tightSwitch addTarget:self action:@selector(tightChanged) forControlEvents:UIControlEventValueChanged];[_connectionPanel addSubview:_tightSwitch];

    _statsLabel=[[UILabel alloc] initWithFrame:CGRectMake(190,216,w-210,28)];
    _statsLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;_statsLabel.backgroundColor=[UIColor clearColor];
    _statsLabel.textColor=[UIColor lightGrayColor];_statsLabel.font=[UIFont systemFontOfSize:12];_statsLabel.text=@"FPS -- | -- kbps | --";[_connectionPanel addSubview:_statsLabel];

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(340,184,w-360,30)];
    _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.font = [UIFont systemFontOfSize:13];
    _statusLabel.text = @"Ready";
    [_connectionPanel addSubview:_statusLabel];

    _keyboardButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _keyboardButton.frame = CGRectMake(w-515,248,80,34);
    _keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_keyboardButton setTitle:@"Keyboard" forState:UIControlStateNormal];
    [_keyboardButton addTarget:self action:@selector(keyboardTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_keyboardButton];

    _filesButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _filesButton.frame = CGRectMake(w-425,248,80,34);
    _filesButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_filesButton setTitle:@"Files" forState:UIControlStateNormal];
    [_filesButton addTarget:self action:@selector(filesTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_filesButton];

    _terminalButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _terminalButton.frame=CGRectMake(w-605,248,80,34);_terminalButton.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
    [_terminalButton setTitle:@"Terminal" forState:UIControlStateNormal];[_terminalButton addTarget:self action:@selector(terminalTapped) forControlEvents:UIControlEventTouchUpInside];[_connectionPanel addSubview:_terminalButton];

    _fullScreenButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _fullScreenButton.frame = CGRectMake(w-335,248,80,34);
    _fullScreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_fullScreenButton setTitle:@"Full" forState:UIControlStateNormal];
    [_fullScreenButton addTarget:self action:@selector(fullScreenTapped) forControlEvents:UIControlEventTouchUpInside];
    [_connectionPanel addSubview:_fullScreenButton];

    _settingsButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _settingsButton.frame = CGRectMake(w-245,248,225,34);
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
    [self buildTerminalPanel];

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
    [defaults setBool:_tightSwitch.on forKey:@"preferTight"];
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
    [self saveConnectionSettings];
    NSString *host=[_hostField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger port=[_portField.text integerValue];if(![host length]||port<=0){_statusLabel.text=@"Host/port required";return;}
    [_client disconnect];[_client release];_client=nil;
    NSString *connectHost=host;NSInteger connectPort=port;

    if(_sshTunnelSwitch && _sshTunnelSwitch.on){
        if(!_tunnelSession)_tunnelSession=[[TerminalSession alloc] init];
        _tunnelSession.delegate=self;
        _tunnelLocalPort=15901;
        NSInteger sshPort=[_sshPortField.text integerValue];if(sshPort<=0)sshPort=22;
        if(![_sshKeyField.text length]){_statusLabel.text=@"SSH tunnel needs key path";return;}
        BOOL tunnelOK=[_tunnelSession startTunnelHost:host port:sshPort user:_sshUserField.text keyPath:_sshKeyField.text localPort:_tunnelLocalPort remoteHost:@"127.0.0.1" remotePort:port];
        if(!tunnelOK){_statusLabel.text=@"SSH tunnel failed";return;}
        connectHost=@"127.0.0.1";connectPort=_tunnelLocalPort;
        _statusLabel.text=@"Opening SSH tunnel…";
        [NSThread sleepForTimeInterval:0.8];
    }

    _client=[[VNCClient alloc] initWithHost:connectHost port:connectPort password:_passwordField.text ?: @""];
    _client.delegate=self;
    NSInteger qm=_qualityControl.selectedSegmentIndex;
    _client.adaptiveQualityEnabled=(qm==0);
    _client.qualityProfile=(qm==0?VNCQualityBalanced:(VNCQualityProfile)(qm-1));
    _client.preferTight=_tightSwitch.on;
    _vncView.client=_client;_vncView.inputMode=(VNCInputMode)_inputModeControl.selectedSegmentIndex;
    _shouldAutoReconnect=YES;[_connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [_client connect];
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
    _controlsCollapsed=collapsed; CGFloat panelHeight=collapsed?42.0:292.0; CGFloat w=_controller.view.bounds.size.width,h=_controller.view.bounds.size.height;
    if(animated){[UIView beginAnimations:@"connectionPanel" context:NULL];[UIView setAnimationDuration:0.20];}
    CGRect pf=_connectionPanel.frame;pf.size.height=panelHeight;_connectionPanel.frame=pf;
    _hostField.alpha=collapsed?0:1;_portField.alpha=collapsed?0:1;_passwordField.alpha=collapsed?0:1;_connectButton.alpha=collapsed?0:1;_speedLabel.alpha=collapsed?0:1;_speedSlider.alpha=collapsed?0:1;_qualityControl.alpha=collapsed?0:1;_inputModeControl.alpha=collapsed?0:1;_profilesButton.alpha=collapsed?0:1;_tightSwitch.alpha=collapsed?0:1;_statsLabel.alpha=collapsed?0:1;[_connectionPanel viewWithTag:500].alpha=collapsed?0:1;[_connectionPanel viewWithTag:501].alpha=collapsed?0:1;[_connectionPanel viewWithTag:502].alpha=collapsed?0:1;
    _statusLabel.frame=CGRectMake(12,collapsed?7:184,collapsed?w-620:w-360,28);
    _keyboardButton.frame=CGRectMake(w-515,collapsed?5:248,80,34);
    _terminalButton.frame=CGRectMake(w-605,collapsed?5:248,80,34);
    _filesButton.frame=CGRectMake(w-425,collapsed?5:248,80,34);
    _fullScreenButton.frame=CGRectMake(w-335,collapsed?5:248,80,34);
    _settingsButton.frame=CGRectMake(w-245,collapsed?5:248,225,34);
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
    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(15,8,pw-300,30)] autorelease];title.backgroundColor=[UIColor clearColor];title.textColor=[UIColor whiteColor];title.text=@"Remote Files";title.font=[UIFont boldSystemFontOfSize:16];[_filesPanel addSubview:title];
    _filesUpButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];_filesUpButton.frame=CGRectMake(pw-280,6,60,32);[_filesUpButton setTitle:@"Up" forState:UIControlStateNormal];[_filesUpButton addTarget:self action:@selector(filesUpTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:_filesUpButton];
    UIButton *mkdir=[UIButton buttonWithType:UIButtonTypeRoundedRect];mkdir.frame=CGRectMake(pw-215,6,60,32);[mkdir setTitle:@"New" forState:UIControlStateNormal];[mkdir addTarget:self action:@selector(mkdirRemote) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:mkdir];
    UIButton *upload=[UIButton buttonWithType:UIButtonTypeRoundedRect];upload.frame=CGRectMake(pw-150,6,60,32);[upload setTitle:@"Upload" forState:UIControlStateNormal];[upload addTarget:self action:@selector(uploadLocalFile) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:upload];
    UIButton *close=[UIButton buttonWithType:UIButtonTypeRoundedRect];close.frame=CGRectMake(pw-85,6,70,32);[close setTitle:@"Close" forState:UIControlStateNormal];[close addTarget:self action:@selector(closeFilesTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:close];

    _downloadURLField=[[UITextField alloc] initWithFrame:CGRectMake(15,44,pw-230,34)];_downloadURLField.borderStyle=UITextBorderStyleRoundedRect;_downloadURLField.placeholder=@"http://server:8085";_downloadURLField.autocorrectionType=UITextAutocorrectionTypeNo;_downloadURLField.autocapitalizationType=UITextAutocapitalizationTypeNone;NSString *saved=[[NSUserDefaults standardUserDefaults] stringForKey:@"filesBaseURL"];if([saved length])_downloadURLField.text=saved;[_filesPanel addSubview:_downloadURLField];
    _filesTokenField=[[UITextField alloc] initWithFrame:CGRectMake(pw-210,44,120,34)];_filesTokenField.borderStyle=UITextBorderStyleRoundedRect;_filesTokenField.placeholder=@"API token";_filesTokenField.secureTextEntry=YES;_filesTokenField.text=[[NSUserDefaults standardUserDefaults] stringForKey:@"filesToken"];[_filesPanel addSubview:_filesTokenField];
    _browseFilesButton=[[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];_browseFilesButton.frame=CGRectMake(pw-85,44,70,34);[_browseFilesButton setTitle:@"Browse" forState:UIControlStateNormal];[_browseFilesButton addTarget:self action:@selector(browseFilesTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:_browseFilesButton];

    _remoteEntries=[[NSMutableArray alloc] init];_selectedRemoteIndex=-1;
    _remoteFilesTable=[[UITableView alloc] initWithFrame:CGRectMake(15,86,pw-30,ph-248) style:UITableViewStylePlain];_remoteFilesTable.delegate=self;_remoteFilesTable.dataSource=self;[_filesPanel addSubview:_remoteFilesTable];
    _downloadProgress=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];_downloadProgress.frame=CGRectMake(15,ph-152,pw-120,18);[_filesPanel addSubview:_downloadProgress];
    UIButton *cancel=[UIButton buttonWithType:UIButtonTypeRoundedRect];cancel.frame=CGRectMake(pw-95,ph-163,80,34);[cancel setTitle:@"Cancel" forState:UIControlStateNormal];[cancel addTarget:self action:@selector(cancelDownloadTapped) forControlEvents:UIControlEventTouchUpInside];[_filesPanel addSubview:cancel];
    _downloadStatusLabel=[[UILabel alloc] initWithFrame:CGRectMake(15,ph-132,pw-30,22)];_downloadStatusLabel.backgroundColor=[UIColor clearColor];_downloadStatusLabel.textColor=[UIColor whiteColor];_downloadStatusLabel.font=[UIFont systemFontOfSize:12];_downloadStatusLabel.text=@"Files v2: enter server and token.";[_filesPanel addSubview:_downloadStatusLabel];
    UILabel *local=[[[UILabel alloc] initWithFrame:CGRectMake(15,ph-108,pw-30,20)] autorelease];local.backgroundColor=[UIColor clearColor];local.textColor=[UIColor lightGrayColor];local.font=[UIFont boldSystemFontOfSize:12];local.text=@"Local: /var/mobile/Documents/iPad1VNC";[_filesPanel addSubview:local];
    _fileListView=[[UITextView alloc] initWithFrame:CGRectMake(15,ph-86,pw-30,72)];_fileListView.editable=NO;_fileListView.font=[UIFont systemFontOfSize:11];[_filesPanel addSubview:_fileListView];[_controller.view addSubview:_filesPanel];
}
- (void)browseFilesTapped {
    NSString*u=[_downloadURLField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(![u length]&&[_hostField.text length])u=[NSString stringWithFormat:@"http://%@:8085",_hostField.text];
    if(![u hasPrefix:@"http://"]&&![u hasPrefix:@"https://"])u=[@"http://" stringByAppendingString:u];
    while([u hasSuffix:@"/"])u=[u substringToIndex:[u length]-1];
    NSURL*url=[NSURL URLWithString:u];if(!url){_downloadStatusLabel.text=@"Invalid server address";return;}
    _downloadURLField.text=u;[_filesToken release];_filesToken=[_filesTokenField.text copy];
    [[NSUserDefaults standardUserDefaults] setObject:u forKey:@"filesBaseURL"];[[NSUserDefaults standardUserDefaults] setObject:(_filesToken?:@"") forKey:@"filesToken"];[[NSUserDefaults standardUserDefaults] synchronize];
    [_downloadURLField resignFirstResponder];[_filesTokenField resignFirstResponder];
    [_remoteRelativePath release];_remoteRelativePath=[@"" copy];
    [self startBrowseURL:url];
}
- (void)startBrowseURL:(NSURL*)url {
    if(_browseConnection){[_browseConnection cancel];[_browseConnection release];_browseConnection=nil;}[_browseData release];_browseData=[[NSMutableData alloc]init];
    [_remoteBaseURL release];_remoteBaseURL=[url retain];
    NSString *pathEsc=[_remoteRelativePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *s=[NSString stringWithFormat:@"%@/api/list?path=%@",[url absoluteString],pathEsc?:@""];
    NSMutableURLRequest *req=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:s] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    if([_filesToken length])[req setValue:_filesToken forHTTPHeaderField:@"X-iPad1VNC-Token"];
    _downloadStatusLabel.text=@"Loading remote files…";_browseConnection=[[NSURLConnection alloc]initWithRequest:req delegate:self startImmediately:YES];
}
- (void)filesUpTapped {
    if(![_remoteRelativePath length])return;
    NSString *p=[_remoteRelativePath stringByDeletingLastPathComponent];[_remoteRelativePath release];_remoteRelativePath=[p copy];[self startBrowseURL:_remoteBaseURL];
}
- (void)parseDirectoryHTML:(NSData*)data baseURL:(NSURL*)baseURL {
    (void)baseURL;NSError *err=nil;NSDictionary *obj=[NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    [_remoteEntries removeAllObjects];
    if(![obj isKindOfClass:[NSDictionary class]]){_downloadStatusLabel.text=@"Files API error / invalid token";[_remoteFilesTable reloadData];return;}
    NSArray *entries=[obj objectForKey:@"entries"];NSString *serverPath=[obj objectForKey:@"path"];
    if([serverPath isKindOfClass:[NSString class]]){[_remoteRelativePath release];_remoteRelativePath=[serverPath copy];}
    for(NSDictionary *e in entries)if([e isKindOfClass:[NSDictionary class]])[_remoteEntries addObject:e];
    [_remoteFilesTable reloadData];_downloadStatusLabel.text=([_remoteEntries count]?@"Tap folder; tap file for actions.":@"Remote folder is empty.");
}
- (NSString*)remotePathForEntry:(NSDictionary*)e {
    NSString *n=[e objectForKey:@"name"];return([_remoteRelativePath length]?[_remoteRelativePath stringByAppendingPathComponent:n]:n);
}
- (NSURL*)downloadURLForEntry:(NSDictionary*)e {
    NSString *path=[[self remotePathForEntry:e] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *tok=[_filesToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/download?path=%@&token=%@",[_remoteBaseURL absoluteString],path?:@"",tok?:@""]];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {(void)section;return(tableView==_remoteFilesTable?[_remoteEntries count]:0);}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {static NSString*CID=@"RemoteFile";UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:CID];if(!cell)cell=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CID]autorelease];NSDictionary*e=[_remoteEntries objectAtIndex:indexPath.row];BOOL dir=[[e objectForKey:@"dir"] boolValue];cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",dir?@"[DIR]":@"↓",[e objectForKey:@"name"]];cell.accessoryType=dir?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;return cell;}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if(tableView!=_remoteFilesTable)return;[tableView deselectRowAtIndexPath:indexPath animated:YES];NSDictionary*e=[_remoteEntries objectAtIndex:indexPath.row];
    if([[e objectForKey:@"dir"] boolValue]){
        NSString *p=[self remotePathForEntry:e];[_remoteRelativePath release];_remoteRelativePath=[p copy];[self startBrowseURL:_remoteBaseURL];
    } else {
        _selectedRemoteIndex=indexPath.row;
        UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:[e objectForKey:@"name"] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Download",@"Rename",nil] autorelease];
        s.tag=920;[s showInView:_filesPanel];
    }
}
- (void)downloadTapped {
    NSString *u=[_downloadURLField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self startDownloadFromURL:[NSURL URLWithString:u]];
}
- (void)cancelDownloadTapped { if(_downloadConnection){[_downloadConnection cancel];[_downloadConnection release];_downloadConnection=nil;}if(_downloadHandle){[_downloadHandle closeFile];[_downloadHandle release];_downloadHandle=nil;}if(_downloadPath){[[NSFileManager defaultManager] removeItemAtPath:_downloadPath error:nil];[_downloadPath release];_downloadPath=nil;}_downloadStatusLabel.text=@"Cancelled";_downloadProgress.progress=0; }
- (void)closeFilesTapped { [_downloadURLField resignFirstResponder]; _filesPanel.hidden=YES; }

- (void)performFileAPIPath:(NSString*)path method:(NSString*)method body:(NSData*)body contentType:(NSString*)contentType {
    if(!_remoteBaseURL)return;NSURL *u=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[_remoteBaseURL absoluteString],path]];
    NSMutableURLRequest *r=[NSMutableURLRequest requestWithURL:u cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
    [r setHTTPMethod:method];if([_filesToken length])[r setValue:_filesToken forHTTPHeaderField:@"X-iPad1VNC-Token"];
    if(contentType)[r setValue:contentType forHTTPHeaderField:@"Content-Type"];if(body)[r setHTTPBody:body];
    NSURLResponse *resp=nil;NSError *err=nil;NSData *d=[NSURLConnection sendSynchronousRequest:r returningResponse:&resp error:&err];
    if(err){_downloadStatusLabel.text=[NSString stringWithFormat:@"API failed: %@",[err localizedDescription]];return;}
    NSDictionary *o=(d?[NSJSONSerialization JSONObjectWithData:d options:0 error:nil]:nil);
    if([[o objectForKey:@"ok"] boolValue]){_downloadStatusLabel.text=@"Done";[self startBrowseURL:_remoteBaseURL];}
    else _downloadStatusLabel.text=[NSString stringWithFormat:@"API: %@",[o objectForKey:@"error"]?:@"failed"];
}
- (void)mkdirRemote {
    if(!_remoteBaseURL){_downloadStatusLabel.text=@"Browse first";return;}
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"New Folder" message:@"Folder name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create",nil] autorelease];a.tag=930;a.alertViewStyle=UIAlertViewStylePlainTextInput;[a show];
}
- (void)renameRemoteEntry:(NSDictionary*)entry {
    _selectedRemoteIndex=[_remoteEntries indexOfObjectIdenticalTo:entry];
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Rename" message:@"New name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename",nil] autorelease];a.tag=931;a.alertViewStyle=UIAlertViewStylePlainTextInput;[[a textFieldAtIndex:0] setText:[entry objectForKey:@"name"]];[a show];
}
- (void)deleteRemoteEntry:(NSDictionary*)entry {
    NSString *rp=[self remotePathForEntry:entry];NSDictionary *o=[NSDictionary dictionaryWithObject:rp forKey:@"path"];NSData *b=[NSJSONSerialization dataWithJSONObject:o options:0 error:nil];[self performFileAPIPath:@"/api/delete" method:@"POST" body:b contentType:@"application/json"];
}
- (void)uploadLocalFile {
    NSArray *files=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self downloadsDirectory] error:nil];
    if(![files count]){_downloadStatusLabel.text=@"No local downloaded files to upload";return;}
    UIActionSheet *s=[[[UIActionSheet alloc] initWithTitle:@"Upload local file" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];s.tag=921;
    NSUInteger max=MIN((NSUInteger)12,[files count]);for(NSUInteger i=0;i<max;i++)[s addButtonWithTitle:[files objectAtIndex:i]];s.cancelButtonIndex=[s addButtonWithTitle:@"Cancel"];[s showInView:_filesPanel];
}

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
    [_terminalSession stop];[_tunnelSession stop];[_terminalSession release];[_tunnelSession release];[_terminalPanel release];[_terminalView release];[_terminalInput release];[_sshUserField release];[_sshPortField release];[_sshKeyField release];[_sshTunnelSwitch release];[_terminalButton release];
    [_filesToken release];[_filesTokenField release];[_remoteRelativePath release];
    [_filesPanel release];[_downloadURLField release];[_remoteFilesTable release];[_browseFilesButton release];[_filesUpButton release];[_remoteEntries release];[_remoteBaseURL release];[_browseData release];[_downloadStatusLabel release];[_downloadProgress release];[_fileListView release];[_keyBar release];
    [_exitFullScreenButton release];[_fullScreenButton release];[_settingsButton release];[_filesButton release];[_keyboardButton release];[_qualityControl release];[_inputModeControl release];[_tightSwitch release];[_statsLabel release];[_profilesButton release];[_profiles release];[_speedSlider release];[_speedLabel release];
    [_vncView release];[_keyboardField release];[_statusLabel release];[_connectButton release];[_passwordField release];[_portField release];[_hostField release];[_connectionPanel release];[_controller release];[_window release];[super dealloc];
}
- (NSString*)remotePathForEntry:(NSDictionary*)e;
- (NSURL*)downloadURLForEntry:(NSDictionary*)e;
@end
