#import <Foundation/Foundation.h>

@interface ArchiveManager : NSObject

+ (ArchiveManager *)sharedManager;

- (NSArray *)entriesInZipAtPath:(NSString *)zipPath error:(NSError **)error;

- (NSString *)extractZipAtPath:(NSString *)zipPath
                   toDirectory:(NSString *)destinationDirectory
                         error:(NSError **)error;

- (NSString *)createZipNamed:(NSString *)name
                   fromPaths:(NSArray *)paths
                 inDirectory:(NSString *)destinationDirectory
                       error:(NSError **)error;

@end
