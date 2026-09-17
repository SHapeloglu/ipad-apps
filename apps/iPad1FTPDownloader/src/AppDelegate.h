#import <UIKit/UIKit.h>
#import "FTPDownloader.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, FTPDownloaderDelegate, UITextFieldDelegate> {
    UIWindow *_window;
    UITextField *_hostField;
    UITextField *_portField;
    UITextField *_userField;
    UITextField *_passField;
    UITextField *_remotePathField;
    UITextField *_localNameField;
    UILabel *_statusLabel;
    UILabel *_bytesLabel;
    UIButton *_downloadButton;
    FTPDownloader *_downloader;
}
@property (nonatomic, retain) UIWindow *window;
@end
