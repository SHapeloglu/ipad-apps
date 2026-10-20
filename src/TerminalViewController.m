#import "TerminalViewController.h"
#include <math.h>

static NSString * const TerminalFontSizeDefaultsKey = @"TerminalFontSize";
static const CGFloat TerminalDefaultFontSize = 15.0f;
static const CGFloat TerminalMinimumFontSize = 10.0f;
static const CGFloat TerminalMaximumFontSize = 24.0f;
static const CGFloat TerminalFontStep = 1.0f;
static const CGFloat TerminalHelperButtonWidth = 58.0f;
static const NSUInteger TerminalLargePasteThreshold = 4096;
static const NSInteger TerminalLargePasteAlertTag = 2101;

@interface TerminalViewController ()
- (void)startLocalShell;
- (void)appendTerminalText:(NSString *)text;
- (void)trimScrollbackIfNeeded;
- (void)sendSpecialKey:(UIButton *)button;
- (void)sendControlC;
- (BOOL)sendControlCharacterForText:(NSString *)text;
- (void)setControlModifierActive:(BOOL)active;
- (void)updateTerminalSize;
- (void)layoutSpecialKeyButtons;
- (void)focusTerminalInput:(id)sender;
- (void)changeFontSize:(UIBarButtonItem *)sender;
- (void)copyTerminal:(id)sender;
- (void)pasteFromClipboard;
- (void)sendPasteText:(NSString *)text;
- (UIButton *)specialButtonWithTitle:(NSString *)title
                               value:(NSString *)value
                               frame:(CGRect)frame;
@end

@implementation TerminalViewController

- (id)initWithLocalShell
{
    self = [super init];
    if (self) {
        self.title = @"Local Terminal";
        _maxScrollbackCharacters = 120000;
        _controlModifierActive = NO;
        _controlModifierButton = nil;
        _pendingPaste = nil;

        CGFloat savedFontSize =
            [[NSUserDefaults standardUserDefaults] floatForKey:TerminalFontSizeDefaultsKey];
        if (savedFontSize < TerminalMinimumFontSize ||
            savedFontSize > TerminalMaximumFontSize) {
            savedFontSize = TerminalDefaultFontSize;
        }
        _terminalFontSize = savedFontSize;

        _scrollback = [[NSMutableString alloc] init];
        _ansiParser = [[TerminalANSIParser alloc] init];
    }
    return self;
}

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView *root = [[[UIView alloc] initWithFrame:frame] autorelease];
    root.backgroundColor = [UIColor blackColor];
    root.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = root;

    CGFloat keyBarHeight = 44.0f;

    _terminalView = [[UITextView alloc] initWithFrame:
        CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
    _terminalView.backgroundColor = [UIColor blackColor];
    _terminalView.textColor = [UIColor whiteColor];
    _terminalView.font = [UIFont fontWithName:@"Courier" size:_terminalFontSize];
    if (_terminalView.font == nil) {
        _terminalView.font = [UIFont systemFontOfSize:_terminalFontSize];
    }
    _terminalView.editable = NO;
    _terminalView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_terminalView];

    UITapGestureRecognizer *tap =
        [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(focusTerminalInput:)] autorelease];
    [_terminalView addGestureRecognizer:tap];

    _inputCaptureView = [[TerminalInputView alloc]
        initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)];
    _inputCaptureView.terminalDelegate = self;
    _inputCaptureView.backgroundColor = [UIColor clearColor];
    _inputCaptureView.alpha = 0.01f;
    [self.view addSubview:_inputCaptureView];

    /*
     * Scrollable Smart Keys style helper row. This avoids squeezing many
     * terminal keys into unreadable buttons on the iPad 1 keyboard.
     */
    _specialKeyBar = [[UIScrollView alloc] initWithFrame:
        CGRectMake(0.0f, 0.0f, frame.size.width, keyBarHeight)];
    _specialKeyBar.backgroundColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    _specialKeyBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _specialKeyBar.showsHorizontalScrollIndicator = NO;
    _specialKeyBar.alwaysBounceHorizontal = YES;
    _inputCaptureView.terminalAccessoryView = _specialKeyBar;

    NSArray *titles = [NSArray arrayWithObjects:
        @"Esc", @"Ctrl", @"Ctrl+C", @"Tab",
        @"Home", @"End", @"PgUp", @"PgDn",
        @"<", @"^", @"v", @">",
        @"~", @"|", @"/", @"\\", @"-", @"_", @":",
        @"Paste", nil];

    NSArray *values = [NSArray arrayWithObjects:
        @"\x1b", @"CTRL_MODIFIER", @"CTRL_C", @"\t",
        @"\x1b[H", @"\x1b[F", @"\x1b[5~", @"\x1b[6~",
        @"\x1b[D", @"\x1b[A", @"\x1b[B", @"\x1b[C",
        @"~", @"|", @"/", @"\\", @"-", @"_", @":",
        @"PASTE", nil];

    NSUInteger count = [titles count];
    NSUInteger index;
    for (index = 0; index < count; index++) {
        UIButton *button = [self specialButtonWithTitle:[titles objectAtIndex:index]
                                                 value:[values objectAtIndex:index]
                                                 frame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        if ([[values objectAtIndex:index] isEqualToString:@"CTRL_MODIFIER"]) {
            _controlModifierButton = button;
        }
        [_specialKeyBar addSubview:button];
    }

    [self layoutSpecialKeyButtons];
}

