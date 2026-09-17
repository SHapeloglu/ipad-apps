#import <Foundation/Foundation.h>

@interface LRCLyricLine : NSObject {
    NSTimeInterval _time;
    NSString *_text;
}
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, copy) NSString *text;
@end

@interface LRCParser : NSObject
+ (NSArray *)parseFileAtPath:(NSString *)path;
@end
