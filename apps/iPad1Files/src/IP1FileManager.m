#import "IP1FileManager.h"
#import "IP1FileItem.h"


static NSInteger IP1CompareFileItems(id obj1, id obj2, void *context) {
    (void)context;
    IP1FileItem *a = (IP1FileItem *)obj1;
    IP1FileItem *b = (IP1FileItem *)obj2;

    if (a.isDirectory && !b.isDirectory) return NSOrderedAscending;
    if (!a.isDirectory && b.isDirectory) return NSOrderedDescending;
    return [a.name localizedCaseInsensitiveCompare:b.name];
}

@implementation IP1FileManager

+ (IP1FileManager *)sharedManager {
    static IP1FileManager *instance = nil;
    @synchronized(self) {
        if (!instance) {
            instance = [[IP1FileManager alloc] init];
        }
    }
    return instance;
}

- (NSArray *)contentsOfDirectory:(NSString *)path showHidden:(BOOL)showHidden error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *names = [fm contentsOfDirectoryAtPath:path error:error];
    if (!names) return nil;

    NSMutableArray *items = [NSMutableArray array];

    for (NSString *name in names) {
        if (!showHidden && [name hasPrefix:@"."]) continue;

        NSString *fullPath = [path stringByAppendingPathComponent:name];
        IP1FileItem *item = [IP1FileItem itemWithPath:fullPath];
        if (item) [items addObject:item];
    }
    [items sortUsingFunction:IP1CompareFileItems context:NULL];

    return items;
}

- (BOOL)createFolderNamed:(NSString *)name inDirectory:(NSString *)directory error:(NSError **)error {
    if ([name length] == 0 || [name rangeOfString:@"/"].location != NSNotFound) {
        if (error) {
            *error = [NSError errorWithDomain:@"iPad1Files"
                                         code:1001
                                     userInfo:[NSDictionary dictionaryWithObject:@"Geçersiz klasör adı."
                                                                          forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }

    NSString *path = [directory stringByAppendingPathComponent:name];
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:error];
}

- (BOOL)renameItemAtPath:(NSString *)path toName:(NSString *)newName error:(NSError **)error {
    if ([newName length] == 0 || [newName rangeOfString:@"/"].location != NSNotFound) {
        if (error) {
            *error = [NSError errorWithDomain:@"iPad1Files"
                                         code:1002
                                     userInfo:[NSDictionary dictionaryWithObject:@"Geçersiz dosya adı."
                                                                          forKey:NSLocalizedDescriptionKey]];
        }
        return NO;
    }

    NSString *destination = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    return [[NSFileManager defaultManager] moveItemAtPath:path toPath:destination error:error];
}

- (BOOL)deleteItemAtPath:(NSString *)path error:(NSError **)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

- (NSString *)uniqueDestinationForSource:(NSString *)source directory:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *name = [source lastPathComponent];
    NSString *candidate = [directory stringByAppendingPathComponent:name];

    if (![fm fileExistsAtPath:candidate]) return candidate;

    NSString *base = [name stringByDeletingPathExtension];
    NSString *ext = [name pathExtension];

    NSUInteger index = 2;
    do {
        NSString *newName;
        if ([ext length] > 0) {
            newName = [NSString stringWithFormat:@"%@ (%lu).%@", base, (unsigned long)index, ext];
        } else {
            newName = [NSString stringWithFormat:@"%@ (%lu)", base, (unsigned long)index];
        }
        candidate = [directory stringByAppendingPathComponent:newName];
        index++;
    } while ([fm fileExistsAtPath:candidate]);

    return candidate;
}

- (BOOL)copyItemAtPath:(NSString *)source toDirectory:(NSString *)destination error:(NSError **)error {
    NSString *target = [self uniqueDestinationForSource:source directory:destination];
    return [[NSFileManager defaultManager] copyItemAtPath:source toPath:target error:error];
}

- (BOOL)moveItemAtPath:(NSString *)source toDirectory:(NSString *)destination error:(NSError **)error {
    NSString *target = [self uniqueDestinationForSource:source directory:destination];
    return [[NSFileManager defaultManager] moveItemAtPath:source toPath:target error:error];
}

- (NSArray *)filesWithExtension:(NSString *)extension underPath:(NSString *)rootPath {
    NSMutableArray *result = [NSMutableArray array];
    NSDirectoryEnumerator *enumerator =
        [[NSFileManager defaultManager] enumeratorAtPath:rootPath];

    NSString *relativePath = nil;
    while ((relativePath = [enumerator nextObject])) {
        if ([[[relativePath pathExtension] lowercaseString] isEqualToString:[extension lowercaseString]]) {
            [result addObject:[rootPath stringByAppendingPathComponent:relativePath]];
        }
    }
    return result;
}

- (unsigned long long)recursiveSizeOfPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fm fileExistsAtPath:path isDirectory:&isDirectory]) return 0;

    if (!isDirectory) {
        NSDictionary *attrs = [fm attributesOfItemAtPath:path error:nil];
        return [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    }

    unsigned long long total = 0;
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtPath:path];
    NSString *relativePath = nil;
    while ((relativePath = [enumerator nextObject])) {
        NSString *fullPath = [path stringByAppendingPathComponent:relativePath];
        BOOL childDirectory = NO;
        if ([fm fileExistsAtPath:fullPath isDirectory:&childDirectory] && !childDirectory) {
            NSDictionary *attrs = [fm attributesOfItemAtPath:fullPath error:nil];
            total += [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
        }
    }
    return total;
}

@end
