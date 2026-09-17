#import "TerminalViewController.h"
#include <math.h>

@interface TerminalViewController ()
- (void)startLocalShell;
- (void)sendCurrentCommand;
- (void)appendTerminalText:(NSString *)text;
- (void)trimScrollbackIfNeeded;
- (void)sendSpecialKey:(UIButton *)button;
- (void)sendControlC;
- (void)updateTerminalSize;
@end

@implementation TerminalViewController

- (id)initWithLocalShell
{
    self = [super init];
    if (self) {
        self.title = @"Local Terminal";
        _maxScrollbackCharacters = 120000;
        _scrollback = [[NSMutableString alloc] init];
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

    CGFloat keyBarHeight = 40.0f;
    CGFloat inputHeight = 38.0f;

    _terminalView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                frame.size.width,
                                                                frame.size.height - keyBarHeight - inputHeight)];
    _terminalView.backgroundColor = [UIColor blackColor];
    _terminalView.textColor = [UIColor whiteColor];
    _terminalView.font = [UIFont fontWithName:@"Courier" size:15.0f];
    if (_terminalView.font == nil) {
        _terminalView.font = [UIFont systemFontOfSize:15.0f];
    }
    _terminalView.editable = NO;
    _terminalView.autocorrectionType = UITextAutocorrectionTypeNo;
    _terminalView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _terminalView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_terminalView];

    _specialKeyBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                             frame.size.height - keyBarHeight - inputHeight,
                                                             frame.size.width,
                                                             keyBarHeight)];
    _specialKeyBar.backgroundColor = [UIColor darkGrayColor];
    _specialKeyBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_specialKeyBar];

    NSArray *titles = [NSArray arrayWithObjects:@"Esc", @"Ctrl+C", @"Tab", @"←", @"↑", @"↓", @"→", nil];
    NSArray *values = [NSArray arrayWithObjects:@"\x1b", @"CTRL_C", @"\t",
                                                @"\x1b[D", @"\x1b[A", @"\x1b[B", @"\x1b[C", nil];

    CGFloat buttonWidth = floorf(frame.size.width / (CGFloat)[titles count]);
    NSUInteger index;
    for (index = 0; index < [titles count]; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(index * buttonWidth + 2.0f, 3.0f,
                                  buttonWidth - 4.0f, keyBarHeight - 6.0f);
        [button setTitle:[titles objectAtIndex:index] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        button.accessibilityLabel = [values objectAtIndex:index];
        [button addTarget:self action:@selector(sendSpecialKey:)
         forControlEvents:UIControlEventTouchUpInside];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_specialKeyBar addSubview:button];
    }

    _inputField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f,
                                                               frame.size.height - inputHeight,
                                                               frame.size.width,
                                                               inputHeight)];
    _inputField.backgroundColor = [UIColor whiteColor];
    _inputField.textColor = [UIColor blackColor];
    _inputField.font = [UIFont fontWithName:@"Courier" size:16.0f];
    if (_inputField.font == nil) {
        _inputField.font = [UIFont systemFontOfSize:16.0f];
    }
    _inputField.delegate = self;
    _inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    _inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _inputField.returnKeyType = UIReturnKeyDefault;
    _inputField.placeholder = @"Type command and press Return";
    _inputField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_inputField];
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
    [_inputField becomeFirstResponder];
    [self updateTerminalSize];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateTerminalSize];
}

- (void)startLocalShell
{
    _session = [[LocalTerminalSession alloc] init];
    _session.delegate = self;

    NSError *error = nil;
    if (![_session startWithError:&error]) {
        [self appendTerminalText:
         [NSString stringWithFormat:@"\r\n[PTY ERROR] %@\r\n",
          [error localizedDescription]]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _inputField) {
        [self sendCurrentCommand];
        return NO;
    }
    return YES;
}

- (void)sendCurrentCommand
{
    NSString *command = _inputField.text;
    if (command == nil) {
        command = @"";
    }

    [_session writeString:[command stringByAppendingString:@"\n"]];
    _inputField.text = @"";
}

- (void)sendSpecialKey:(UIButton *)button
{
    NSString *value = button.accessibilityLabel;

    if ([value isEqualToString:@"CTRL_C"]) {
        [self sendControlC];
        return;
    }

    if (value != nil) {
        [_session writeString:value];
    }

    [_inputField becomeFirstResponder];
}

- (void)sendControlC
{
    unsigned char byte = 0x03;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    [_session writeData:data];
    [_inputField becomeFirstResponder];
}

- (void)appendTerminalText:(NSString *)text
{
    if (text == nil || [text length] == 0) {
        return;
    }

    [_scrollback appendString:text];
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
                             range:NSMakeRange(removeCount,
                                               length - removeCount)];

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
    [_session writeString:@"\x0c"];
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

    unsigned short columns = (unsigned short)MAX(20, floorf(usableWidth / MAX(1.0f, glyph.width)));
    unsigned short rows = (unsigned short)MAX(5, floorf(usableHeight / MAX(1.0f, glyph.height)));

    [_session resizeRows:rows columns:columns];
}

- (void)localTerminalSession:(LocalTerminalSession *)session didReceiveText:(NSString *)text
{
    (void)session;
    [self appendTerminalText:text];
}

- (void)localTerminalSessionDidExit:(LocalTerminalSession *)session
{
    (void)session;
    [self appendTerminalText:@"\r\n[Process exited]\r\n"];
}

- (void)localTerminalSession:(LocalTerminalSession *)session
            didFailWithError:(NSError *)error
{
    (void)session;
    [self appendTerminalText:
     [NSString stringWithFormat:@"\r\n[PTY ERROR] %@\r\n",
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
    _session.delegate = nil;
    [_session stop];
    [_session release];

    [_terminalView release];
    [_inputField release];
    [_specialKeyBar release];
    [_scrollback release];

    [super dealloc];
}

@end
