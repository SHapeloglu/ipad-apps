#!/usr/bin/env python3
from pathlib import Path

root = Path(".")
if not (root / "src").is_dir() or not (root / "Makefile").exists():
    raise SystemExit("Bu script iPad1Files repo kökünde çalıştırılmalıdır.")

# iPad1Player/PDFReader registry
p = root / "src/IP1AppRegistry.m"
p.write_text(r"""#import "IP1AppRegistry.h"

@implementation IP1AppRegistry

+ (NSArray *)defaultRegistrations {
    return [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"pdf", @"extension",
            @"iPad1PDFReader", @"name",
            @"ipad1pdf", @"scheme",
            @"ipad1pdf://open?path=%@", @"url", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"mkv", @"extension",
            @"iPad1Player", @"name",
            @"ipad1player", @"scheme",
            @"ipad1player://open?path=%@", @"url", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"mp4", @"extension",
            @"iPad1Player", @"name",
            @"ipad1player", @"scheme",
            @"ipad1player://open?path=%@", @"url", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"mov", @"extension",
            @"iPad1Player", @"name",
            @"ipad1player", @"scheme",
            @"ipad1player://open?path=%@", @"url", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"m4v", @"extension",
            @"iPad1Player", @"name",
            @"ipad1player", @"scheme",
            @"ipad1player://open?path=%@", @"url", nil],
        nil];
}

+ (NSDictionary *)registrationForExtension:(NSString *)extension {
    if (![extension length]) return nil;
    NSString *ext=[extension lowercaseString];
    if ([ext hasPrefix:@"."]) ext=[ext substringFromIndex:1];
    for (NSDictionary *item in [self defaultRegistrations]) {
        if ([[item objectForKey:@"extension"] isEqualToString:ext]) return item;
    }
    return nil;
}

+ (NSDictionary *)registrationForPath:(NSString *)path {
    return [self registrationForExtension:[path pathExtension]];
}

+ (NSString *)displayNameForPath:(NSString *)path {
    return [[self registrationForPath:path] objectForKey:@"name"];
}

@end
""", encoding="utf-8")

# MKV type recognition
p = root / "src/IP1FileTypeDetector.m"
s = p.read_text(encoding="utf-8")
s = s.replace('@"mp4", @"m4v", @"mov", @"avi"',
              '@"mkv", @"mp4", @"m4v", @"mov", @"avi"')
p.write_text(s, encoding="utf-8")

# Lightweight Recents
(root / "src/IP1RecentManager.h").write_text(r"""#import <Foundation/Foundation.h>
@interface IP1RecentManager : NSObject
+ (IP1RecentManager *)sharedManager;
- (void)recordPath:(NSString *)path;
- (NSArray *)recentPaths;
- (void)removePath:(NSString *)path;
- (void)pruneMissingPaths;
@end
""", encoding="utf-8")

(root / "src/IP1RecentManager.m").write_text(r"""#import "IP1RecentManager.h"
#define IP1RecentPathsKey @"IP1RecentPaths"
#define IP1RecentMaximumCount 20
@implementation IP1RecentManager
+ (IP1RecentManager *)sharedManager {
    static IP1RecentManager *instance=nil;
    @synchronized(self) {
        if(!instance) instance=[[IP1RecentManager alloc] init];
    }
    return instance;
}
- (NSMutableArray *)mutableStoredPaths {
    NSArray *a=[[NSUserDefaults standardUserDefaults] arrayForKey:IP1RecentPathsKey];
    return a ? [NSMutableArray arrayWithArray:a] : [NSMutableArray array];
}
- (void)recordPath:(NSString *)path {
    if(![path length]) return;
    NSMutableArray *a=[self mutableStoredPaths];
    [a removeObject:path];
    [a insertObject:path atIndex:0];
    while([a count] > IP1RecentMaximumCount) [a removeLastObject];
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:IP1RecentPathsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray *)recentPaths {
    [self pruneMissingPaths];
    NSArray *a=[[NSUserDefaults standardUserDefaults] arrayForKey:IP1RecentPathsKey];
    return a ? a : [NSArray array];
}
- (void)removePath:(NSString *)path {
    NSMutableArray *a=[self mutableStoredPaths];
    [a removeObject:path];
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:IP1RecentPathsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)pruneMissingPaths {
    NSMutableArray *a=[self mutableStoredPaths];
    NSFileManager *fm=[NSFileManager defaultManager];
    NSInteger i=(NSInteger)[a count]-1;
    while(i>=0) {
        if(![fm fileExistsAtPath:[a objectAtIndex:(NSUInteger)i]])
            [a removeObjectAtIndex:(NSUInteger)i];
        i--;
    }
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:IP1RecentPathsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
""", encoding="utf-8")

# Session-only authorization state. This does NOT verify a password.
(root / "src/IP1RootAuthorization.h").write_text(r"""#import <Foundation/Foundation.h>
@interface IP1RootAuthorization : NSObject {
    BOOL _authorized;
}
+ (IP1RootAuthorization *)sharedAuthorization;
- (BOOL)isAuthorized;
- (void)markVerifiedForCurrentSession;
- (void)invalidate;
@end
""", encoding="utf-8")

(root / "src/IP1RootAuthorization.m").write_text(r"""#import "IP1RootAuthorization.h"
@implementation IP1RootAuthorization
+ (IP1RootAuthorization *)sharedAuthorization {
    static IP1RootAuthorization *instance=nil;
    @synchronized(self) {
        if(!instance) instance=[[IP1RootAuthorization alloc] init];
    }
    return instance;
}
- (BOOL)isAuthorized { return _authorized; }
- (void)markVerifiedForCurrentSession { _authorized=YES; }
- (void)invalidate { _authorized=NO; }
@end
""", encoding="utf-8")

# Add new M files to Makefile
p = root / "Makefile"
s = p.read_text(encoding="utf-8")
anchor = "\tsrc/IP1FavoritesManager.m \\\n"
if "src/IP1RecentManager.m" not in s and anchor in s:
    s = s.replace(anchor, anchor + "\tsrc/IP1RecentManager.m \\\n\tsrc/IP1RootAuthorization.m \\\n", 1)
p.write_text(s, encoding="utf-8")

print("Temel suite routing + recents + session authorization altyapısı uygulandı.")
print("Not: Gerçek root parola doğrulayıcısı fiziksel iPad testi olmadan etkinleştirilmemelidir.")
