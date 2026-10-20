#import "IP1FileItem.h"

@implementation IP1FileItem

@synthesize path = _path;
@synthesize name = _name;
@synthesize directory = _directory;
@synthesize size = _size;
@synthesize modifiedDate = _modifiedDate;

+ (IP1FileItem *)itemWithPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fm fileExistsAtPath:path isDirectory:&isDirectory]) {
        return nil;
    }

    NSDictionary *attrs = [fm attributesOfItemAtPath:path error:nil];

    IP1FileItem *item = [[[IP1FileItem alloc] init] autorelease];
    item.path = path;
    item.name = [path lastPathComponent];
    item.directory = isDirectory;
    item.size = isDirectory ? 0 : [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    item.modifiedDate = [attrs objectForKey:NSFileModificationDate];
    return item;
}

- (NSString *)extension {
    return [[self.name pathExtension] lowercaseString];
}

- (NSString *)formattedSize {
    if (self.directory) {
        return @"Klasör";
    }

    double bytes = (double)self.size;
    if (bytes < 1024.0) return [NSString stringWithFormat:@"%.0f B", bytes];
    if (bytes < 1024.0 * 1024.0) return [NSString stringWithFormat:@"%.1f KB", bytes / 1024.0];
    if (bytes < 1024.0 * 1024.0 * 1024.0) return [NSString stringWithFormat:@"%.1f MB", bytes / (1024.0 * 1024.0)];
    return [NSString stringWithFormat:@"%.2f GB", bytes / (1024.0 * 1024.0 * 1024.0)];
}

- (void)dealloc {
    [_path release];
    [_name release];
    [_modifiedDate release];
    [super dealloc];
}

@end
