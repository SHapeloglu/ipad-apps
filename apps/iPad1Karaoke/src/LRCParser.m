#import "LRCParser.h"

@implementation LRCLyricLine
@synthesize time = _time;
@synthesize text = _text;
- (void)dealloc { [_text release]; [super dealloc]; }
@end

static NSInteger CompareLyricLines(id first, id second, void *context) {
    (void)context;
    NSTimeInterval firstTime = [(LRCLyricLine *)first time];
    NSTimeInterval secondTime = [(LRCLyricLine *)second time];
    if (firstTime < secondTime) return NSOrderedAscending;
    if (firstTime > secondTime) return NSOrderedDescending;
    return NSOrderedSame;
}

@implementation LRCParser

+ (NSArray *)parseFileAtPath:(NSString *)path {
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!content || error) return [NSArray array];

    NSMutableArray *lines = [NSMutableArray array];
    NSArray *rows = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(\\d{1,2}):(\\d{2})(?:\\.(\\d{1,2}))?\\](.*)" options:0 error:nil];

    for (NSString *row in rows) {
        NSTextCheckingResult *match = [regex firstMatchInString:row options:0 range:NSMakeRange(0, [row length])];
        if (!match || [match numberOfRanges] < 5) continue;

        NSInteger minutes = [[row substringWithRange:[match rangeAtIndex:1]] integerValue];
        NSInteger seconds = [[row substringWithRange:[match rangeAtIndex:2]] integerValue];
        NSTimeInterval fraction = 0.0;
        NSRange fractionRange = [match rangeAtIndex:3];
        if (fractionRange.location != NSNotFound) {
            NSString *fractionText = [row substringWithRange:fractionRange];
            fraction = [fractionText doubleValue] / ([fractionText length] == 1 ? 10.0 : 100.0);
        }

        LRCLyricLine *line = [[[LRCLyricLine alloc] init] autorelease];
        line.time = minutes * 60.0 + seconds + fraction;
        line.text = [[row substringWithRange:[match rangeAtIndex:4]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [lines addObject:line];
    }

    [lines sortUsingFunction:CompareLyricLines context:NULL];
    return lines;
}
@end
