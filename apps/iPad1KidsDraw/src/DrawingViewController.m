#import "DrawingViewController.h"
#import "DrawingView.h"

#define TOOLBAR_HEIGHT 72.0f
#define BUTTON_SIZE 48.0f
#define BUTTON_GAP 8.0f

@implementation DrawingViewController

- (void)loadView
{
    UIView *root = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    root.backgroundColor = [UIColor colorWithWhite:0.90f alpha:1.0f];
    self.view = root;

    _toolbar = [[UIView alloc] initWithFrame:CGRectZero];
    _toolbar.backgroundColor = [UIColor colorWithWhite:0.93f alpha:1.0f];
    [self.view addSubview:_toolbar];

    _drawingView = [[DrawingView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_drawingView];

    _lastPaintColor = [[UIColor blackColor] retain];

    NSArray *colors = [NSArray arrayWithObjects:
        [UIColor blackColor],
        [UIColor redColor],
        [UIColor blueColor],
        [UIColor greenColor],
        [UIColor orangeColor],
        [UIColor purpleColor],
        [UIColor magentaColor],
        nil];

    NSInteger i;
    for (i = 0; i < [colors count]; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(10.0f + i * (BUTTON_SIZE + BUTTON_GAP), 12.0f, BUTTON_SIZE, BUTTON_SIZE);
        b.backgroundColor = [colors objectAtIndex:i];
        b.tag = 100 + i;
        [b addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbar addSubview:b];
    }

    UIButton *thin = [self textButton:@"İnce" tag:201];
    UIButton *medium = [self textButton:@"Orta" tag:202];
    UIButton *thick = [self textButton:@"Kalın" tag:203];
    UIButton *eraser = [self textButton:@"Silgi" tag:204];
    UIButton *clear = [self textButton:@"Temizle" tag:205];
    UIButton *save = [self textButton:@"Kaydet" tag:206];

    [_toolbar addSubview:thin];
    [_toolbar addSubview:medium];
    [_toolbar addSubview:thick];
    [_toolbar addSubview:eraser];
    [_toolbar addSubview:clear];
    [_toolbar addSubview:save];
}

- (UIButton *)textButton:(NSString *)title tag:(NSInteger)tag
{
    UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.frame = CGRectMake(0, 0, 64, 48);
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    b.tag = tag;
    [b addTarget:self action:@selector(toolPressed:) forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect bounds = self.view.bounds;
    _toolbar.frame = CGRectMake(0, 0, bounds.size.width, TOOLBAR_HEIGHT);
    _drawingView.frame = CGRectMake(0, TOOLBAR_HEIGHT, bounds.size.width, bounds.size.height - TOOLBAR_HEIGHT);

    CGFloat x = 10.0f + 7.0f * (BUTTON_SIZE + BUTTON_GAP) + 12.0f;
    NSArray *tags = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:201],
        [NSNumber numberWithInt:202],
        [NSNumber numberWithInt:203],
        [NSNumber numberWithInt:204],
        [NSNumber numberWithInt:205],
        [NSNumber numberWithInt:206], nil];

    NSInteger i;
    for (i = 0; i < [tags count]; i++) {
        UIView *v = [_toolbar viewWithTag:[[tags objectAtIndex:i] intValue]];
        v.frame = CGRectMake(x, 12.0f, 68.0f, 48.0f);
        x += 72.0f;
    }
}

- (void)colorPressed:(UIButton *)sender
{
    NSArray *colors = [NSArray arrayWithObjects:
        [UIColor blackColor],
        [UIColor redColor],
        [UIColor blueColor],
        [UIColor greenColor],
        [UIColor orangeColor],
        [UIColor purpleColor],
        [UIColor magentaColor],
        nil];

    NSInteger index = sender.tag - 100;
    if (index >= 0 && index < [colors count]) {
        UIColor *color = [colors objectAtIndex:index];
        [_lastPaintColor release];
        _lastPaintColor = [color retain];
        _drawingView.strokeColor = color;
    }
}

- (void)toolPressed:(UIButton *)sender
{
    switch (sender.tag) {
        case 201:
            _drawingView.lineWidth = 3.0f;
            _drawingView.strokeColor = _lastPaintColor;
            break;
        case 202:
            _drawingView.lineWidth = 7.0f;
            _drawingView.strokeColor = _lastPaintColor;
            break;
        case 203:
            _drawingView.lineWidth = 14.0f;
            _drawingView.strokeColor = _lastPaintColor;
            break;
        case 204:
            _drawingView.lineWidth = 20.0f;
            _drawingView.strokeColor = [UIColor whiteColor];
            break;
        case 205:
            [self confirmClear];
            break;
        case 206:
            [self saveDrawing];
            break;
        default:
            break;
    }
}

- (void)confirmClear
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Resmi temizle?"
                                                    message:@"Bütün çizim silinecek."
                                                   delegate:self
                                          cancelButtonTitle:@"Vazgeç"
                                          otherButtonTitles:@"Temizle", nil] autorelease];
    alert.tag = 501;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 501 && buttonIndex == 1) {
        [_drawingView clearCanvas];
    }
}

- (void)saveDrawing
{
    UIImage *image = [_drawingView renderedImage];
    UIImageWriteToSavedPhotosAlbum(image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *title = error ? @"Kaydedilemedi" : @"Kaydedildi";
    NSString *message = error ? [error localizedDescription] : @"Resim Fotoğraflar'a kaydedildi.";

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
    [alert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc
{
    [_drawingView release];
    [_toolbar release];
    [_lastPaintColor release];
    [super dealloc];
}

@end
