#import <Foundation/Foundation.h>

@class IP1FileItem;

typedef enum {
    IP1FileConflictPolicyUnique = 0,
    IP1FileConflictPolicyOverwrite = 1
} IP1FileConflictPolicy;

@interface IP1FileManager : NSObject

+ (IP1FileManager *)sharedManager;

- (NSArray *)contentsOfDirectory:(NSString *)path showHidden:(BOOL)showHidden error:(NSError **)error;
- (BOOL)createFolderNamed:(NSString *)name inDirectory:(NSString *)directory error:(NSError **)error;
- (BOOL)renameItemAtPath:(NSString *)path toName:(NSString *)newName error:(NSError **)error;
- (BOOL)deleteItemAtPath:(NSString *)path error:(NSError **)error;

- (BOOL)isProtectedSystemDirectory:(NSString *)path;
- (BOOL)isProtectedSystemRootPath:(NSString *)path;
- (BOOL)itemExistsAtDestinationForSource:(NSString *)source directory:(NSString *)directory;

- (BOOL)copyItemAtPath:(NSString *)source toDirectory:(NSString *)destination error:(NSError **)error;
- (BOOL)moveItemAtPath:(NSString *)source toDirectory:(NSString *)destination error:(NSError **)error;
- (BOOL)copyItemAtPath:(NSString *)source
          toDirectory:(NSString *)destination
       conflictPolicy:(IP1FileConflictPolicy)policy
                error:(NSError **)error;
- (BOOL)moveItemAtPath:(NSString *)source
          toDirectory:(NSString *)destination
       conflictPolicy:(IP1FileConflictPolicy)policy
                error:(NSError **)error;
- (NSArray *)filesWithExtension:(NSString *)extension underPath:(NSString *)rootPath;
- (unsigned long long)recursiveSizeOfPath:(NSString *)path;

@end