- (UIButton *)specialButtonWithTitle:(NSString *)title
                               value:(NSString *)value
                               frame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor colorWithWhite:0.28f alpha:1.0f];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor]
                 forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    button.accessibilityLabel = value;
    [button addTarget:self
               action:@selector(sendSpecialKey:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *fontDown =
        [[[UIBarButtonItem alloc] initWithTitle:@"A-"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(changeFontSize:)] autorelease];
    fontDown.tag = -1;

    UIBarButtonItem *fontUp =
        [[[UIBarButtonItem alloc] initWithTitle:@"A+"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(changeFontSize:)] autorelease];
    fontUp.tag = 1;

    UIBarButtonItem *copyButton =
        [[[UIBarButtonItem alloc] initWithTitle:@"Copy"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(copyTerminal:)] autorelease];

    self.navigationItem.leftBarButtonItems =
        [NSArray arrayWithObjects:fontDown, fontUp, copyButton, nil];

    UIBarButtonItem *clearButton =
        [[[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(clearTerminal:)] autorelease];
    self.navigationItem.rightBarButtonItem = clearButton;

    [self startLocalShell];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_inputCaptureView becomeFirstResponder];
    [self updateTerminalSize];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect barFrame = _specialKeyBar.frame;
    barFrame.size.width = self.view.bounds.size.width;
    _specialKeyBar.frame = barFrame;
    [self layoutSpecialKeyButtons];

    [self updateTerminalSize];
}

- (void)layoutSpecialKeyButtons
{
    NSArray *buttons = [_specialKeyBar subviews];
    NSUInteger count = [buttons count];
    CGFloat height = _specialKeyBar.bounds.size.height;

    NSUInteger index;
    for (index = 0; index < count; index++) {
        UIButton *button = (UIButton *)[buttons objectAtIndex:index];
        button.frame = CGRectMake((CGFloat)index * TerminalHelperButtonWidth + 1.0f,
                                  3.0f,
                                  TerminalHelperButtonWidth - 2.0f,
                                  MAX(1.0f, height - 6.0f));
    }

    _specialKeyBar.contentSize =
        CGSizeMake((CGFloat)count * TerminalHelperButtonWidth, height);
}

- (void)focusTerminalInput:(id)sender
{
    (void)sender;
    [_inputCaptureView becomeFirstResponder];
}

- (void)startLocalShell
{
    _session = [[LocalTerminalSession alloc] init];
    _session.delegate = self;

    NSError *error = nil;
    if (![_session startWithError:&error]) {
        [self appendTerminalText:
         [NSString stringWithFormat:@"\n[PTY ERROR] %@\n",
          [error localizedDescription]]];
    }
}

#pragma mark - Font / clipboard

- (void)changeFontSize:(UIBarButtonItem *)sender
{
    CGFloat nextSize =
        _terminalFontSize + ((sender.tag < 0) ? -TerminalFontStep : TerminalFontStep);
    nextSize = MAX(TerminalMinimumFontSize,
                   MIN(TerminalMaximumFontSize, nextSize));

    if (fabs(nextSize - _terminalFontSize) < 0.01f) {
        [_inputCaptureView becomeFirstResponder];
        return;
    }

    _terminalFontSize = nextSize;
    [[NSUserDefaults standardUserDefaults] setFloat:_terminalFontSize
                                             forKey:TerminalFontSizeDefaultsKey];

    UIFont *font = [UIFont fontWithName:@"Courier" size:_terminalFontSize];
    if (font == nil) {
        font = [UIFont systemFontOfSize:_terminalFontSize];
    }
    _terminalView.font = font;

    [self updateTerminalSize];
    [_inputCaptureView becomeFirstResponder];
}

- (void)copyTerminal:(id)sender
{
    (void)sender;

    NSString *textToCopy = nil;
    NSRange selectedRange = _terminalView.selectedRange;

    if (selectedRange.length > 0 &&
        NSMaxRange(selectedRange) <= [_terminalView.text length]) {
        textToCopy = [_terminalView.text substringWithRange:selectedRange];
    } else {
        textToCopy = _scrollback;
    }

    if ([textToCopy length] > 0) {
        [UIPasteboard generalPasteboard].string = textToCopy;
    }

    [_inputCaptureView becomeFirstResponder];
}

- (void)pasteFromClipboard
{
    NSString *text = [UIPasteboard generalPasteboard].string;
    if (text == nil || [text length] == 0) {
        return;
    }

    if ([text length] > TerminalLargePasteThreshold) {
        [_pendingPaste release];
        _pendingPaste = [text copy];

        NSString *message =
            [NSString stringWithFormat:@"Paste %lu characters into the terminal?",
             (unsigned long)[text length]];

        UIAlertView *alert =
            [[[UIAlertView alloc] initWithTitle:@"Large Paste"
                                       message:message
                                      delegate:self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"Paste", nil] autorelease];
        alert.tag = TerminalLargePasteAlertTag;
        [alert show];
        return;
    }

    [self sendPasteText:text];
}

- (void)sendPasteText:(NSString *)text
{
    if (text == nil || [text length] == 0) {
        return;
    }

    [self setControlModifierActive:NO];
    [_session writeString:text];
    [_inputCaptureView becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != TerminalLargePasteAlertTag) {
        return;
    }

    if (buttonIndex != alertView.cancelButtonIndex && _pendingPaste != nil) {
        [self sendPasteText:_pendingPaste];
    }

    [_pendingPaste release];
    _pendingPaste = nil;
}

#pragma mark - UIKeyInput bridge

- (void)terminalInputView:(TerminalInputView *)inputView didInsertText:(NSString *)text
{
    (void)inputView;

    if (_controlModifierActive) {
        BOOL sent = [self sendControlCharacterForText:text];
        [self setControlModifierActive:NO];

        if (sent) {
            return;
        }
    }

    [_session writeString:text];
}

- (void)terminalInputViewDidDeleteBackward:(TerminalInputView *)inputView
{
    (void)inputView;

    [self setControlModifierActive:NO];

    unsigned char byte = 0x7F;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    [_session writeData:data];
}

#pragma mark - Special keys

- (void)sendSpecialKey:(UIButton *)button
{
    NSString *value = button.accessibilityLabel;

    if ([value isEqualToString:@"CTRL_MODIFIER"]) {
        [self setControlModifierActive:!_controlModifierActive];
    } else if ([value isEqualToString:@"CTRL_C"]) {
        [self setControlModifierActive:NO];
        [self sendControlC];
    } else if ([value isEqualToString:@"PASTE"]) {
        [self pasteFromClipboard];
    } else if (value != nil) {
        [self setControlModifierActive:NO];
        [_session writeString:value];
    }

    [_inputCaptureView becomeFirstResponder];
}

- (void)setControlModifierActive:(BOOL)active
{
    _controlModifierActive = active;

    if (_controlModifierButton != nil) {
        [_controlModifierButton setTitle:(active ? @"Ctrl*" : @"Ctrl")
                                forState:UIControlStateNormal];
    }
}

- (BOOL)sendControlCharacterForText:(NSString *)text
{
    if (text == nil || [text length] != 1) {
        return NO;
    }

    unichar character = [text characterAtIndex:0];
    unsigned char byte = 0;

    if (character >= 'a' && character <= 'z') {
        character = (unichar)(character - 'a' + 'A');
    }

    if (character == ' ') {
        byte = 0x00;
    } else if (character >= '@' && character <= '_') {
        byte = (unsigned char)(character & 0x1F);
    } else if (character == '?') {
        byte = 0x7F;
    } else {
        return NO;
    }

    NSData *data = [NSData dataWithBytes:&byte length:1];
    return [_session writeData:data];
}

- (void)sendControlC
{
    unsigned char byte = 0x03;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    [_session writeData:data];
    [_inputCaptureView becomeFirstResponder];
}

#pragma mark - Output

- (void)appendTerminalText:(NSString *)text
{
    if (text == nil || [text length] == 0) {
        return;
    }

    TerminalANSIAction action = TerminalANSIActionNone;
    NSString *cleanText = [_ansiParser consumeText:text action:&action];

    if (action == TerminalANSIActionClearScreen) {
        [_scrollback setString:@""];
    }

    if ([cleanText length] > 0) {
        [_scrollback appendString:cleanText];
    }

    [self trimScrollbackIfNeeded];

    _terminalView.text = _scrollback;

    if ([_terminalView.text length] > 0) {
        NSRange end = NSMakeRange([_terminalView.text length] - 1, 1);
        [_terminalView scrollRangeToVisible:end];
    }
}

- (void)trimScrollbackIfNeeded
{
    NSUInteger length = [_scrollback length];
    if (length <= _maxScrollbackCharacters) {
        return;
    }

    NSUInteger removeCount = length - _maxScrollbackCharacters;

    NSRange newlineRange =
        [_scrollback rangeOfString:@"\n"
                           options:0
                             range:NSMakeRange(removeCount, length - removeCount)];

    if (newlineRange.location != NSNotFound) {
        removeCount = NSMaxRange(newlineRange);
    }

    [_scrollback deleteCharactersInRange:NSMakeRange(0, removeCount)];
}

- (void)clearTerminal:(id)sender
{
    (void)sender;

    [_scrollback setString:@""];
    _terminalView.text = @"";

    unsigned char byte = 0x0C;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    [_session writeData:data];

    [_inputCaptureView becomeFirstResponder];
}

- (void)updateTerminalSize
{
    if (_session == nil || !_session.running || _terminalView == nil) {
        return;
    }

    UIFont *font = _terminalView.font;
    CGSize glyph = [@"M" sizeWithFont:font];

    CGFloat usableWidth = _terminalView.bounds.size.width - 16.0f;
    CGFloat usableHeight = _terminalView.bounds.size.height - 16.0f;

    unsigned short columns =
        (unsigned short)MAX(20, floorf(usableWidth / MAX(1.0f, glyph.width)));
    unsigned short rows =
        (unsigned short)MAX(5, floorf(usableHeight / MAX(1.0f, glyph.height)));

    [_session resizeRows:rows columns:columns];
}

#pragma mark - Session delegate

- (void)localTerminalSession:(LocalTerminalSession *)session didReceiveText:(NSString *)text
{
    (void)session;
    [self appendTerminalText:text];
}

- (void)localTerminalSessionDidExit:(LocalTerminalSession *)session
{
    (void)session;
    [self appendTerminalText:@"\n[Process exited]\n"];
}

- (void)localTerminalSession:(LocalTerminalSession *)session
            didFailWithError:(NSError *)error
{
    (void)session;
    [self appendTerminalText:
     [NSString stringWithFormat:@"\n[PTY ERROR] %@\n",
      [error localizedDescription]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation) ||
           UIInterfaceOrientationIsLandscape(orientation);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        _session.delegate = nil;
        [_session stop];
    }
}

- (void)dealloc
{
    _inputCaptureView.terminalDelegate = nil;
    _controlModifierButton = nil;

    [_pendingPaste release];

    _session.delegate = nil;
    [_session stop];
    [_session release];

    [_ansiParser release];
    [_terminalView release];
    [_inputCaptureView release];
    [_specialKeyBar release];
    [_scrollback release];

    [super dealloc];
}

@end
