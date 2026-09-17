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
    UIButton *_connectButton;
    UIButton *_keyboardButton;
    UIButton *_settingsButton;
    UITextField *_keyboardField;
    VNCView *_vncView;
    VNCClient *_client;
    BOOL _controlsCollapsed;
}
@property (nonatomic, retain) UIWindow *window;
@end
