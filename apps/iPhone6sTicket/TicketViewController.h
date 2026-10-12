#import <UIKit/UIKit.h>
#import "APIClient.h"
#import "QRScanner.h"

@interface TicketViewController : UIViewController <APIClientDelegate, QRScannerDelegate, UIAlertViewDelegate> {
    UILabel *_titleLabel;
    UILabel *_statusLabel;
    UILabel *_nameLabel;
    UILabel *_numberLabel;
    UILabel *_eventLabel;
    UILabel *_dateLabel;
    UILabel *_locationLabel;
    UIButton *_scanButton;
    UIButton *_manualButton;
    UIActivityIndicatorView *_spinner;
    APIClient *_apiClient;
    QRScanner *_qrScanner;
}
@end
