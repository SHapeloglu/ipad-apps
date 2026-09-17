#import <UIKit/UIKit.h>
@class VNCClient;
@class VNCView;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate, UIWebViewDelegate> {
    UIWindow *_window;
    UIViewController *_controller;
    UIView *_connectionPanel;
    UITextField *_hostField;
    UITextField *_portField;
    UITextField *_passwordField;
    UILabel *_statusLabel;
    UILabel *_speedLabel;
    UISlider *_speedSlider;
    UISegmentedControl *_qualityControl;
    UIButton *_connectButton;
    UIButton *_keyboardButton;
    UIButton *_filesButton;
    UIButton *_settingsButton;
    UIButton *_fullScreenButton;
    UIButton *_exitFullScreenButton;
    UITextField *_keyboardField;
    UIView *_keyBar;
    VNCView *_vncView;
    VNCClient *_client;
    NSTimer *_reconnectTimer;
    NSTimer *_clipboardTimer;
    NSInteger _lastPasteboardChangeCount;
    BOOL _ctrlArmed;
    BOOL _altArmed;
    BOOL _controlsCollapsed;
    BOOL _fullScreen;
    BOOL _shouldAutoReconnect;

    UIView *_filesPanel;
    UITextField *_downloadURLField;
    UIWebView *_remoteFilesWebView;
    UIButton *_browseFilesButton;
    UILabel *_downloadStatusLabel;
    UIProgressView *_downloadProgress;
    UITextView *_fileListView;
    NSURLConnection *_downloadConnection;
    NSFileHandle *_downloadHandle;
    NSString *_downloadPath;
    long long _downloadExpected;
    long long _downloadReceived;
}
@property (nonatomic, retain) UIWindow *window;
@end
