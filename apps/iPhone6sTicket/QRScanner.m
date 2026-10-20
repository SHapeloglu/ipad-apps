#import "QRScanner.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>

@class NativeQRScannerViewController;

@interface NativeQRScannerViewController : UIViewController {
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_previewLayer;
    id _metadataOutput;
    UIButton *_closeButton;
    UILabel *_hintLabel;
    UIView *_scanFrame;
    BOOL _finished;
    QRScanner *_owner;
}
@property (nonatomic, assign) QRScanner *owner;
@end

@interface QRScanner ()
- (void)scannerController:(NativeQRScannerViewController *)controller didReadText:(NSString *)text;
- (void)scannerControllerDidCancel:(NativeQRScannerViewController *)controller;
@end

@implementation QRScanner
@synthesize delegate = _delegate;

- (BOOL)isNativeScannerAvailable {
    return NSClassFromString(@"AVCaptureMetadataOutput") != Nil;
}

- (void)presentScannerFromViewController:(UIViewController *)controller {
    _presenter = controller;

    if (![self isNativeScannerAvailable]) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"QR tarama desteklenmiyor"
                                                        message:@"Bu iOS surumunde yerlesik QR tarama kullanilamiyor."
                                                       delegate:nil
                                              cancelButtonTitle:@"Tamam"
                                              otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }

    NativeQRScannerViewController *scanner = [[[NativeQRScannerViewController alloc] init] autorelease];
    scanner.owner = self;
    _scannerController = [scanner retain];
    [controller presentViewController:scanner animated:YES completion:nil];
}

- (void)scannerController:(NativeQRScannerViewController *)controller didReadText:(NSString *)text {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [_scannerController release];
    _scannerController = nil;

    if ([text length] > 0 && [_delegate respondsToSelector:@selector(qrScannerDidReadText:)])
        [_delegate qrScannerDidReadText:text];
}

- (void)scannerControllerDidCancel:(NativeQRScannerViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [_scannerController release];
    _scannerController = nil;

    if ([_delegate respondsToSelector:@selector(qrScannerDidCancel)])
        [_delegate qrScannerDidCancel];
}

- (void)dealloc {
    [_scannerController release];
    [super dealloc];
}
@end

@implementation NativeQRScannerViewController
@synthesize owner = _owner;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _finished = NO;

    _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 42, self.view.bounds.size.width - 40, 50)];
    _hintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _hintLabel.text = @"QR kodunu kameraya gosterin";
    _hintLabel.textColor = [UIColor whiteColor];
    _hintLabel.backgroundColor = [UIColor clearColor];
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    _hintLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    [self.view addSubview:_hintLabel];

    _scanFrame = [[UIView alloc] initWithFrame:CGRectMake(35, 145, self.view.bounds.size.width - 70, self.view.bounds.size.width - 70)];
    _scanFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scanFrame.backgroundColor = [UIColor clearColor];
    _scanFrame.layer.borderColor = [UIColor colorWithRed:0.2f green:0.9f blue:0.4f alpha:1.0f].CGColor;
    _scanFrame.layer.borderWidth = 3.0f;
    _scanFrame.layer.cornerRadius = 10.0f;
    [self.view addSubview:_scanFrame];

    _closeButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _closeButton.frame = CGRectMake(30, self.view.bounds.size.height - 80, self.view.bounds.size.width - 60, 48);
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_closeButton setTitle:@"Vazgec" forState:UIControlStateNormal];
    _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    [_closeButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];

    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input || error) {
        [self showCameraError:@"Kamera acilamadi."];
        return;
    }

    _session = [[AVCaptureSession alloc] init];
    if ([_session canAddInput:input])
        [_session addInput:input];

    Class metadataClass = NSClassFromString(@"AVCaptureMetadataOutput");
    if (!metadataClass) {
        [self showCameraError:@"QR tarama bu iOS surumunde desteklenmiyor."];
        return;
    }

    _metadataOutput = [[metadataClass alloc] init];
    if ([_session canAddOutput:_metadataOutput])
        [_session addOutput:_metadataOutput];
    else {
        [self showCameraError:@"QR cikisi kameraya eklenemedi."];
        return;
    }

    SEL delegateSel = NSSelectorFromString(@"setMetadataObjectsDelegate:queue:");
    if ([_metadataOutput respondsToSelector:delegateSel]) {
        void (*sendDelegate)(id, SEL, id, dispatch_queue_t) = (void (*)(id, SEL, id, dispatch_queue_t))objc_msgSend;
        sendDelegate(_metadataOutput, delegateSel, self, dispatch_get_main_queue());
    }

    SEL typesSel = NSSelectorFromString(@"setMetadataObjectTypes:");
    if ([_metadataOutput respondsToSelector:typesSel]) {
        NSArray *types = [NSArray arrayWithObject:@"org.iso.QRCode"];
        void (*sendTypes)(id, SEL, id) = (void (*)(id, SEL, id))objc_msgSend;
        sendTypes(_metadataOutput, typesSel, types);
    }

    _previewLayer = [[AVCaptureVideoPreviewLayer layerWithSession:_session] retain];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];

    [_session startRunning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = self.view.bounds;

    CGFloat width = self.view.bounds.size.width - 70.0f;
    _scanFrame.frame = CGRectMake(35.0f, 145.0f, width, width);
}

- (void)showCameraError:(NSString *)message {
    _hintLabel.text = message;
    _hintLabel.textColor = [UIColor colorWithRed:1.0f green:0.35f blue:0.3f alpha:1.0f];
}

- (void)cancelPressed {
    if (_finished) return;
    _finished = YES;
    [_session stopRunning];
    if (_owner) [_owner scannerControllerDidCancel:self];
}

// AVCaptureMetadataOutputObjectsDelegate callback. Runtime dispatch kullanildigi icin
// eski SDK header'larinda protokolu tanimli olmasa da iPhone 6s / iOS 9+ uzerinde calisir.
- (void)captureOutput:(id)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(id)connection {
    if (_finished) return;

    for (id object in metadataObjects) {
        if (![object respondsToSelector:@selector(stringValue)]) continue;
        NSString *value = [object performSelector:@selector(stringValue)];
        if ([value length] == 0) continue;

        _finished = YES;
        [_session stopRunning];
        if (_owner) [_owner scannerController:self didReadText:value];
        break;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [_session stopRunning];
    [_session release];
    [_previewLayer release];
    [_metadataOutput release];
    [_closeButton release];
    [_hintLabel release];
    [_scanFrame release];
    [super dealloc];
}
@end
