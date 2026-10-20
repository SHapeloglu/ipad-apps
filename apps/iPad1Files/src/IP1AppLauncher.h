#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IP1AppLauncher : NSObject
+ (BOOL)canOpenRegistration:(NSDictionary *)registration;
+ (BOOL)openPath:(NSString *)path withRegistration:(NSDictionary *)registration;
+ (BOOL)canOpenRegisteredAppForPath:(NSString *)path;
+ (BOOL)openRegisteredAppForPath:(NSString *)path;
+ (BOOL)canOpenPDFReader;
+ (BOOL)openPDFReaderWithPath:(NSString *)path;
+ (BOOL)openFilesWithPath:(NSString *)path;
@end
