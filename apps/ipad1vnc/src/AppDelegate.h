#import <UIKit/UIKit.h>
@class VNCClient;
@class VNCView;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate> {
    UIWindow *_window;
    UIViewController *_controller;
    UITextField *_hostField;
    UITextField *_portField;
    UITextField *_passwordField;
    UILabel *_statusLabel;
    UIButton *_connectButton;
    UIButton *_keyboardButton;
    UITextField *_keyboardField;
    VNCView *_vncView;
    VNCClient *_client;
}
@property (nonatomic, retain) UIWindow *window;
@end
