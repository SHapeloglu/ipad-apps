#import <UIKit/UIKit.h>
@class VNCClient;
@class VNCView;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate> {
    UIWindow *_window;
    UIViewController *_controller;
    UIView *_connectionPanel;
    UITextField *_hostField;
    UITextField *_portField;
    UITextField *_passwordField;
    UILabel *_statusLabel;
    UILabel *_speedLabel;
    UISlider *_speedSlider;
    UIButton *_connectButton;
    UIButton *_keyboardButton;
    UIButton *_settingsButton;
    UIButton *_fullScreenButton;
    UIButton *_exitFullScreenButton;
    UITextField *_keyboardField;
    VNCView *_vncView;
    VNCClient *_client;
    NSTimer *_reconnectTimer;
    BOOL _controlsCollapsed;
    BOOL _fullScreen;
    BOOL _shouldAutoReconnect;
}
@property (nonatomic, retain) UIWindow *window;
@end
