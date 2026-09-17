#import "IP1AppLauncher.h"

@implementation IP1AppLauncher

+ (NSString *)escapedPath:(NSString *)path {
    return [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL)canOpenPDFReader {
    NSURL *url = [NSURL URLWithString:@"ipad1pdf://"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (BOOL)openPDFReaderWithPath:(NSString *)path {
    if (![self canOpenPDFReader]) return NO;

    NSString *urlString =
        [NSString stringWithFormat:@"ipad1pdf://open?path=%@", [self escapedPath:path]];
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

+ (BOOL)openFilesWithPath:(NSString *)path {
    NSString *urlString =
        [NSString stringWithFormat:@"ipad1files://open?path=%@", [self escapedPath:path]];
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
