#import <UIKit/UIKit.h>
#import "FTPDownloader.h"
#import "FTPBrowser.h"

@interface AppDelegate : UIResponder
<UIApplicationDelegate, FTPDownloaderDelegate, FTPBrowserDelegate,
UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    UIWindow *_window;
    UITextField *_hostField;
    UITextField *_portField;
    UITextField *_userField;
    UITextField *_passField;
    UITextField *_pathField;
    UIButton *_connectButton;
    UIButton *_upButton;
    UILabel *_statusLabel;
    UILabel *_bytesLabel;
    UITableView *_tableView;
    FTPDownloader *_downloader;
    FTPBrowser *_browser;
    NSArray *_items;
    NSString *_currentPath;
    NSString *_host;
    NSString *_username;
    NSString *_password;
    NSInteger _port;
}
@property (nonatomic, retain) UIWindow *window;
@end
