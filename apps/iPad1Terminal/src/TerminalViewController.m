#import "TerminalViewController.h"
#include <math.h>

@interface TerminalViewController ()
- (void)startLocalShell;
- (void)appendTerminalText:(NSString *)text;
- (void)trimScrollbackIfNeeded;
- (void)sendSpecialKey:(UIButton *)button;
- (void)sendControlC;
- (void)updateTerminalSize;
- (void)focusTerminalInput:(id)sender;
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
    _terminalView.font = [UIFont fontWithName:@"Courier" size:15.0f];
    if (_terminalView.font == nil) {
        _terminalView.font = [UIFont systemFontOfSize:15.0f];
    }
    _terminalView.editable = NO;
    _terminalView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_terminalView];

    UITapGestureRecognizer *tap =
        [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(focusTerminalInput:)] autorelease];
    [_terminalView addGestureRecognizer:tap];

    /*
     * Invisible UIKeyInput capture view.
     * The keyboard belongs to the terminal itself instead of a visible
     * white UITextField.
     */
    _inputCaptureView = [[TerminalInputView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)];
    _inputCaptureView.terminalDelegate = self;
    _inputCaptureView.backgroundColor = [UIColor clearColor];
    _inputCaptureView.alpha = 0.01f;
    [self.view addSubview:_inputCaptureView];

    /*
     * Keep terminal helper keys above the software keyboard.
     */
    _specialKeyBar = [[UIView alloc] initWithFrame:
        CGRectMake(0.0f, 0.0f, frame.size.width, keyBarHeight)];
    _specialKeyBar.backgroundColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    _specialKeyBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _inputCaptureView.terminalAccessoryView = _specialKeyBar;

    NSArray *titles = [NSArray arrayWithObjects:
        @"Esc", @"Ctrl+C", @"Tab", @"<", @"^", @"v", @">", @"~", @"|", nil];

    NSArray *values = [NSArray arrayWithObjects:
        @"\x1b", @"CTRL_C", @"\t", @"\x1b[D", @"\x1b[A",
        @"\x1b[B", @"\x1b[C", @"~", @"|", nil];

    NSUInteger count = [titles count];
    CGFloat buttonWidth = floorf(frame.size.width / (CGFloat)count);

    NSUInteger index;
    for (index = 0; index < count; index++) {
        CGRect buttonFrame = CGRectMake(index * buttonWidth + 1.0f,
                                        3.0f,
                                        buttonWidth - 2.0f,
                                        keyBarHeight - 6.0f);
        UIButton *button = [self specialButtonWithTitle:[titles objectAtIndex:index]
                                                 value:[values objectAtIndex:index]
                                                 frame:buttonFrame];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_specialKeyBar addSubview:button];
    }
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
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    button.accessibilityLabel = value;

    [button addTarget:self
               action:@selector(sendSpecialKey:)
     forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [self updateTerminalSize];
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

#pragma mark - UIKeyInput bridge

- (void)terminalInputView:(TerminalInputView *)inputView didInsertText:(NSString *)text
{
    (void)inputView;

    if ([text isEqualToString:@"\n"]) {
        [_session writeString:@"\n"];
    } else {
        [_session writeString:text];
    }
}

- (void)terminalInputViewDidDeleteBackward:(TerminalInputView *)inputView
{
    (void)inputView;

    unsigned char byte = 0x7F;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    [_session writeData:data];
}

#pragma mark - Special keys

- (void)sendSpecialKey:(UIButton *)button
{
    NSString *value = button.accessibilityLabel;

    if ([value isEqualToString:@"CTRL_C"]) {
        [self sendControlC];
    } else if (value != nil) {
        [_session writeString:value];
    }

    [_inputCaptureView becomeFirstResponder];
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

    /*
     * Ctrl+L lets the interactive shell redraw the prompt naturally.
     */
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
