#import <UIKit/UIKit.h>

@protocol QRScannerDelegate <NSObject>
- (void)qrScannerDidReadText:(NSString *)text;
- (void)qrScannerDidCancel;
@end

@interface QRScanner : NSObject {
    id<QRScannerDelegate> _delegate;
    UIViewController *_presenter;
}
@property (nonatomic, assign) id<QRScannerDelegate> delegate;
- (BOOL)isNativeScannerAvailable;
- (void)presentScannerFromViewController:(UIViewController *)controller;
@end
