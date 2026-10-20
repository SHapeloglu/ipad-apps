#import "TerminalANSIParser.h"

@implementation TerminalANSIParser

- (id)init
{
    self = [super init];
    if (self) {
        _escapeBuffer = [[NSMutableString alloc] init];
        _insideEscape = NO;
    }
    return self;
}

/*
 * Lightweight ANSI/VT100 compatibility layer for the alpha build.
 *
 * It consumes escape sequences that should never be rendered literally,
 * especially ESC[K which previously appeared on screen as "[K".
 *
 * Supported behavior:
 *   ESC[K, ESC[0K, ESC[1K, ESC[2K  -> consume
 *   ESC[J, ESC[0J, ESC[1J          -> consume
 *   ESC[2J                         -> clear screen
 *   ESC[H, ESC[f                   -> consume
 *   ESC[...m                       -> consume SGR/color codes for now
 *   common cursor movement CSI     -> consume for now
 *
 * This is deliberately NOT a complete terminal emulator yet.
 */
- (NSString *)consumeText:(NSString *)text action:(TerminalANSIAction *)action
{
    if (action) {
        *action = TerminalANSIActionNone;
    }

    NSMutableString *output = [NSMutableString string];
    NSUInteger i;
    NSUInteger length = [text length];

    for (i = 0; i < length; i++) {
        unichar ch = [text characterAtIndex:i];

        if (!_insideEscape) {
            if (ch == 0x1B) {
                _insideEscape = YES;
                [_escapeBuffer setString:@""];
                [_escapeBuffer appendFormat:@"%C", ch];
                continue;
            }

            /*
             * A CR is used by terminal applications to return to column 0.
             * UITextView cannot model cursor-column replacement yet, so
             * suppress bare CR and preserve LF for readable output.
             */
            if (ch == '\r') {
                if ((i + 1) < length && [text characterAtIndex:(i + 1)] == '\n') {
                    continue;
                }
                continue;
            }

            if (ch == 0x08) {
                /* Backspace emitted by an application: do not show glyph. */
                if ([output length] > 0) {
                    [output deleteCharactersInRange:NSMakeRange([output length] - 1, 1)];
                }
                continue;
            }

            [output appendFormat:@"%C", ch];
            continue;
        }

        [_escapeBuffer appendFormat:@"%C", ch];

        /*
         * ESC followed by a non-[ character is a short escape sequence.
         */
        if ([_escapeBuffer length] == 2 &&
            [_escapeBuffer characterAtIndex:1] != '[') {
            _insideEscape = NO;
            [_escapeBuffer setString:@""];
            continue;
        }

        if ([_escapeBuffer length] >= 3 &&
            [_escapeBuffer characterAtIndex:1] == '[') {

            /*
             * CSI ends with a byte in the range 0x40..0x7E.
             */
            if (ch >= 0x40 && ch <= 0x7E) {
                if (ch == 'J') {
                    NSString *sequence = [_escapeBuffer substringFromIndex:2];
                    if ([sequence hasPrefix:@"2J"] && action) {
                        *action = TerminalANSIActionClearScreen;
                    }
                }

                _insideEscape = NO;
                [_escapeBuffer setString:@""];
            } else if ([_escapeBuffer length] > 32) {
                /*
                 * Safety guard for malformed input.
                 */
                _insideEscape = NO;
                [_escapeBuffer setString:@""];
            }
        }
    }

    return output;
}

- (void)dealloc
{
    [_escapeBuffer release];
    [super dealloc];
}

@end
