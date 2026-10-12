#import "QRScanner.h"

#if __has_include(<ZBarSDK/ZBarSDK.h>)
#import <ZBarSDK/ZBarSDK.h>
#define IP1_HAS_ZBAR 1
#elif __has_include("ZBarSDK.h")
#import "ZBarSDK.h"
#define IP1_HAS_ZBAR 1
#else
#define IP1_HAS_ZBAR 0
#endif

#if IP1_HAS_ZBAR
@interface QRScanner () <ZBarReaderDelegate>
@end
#endif

@implementation QRScanner
@synthesize delegate = _delegate;

- (BOOL)isNativeScannerAvailable {
#if IP1_HAS_ZBAR
    return YES;
#else
    return NO;
#endif
}

- (void)presentScannerFromViewController:(UIViewController *)controller {
    _presenter = controller;
#if IP1_HAS_ZBAR
    ZBarReaderViewController *reader = [[[ZBarReaderViewController alloc] init] autorelease];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsZBarControls = YES;
    [controller presentModalViewController:reader animated:YES];
#else
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"QR kutuphanesi yok"
                                                    message:@"iOS 5.1.1 QR okumayi yerlesik olarak desteklemez. ZBarSDK ekleyin veya ana ekrandaki 'Token Gir' ile test edin."
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
#endif
}

#if IP1_HAS_ZBAR
- (void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info {
    id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for (symbol in results) break;
    NSString *text = [[symbol.data copy] autorelease];
    [reader dismissModalViewControllerAnimated:YES];
    if ([text length] > 0 && [_delegate respondsToSelector:@selector(qrScannerDidReadText:)])
        [_delegate qrScannerDidReadText:text];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
    if ([_delegate respondsToSelector:@selector(qrScannerDidCancel)]) [_delegate qrScannerDidCancel];
}
#endif

@end
