#import <Foundation/Foundation.h>

typedef enum {
    IP1FileTypeUnknown = 0,
    IP1FileTypeText,
    IP1FileTypeImage,
    IP1FileTypePDF,
    IP1FileTypeAudio,
    IP1FileTypeVideo,
    IP1FileTypeArchive
} IP1FileType;

@interface IP1FileTypeDetector : NSObject
+ (IP1FileType)typeForPath:(NSString *)path;
+ (NSString *)displayNameForType:(IP1FileType)type;
@end
