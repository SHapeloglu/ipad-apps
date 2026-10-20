#import <Foundation/Foundation.h>

@interface IP1FileItem : NSObject {
    NSString *_path;
    NSString *_name;
    BOOL _directory;
    unsigned long long _size;
    NSDate *_modifiedDate;
}

@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, assign, getter=isDirectory) BOOL directory;
@property(nonatomic, assign) unsigned long long size;
@property(nonatomic, retain) NSDate *modifiedDate;

+ (IP1FileItem *)itemWithPath:(NSString *)path;
- (NSString *)extension;
- (NSString *)formattedSize;

@end
