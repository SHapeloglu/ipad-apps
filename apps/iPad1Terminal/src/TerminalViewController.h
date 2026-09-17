#import <UIKit/UIKit.h>
#import "LocalTerminalSession.h"
#import "TerminalInputView.h"
#import "TerminalANSIParser.h"

@interface TerminalViewController : UIViewController
    <LocalTerminalSessionDelegate, TerminalInputViewDelegate>
{
    UITextView *_terminalView;
    TerminalInputView *_inputCaptureView;
    UIView *_specialKeyBar;

    LocalTerminalSession *_session;
    TerminalANSIParser *_ansiParser;

    NSMutableString *_scrollback;
    NSUInteger _maxScrollbackCharacters;
}

- (id)initWithLocalShell;

@end
