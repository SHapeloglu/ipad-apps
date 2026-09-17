#import <UIKit/UIKit.h>

@protocol TerminalInputViewDelegate;

@interface TerminalInputView : UIView <UIKeyInput>
{
    id<TerminalInputViewDelegate> _terminalDelegate;
}

@property (nonatomic, assign) id<TerminalInputViewDelegate> terminalDelegate;

@end

@protocol TerminalInputViewDelegate <NSObject>
- (void)terminalInputView:(TerminalInputView *)inputView didInsertText:(NSString *)text;
- (void)terminalInputViewDidDeleteBackward:(TerminalInputView *)inputView;
@end
