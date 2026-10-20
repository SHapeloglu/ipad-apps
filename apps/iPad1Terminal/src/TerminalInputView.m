#import "TerminalInputView.h"

@implementation TerminalInputView

@synthesize terminalDelegate = _terminalDelegate;
@synthesize terminalAccessoryView = _terminalAccessoryView;

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)hasText
{
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
    /* Allow Turkish and other Unicode keyboards. */
    return UIKeyboardTypeDefault;
}

- (UIView *)inputAccessoryView
{
    return _terminalAccessoryView;
}

- (void)dealloc
{
    _terminalDelegate = nil;
    [_terminalAccessoryView release];
    [super dealloc];
}

@end
