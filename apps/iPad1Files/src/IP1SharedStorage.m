#import "IP1SharedStorage.h"

@implementation IP1SharedStorage

+ (IP1SharedStorage *)sharedStorage {
    static IP1SharedStorage *instance = nil;
    @synchronized(self) {
        if (!instance) {
            instance = [[IP1SharedStorage alloc] init];
        }
    }
    return instance;
}

- (NSString *)rootPath {
    return @"/var/mobile/Media/iPad1Files";
}

- (NSString *)pathForFolder:(NSString *)folder {
    return [[self rootPath] stringByAppendingPathComponent:folder];
}

- (NSString *)downloadsPath { return [self pathForFolder:@"Downloads"]; }
- (NSString *)documentsPath { return [self pathForFolder:@"Documents"]; }
- (NSString *)pdfsPath { return [self pathForFolder:@"PDFs"]; }
- (NSString *)imagesPath { return [self pathForFolder:@"Images"]; }
- (NSString *)musicPath { return [self pathForFolder:@"Music"]; }
- (NSString *)videosPath { return [self pathForFolder:@"Videos"]; }
- (NSString *)archivesPath { return [self pathForFolder:@"Archives"]; }
- (NSString *)sharedPath { return [self pathForFolder:@"Shared"]; }
- (NSString *)tempPath { return [self pathForFolder:@"Temp"]; }
- (NSString *)appDataPath { return [self pathForFolder:@"AppData"]; }

- (BOOL)ensureDirectoryStructure {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = [NSArray arrayWithObjects:
        [self rootPath],
        [self downloadsPath],
        [self documentsPath],
        [self pdfsPath],
        [self imagesPath],
        [self musicPath],
        [self videosPath],
        [self archivesPath],
        [self sharedPath],
        [self tempPath],
        [self appDataPath],
        nil];

    for (NSString *path in paths) {
        BOOL isDirectory = NO;
        if (![fm fileExistsAtPath:path isDirectory:&isDirectory]) {
            NSError *error = nil;
            if (![fm createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error]) {
                NSLog(@"[iPad1Files] Cannot create %@: %@", path, error);
                return NO;
            }
        } else if (!isDirectory) {
            NSLog(@"[iPad1Files] Expected directory but found file: %@", path);
            return NO;
        }
    }
    return YES;
}

@end
