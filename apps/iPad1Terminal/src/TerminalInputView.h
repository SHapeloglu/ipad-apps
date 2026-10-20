#import <UIKit/UIKit.h>

@protocol TerminalInputViewDelegate;

@interface TerminalInputView : UIView <UIKeyInput>
{
    id<TerminalInputViewDelegate> _terminalDelegate;
    UIView *_terminalAccessoryView;
}

@property (nonatomic, assign) id<TerminalInputViewDelegate> terminalDelegate;
@property (nonatomic, retain) UIView *terminalAccessoryView;

@end

@protocol TerminalInputViewDelegate <NSObject>
- (void)terminalInputView:(TerminalInputView *)inputView didInsertText:(NSString *)text;
- (void)terminalInputViewDidDeleteBackward:(TerminalInputView *)inputView;
@end
