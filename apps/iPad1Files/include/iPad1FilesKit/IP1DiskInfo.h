#import <Foundation/Foundation.h>

@interface IP1DiskInfo : NSObject
+ (unsigned long long)freeBytesAtPath:(NSString *)path;
+ (unsigned long long)totalBytesAtPath:(NSString *)path;
+ (NSString *)formattedBytes:(unsigned long long)bytes;
@end
