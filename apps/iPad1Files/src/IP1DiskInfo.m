#import "IP1DiskInfo.h"

@implementation IP1DiskInfo

+ (NSDictionary *)attributes:(NSString *)path {
    return [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:nil];
}

+ (unsigned long long)freeBytesAtPath:(NSString *)path {
    return [[[self attributes:path] objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
}

+ (unsigned long long)totalBytesAtPath:(NSString *)path {
    return [[[self attributes:path] objectForKey:NSFileSystemSize] unsignedLongLongValue];
}

+ (NSString *)formattedBytes:(unsigned long long)bytes {
    double value = (double)bytes;
    if (value < 1024.0) return [NSString stringWithFormat:@"%.0f B", value];
    value /= 1024.0;
    if (value < 1024.0) return [NSString stringWithFormat:@"%.1f KB", value];
    value /= 1024.0;
    if (value < 1024.0) return [NSString stringWithFormat:@"%.1f MB", value];
    value /= 1024.0;
    return [NSString stringWithFormat:@"%.2f GB", value];
}

@end
