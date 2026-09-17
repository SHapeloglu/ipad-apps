#import <Foundation/Foundation.h>

typedef enum {
    TerminalANSIActionNone = 0,
    TerminalANSIActionClearScreen = 1
} TerminalANSIAction;

@interface TerminalANSIParser : NSObject
{
    NSMutableString *_escapeBuffer;
    BOOL _insideEscape;
}

- (NSString *)consumeText:(NSString *)text action:(TerminalANSIAction *)action;

@end
