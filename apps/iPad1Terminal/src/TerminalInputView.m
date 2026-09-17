#import "TerminalInputView.h"

@implementation TerminalInputView

@synthesize terminalDelegate = _terminalDelegate;

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)hasText
{
    /*
     * Always return YES so iOS keeps Backspace enabled.
     * The actual editable state lives in the child shell/PTY.
     */
    return YES;
}

- (void)insertText:(NSString *)text
{
    if (_terminalDelegate &&
        [_terminalDelegate respondsToSelector:@selector(terminalInputView:didInsertText:)]) {
        [_terminalDelegate terminalInputView:self didInsertText:text];
    }
}

- (void)deleteBackward
{
    if (_terminalDelegate &&
        [_terminalDelegate respondsToSelector:@selector(terminalInputViewDidDeleteBackward:)]) {
        [_terminalDelegate terminalInputViewDidDeleteBackward:self];
    }
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeASCIICapable;
}

- (void)dealloc
{
    _terminalDelegate = nil;
    [super dealloc];
}

@end
