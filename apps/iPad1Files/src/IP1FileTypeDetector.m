#import "IP1FileTypeDetector.h"

@implementation IP1FileTypeDetector

+ (BOOL)extension:(NSString *)ext inList:(NSArray *)list {
    return [list containsObject:[ext lowercaseString]];
}

+ (IP1FileType)typeForPath:(NSString *)path {
    NSString *ext = [[path pathExtension] lowercaseString];

    if ([self extension:ext inList:[NSArray arrayWithObjects:@"txt", @"log", @"md", @"csv", @"json", @"xml", @"plist", nil]]) {
        return IP1FileTypeText;
    }
    if ([self extension:ext inList:[NSArray arrayWithObjects:@"jpg", @"jpeg", @"png", @"gif", @"bmp", nil]]) {
        return IP1FileTypeImage;
    }
    if ([ext isEqualToString:@"pdf"]) {
        return IP1FileTypePDF;
    }
    if ([self extension:ext inList:[NSArray arrayWithObjects:@"mp3", @"m4a", @"aac", @"wav", nil]]) {
        return IP1FileTypeAudio;
    }
    if ([self extension:ext inList:[NSArray arrayWithObjects:@"mp4", @"m4v", @"mov", @"avi", nil]]) {
        return IP1FileTypeVideo;
    }
    if ([self extension:ext inList:[NSArray arrayWithObjects:@"zip", @"rar", @"7z", @"tar", @"gz", nil]]) {
        return IP1FileTypeArchive;
    }
    return IP1FileTypeUnknown;
}

+ (NSString *)displayNameForType:(IP1FileType)type {
    switch (type) {
        case IP1FileTypeText: return @"Metin";
        case IP1FileTypeImage: return @"Görsel";
        case IP1FileTypePDF: return @"PDF";
        case IP1FileTypeAudio: return @"Ses";
        case IP1FileTypeVideo: return @"Video";
        case IP1FileTypeArchive: return @"Arşiv";
        default: return @"Dosya";
    }
}

@end
