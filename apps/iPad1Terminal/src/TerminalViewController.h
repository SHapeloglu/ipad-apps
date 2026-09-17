#import <UIKit/UIKit.h>
#import "LocalTerminalSession.h"

@interface TerminalViewController : UIViewController
    <UITextFieldDelegate, LocalTerminalSessionDelegate>
{
    UITextView *_terminalView;
    UITextField *_inputField;
    UIView *_specialKeyBar;

    LocalTerminalSession *_session;
    NSMutableString *_scrollback;
    NSUInteger _maxScrollbackCharacters;
}

- (id)initWithLocalShell;

@end
