#import <UIKit/UIKit.h>
#import "LocalTerminalSession.h"
#import "TerminalInputView.h"
#import "TerminalANSIParser.h"

@interface TerminalViewController : UIViewController
    <LocalTerminalSessionDelegate, TerminalInputViewDelegate, UIAlertViewDelegate>
{
    UITextView *_terminalView;
    TerminalInputView *_inputCaptureView;
    UIScrollView *_specialKeyBar;
    UIButton *_controlModifierButton;

    LocalTerminalSession *_session;
    TerminalANSIParser *_ansiParser;

    NSMutableString *_scrollback;
    NSUInteger _maxScrollbackCharacters;

    CGFloat _terminalFontSize;
    BOOL _controlModifierActive;
    NSString *_pendingPaste;
}

- (id)initWithLocalShell;

@end
