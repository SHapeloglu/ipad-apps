#import "IP1FavoritesManager.h"
#import "IP1SharedStorage.h"

@implementation IP1FavoritesManager

+ (IP1FavoritesManager *)sharedManager {
    static IP1FavoritesManager *instance = nil;
    @synchronized(self) {
        if (!instance) instance = [[IP1FavoritesManager alloc] init];
    }
    return instance;
}

- (NSString *)favoritesFile {
    NSString *appDir = [[[IP1SharedStorage sharedStorage] appDataPath]
                        stringByAppendingPathComponent:@"iPad1Files"];
    [[NSFileManager defaultManager] createDirectoryAtPath:appDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return [appDir stringByAppendingPathComponent:@"favorites.plist"];
}

- (NSMutableArray *)mutableFavorites {
    NSArray *stored = [NSArray arrayWithContentsOfFile:[self favoritesFile]];
    if (stored) return [NSMutableArray arrayWithArray:stored];
    return [NSMutableArray array];
}

- (NSArray *)favorites {
    return [NSArray arrayWithArray:[self mutableFavorites]];
}

- (BOOL)isFavorite:(NSString *)path {
    return [[self mutableFavorites] containsObject:path];
}

- (void)save:(NSArray *)items {
    [items writeToFile:[self favoritesFile] atomically:YES];
}

- (void)addFavorite:(NSString *)path {
    NSMutableArray *items = [self mutableFavorites];
    if (![items containsObject:path]) {
        [items addObject:path];
        [self save:items];
    }
}

- (void)removeFavorite:(NSString *)path {
    NSMutableArray *items = [self mutableFavorites];
    [items removeObject:path];
    [self save:items];
}

- (void)toggleFavorite:(NSString *)path {
    if ([self isFavorite:path]) [self removeFavorite:path];
    else [self addFavorite:path];
}

@end
