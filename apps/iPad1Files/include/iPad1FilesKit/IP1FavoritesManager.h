#import <Foundation/Foundation.h>

@interface IP1FavoritesManager : NSObject

+ (IP1FavoritesManager *)sharedManager;

- (NSArray *)favorites;
- (BOOL)isFavorite:(NSString *)path;
- (void)addFavorite:(NSString *)path;
- (void)removeFavorite:(NSString *)path;
- (void)toggleFavorite:(NSString *)path;

@end
