#import <Foundation/Foundation.h>

@interface IP1SharedStorage : NSObject

+ (IP1SharedStorage *)sharedStorage;

- (NSString *)rootPath;
- (NSString *)downloadsPath;
- (NSString *)documentsPath;
- (NSString *)pdfsPath;
- (NSString *)imagesPath;
- (NSString *)musicPath;
- (NSString *)videosPath;
- (NSString *)archivesPath;
- (NSString *)sharedPath;
- (NSString *)tempPath;
- (NSString *)appDataPath;

- (BOOL)ensureDirectoryStructure;

@end
