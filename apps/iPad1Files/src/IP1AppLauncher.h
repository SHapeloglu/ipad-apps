#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IP1AppLauncher : NSObject
+ (BOOL)canOpenPDFReader;
+ (BOOL)openPDFReaderWithPath:(NSString *)path;
+ (BOOL)openFilesWithPath:(NSString *)path;
@end
