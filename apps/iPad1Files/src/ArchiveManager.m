#import "ArchiveManager.h"
#import "IP1DiskInfo.h"
#import "minizip/unzip.h"
#import "minizip/zip.h"
#import <sys/stat.h>

#define IP1ArchiveBufferSize 32768

static NSError *IP1ArchiveError(NSInteger code, NSString *message) {
    return [NSError errorWithDomain:@"iPad1Files.Archive"
                               code:code
                           userInfo:[NSDictionary dictionaryWithObject:message
                                                                forKey:NSLocalizedDescriptionKey]];
}

static NSString *IP1ZipString(const char *bytes) {
    if (!bytes) return nil;
    NSString *s = [NSString stringWithUTF8String:bytes];
    if (!s) {
        s = [[[NSString alloc] initWithCString:bytes
                                      encoding:NSISOLatin1StringEncoding] autorelease];
    }
    return s;
}

static BOOL IP1IsSafeRelativeArchivePath(NSString *name) {
    if (![name length]) return NO;

    NSString *n = [name stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    if ([n hasPrefix:@"/"]) return NO;

    NSArray *parts = [n componentsSeparatedByString:@"/"];
    for (NSString *part in parts) {
        if ([part isEqualToString:@".."]) return NO;
    }
    return YES;
}

static NSString *IP1SafeOutputPath(NSString *root, NSString *relative) {
    if (!IP1IsSafeRelativeArchivePath(relative)) return nil;

    NSString *normalized = [relative stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    NSString *candidate = [[root stringByAppendingPathComponent:normalized] stringByStandardizingPath];
    NSString *rootStd = [root stringByStandardizingPath];
    NSString *prefix = [rootStd hasSuffix:@"/"] ? rootStd : [rootStd stringByAppendingString:@"/"];

    if (![candidate isEqualToString:rootStd] && ![candidate hasPrefix:prefix]) return nil;
    return candidate;
}

static NSString *IP1UniquePath(NSString *candidate) {
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:candidate]) return candidate;

    NSString *dir = [candidate stringByDeletingLastPathComponent];
    NSString *name = [candidate lastPathComponent];
    NSString *ext = [name pathExtension];
    NSString *base = [name stringByDeletingPathExtension];

    NSUInteger index = 2;
    while (1) {
        NSString *newName;
        if ([ext length]) {
            newName = [NSString stringWithFormat:@"%@ (%lu).%@",
                       base, (unsigned long)index, ext];
        } else {
            newName = [NSString stringWithFormat:@"%@ (%lu)",
                       base, (unsigned long)index];
        }
        NSString *p = [dir stringByAppendingPathComponent:newName];
        if (![fm fileExistsAtPath:p]) return p;
        index++;
    }
}

@interface ArchiveManager ()
- (BOOL)addPath:(NSString *)path
    archiveName:(NSString *)archiveName
        toZip:(zipFile)zip
          error:(NSError **)error;
@end

@implementation ArchiveManager

+ (ArchiveManager *)sharedManager {
    static ArchiveManager *instance = nil;
    @synchronized(self) {
        if (!instance) instance = [[ArchiveManager alloc] init];
    }
    return instance;
}

- (NSArray *)entriesInZipAtPath:(NSString *)zipPath error:(NSError **)error {
    unzFile zip = unzOpen([zipPath fileSystemRepresentation]);
    if (!zip) {
        if (error) *error = IP1ArchiveError(3001, @"ZIP dosyası açılamadı.");
        return nil;
    }

    NSMutableArray *entries = [NSMutableArray array];
    int rc = unzGoToFirstFile(zip);

    if (rc == UNZ_END_OF_LIST_OF_FILE) {
        unzClose(zip);
        return entries;
    }

    while (rc == UNZ_OK) {
        unz_file_info info;
        char nameBuffer[4097];
        memset(&info, 0, sizeof(info));
        memset(nameBuffer, 0, sizeof(nameBuffer));

        rc = unzGetCurrentFileInfo(zip, &info,
                                   nameBuffer, sizeof(nameBuffer) - 1,
                                   NULL, 0, NULL, 0);
        if (rc != UNZ_OK) {
            unzClose(zip);
            if (error) *error = IP1ArchiveError(3002, @"ZIP entry bilgisi okunamadı.");
            return nil;
        }

        NSString *name = IP1ZipString(nameBuffer);
        if (!name || !IP1IsSafeRelativeArchivePath(name)) {
            unzClose(zip);
            if (error) *error = IP1ArchiveError(3003, @"ZIP içinde güvenli olmayan yol bulundu.");
            return nil;
        }

        BOOL directory = [name hasSuffix:@"/"];
        unsigned long mode = (info.external_fa >> 16) & 0xffff;
        BOOL symlink = ((mode & S_IFMT) == S_IFLNK);

        NSDictionary *entry =
            [NSDictionary dictionaryWithObjectsAndKeys:
                name, @"name",
                [NSNumber numberWithUnsignedLongLong:info.uncompressed_size], @"size",
                [NSNumber numberWithUnsignedLongLong:info.compressed_size], @"compressed",
                [NSNumber numberWithBool:directory], @"directory",
                [NSNumber numberWithBool:symlink], @"symlink",
                [NSNumber numberWithUnsignedLong:info.compression_method], @"method",
                nil];
        [entries addObject:entry];

        rc = unzGoToNextFile(zip);
    }

    unzClose(zip);

    if (rc != UNZ_END_OF_LIST_OF_FILE) {
        if (error) *error = IP1ArchiveError(3004, @"ZIP merkez dizini bozuk.");
        return nil;
    }

    return entries;
}

- (NSString *)extractZipAtPath:(NSString *)zipPath
                   toDirectory:(NSString *)destinationDirectory
                         error:(NSError **)error {
    NSArray *entries = [self entriesInZipAtPath:zipPath error:error];
    if (!entries) return nil;

    unsigned long long required = 0;
    for (NSDictionary *entry in entries) {
        if ([[entry objectForKey:@"symlink"] boolValue]) {
            if (error) *error = IP1ArchiveError(3010, @"ZIP symbolic link içeriyor; güvenlik nedeniyle çıkarılmadı.");
            return nil;
        }

        unsigned long method = [[entry objectForKey:@"method"] unsignedLongValue];
        if (method != 0 && method != Z_DEFLATED) {
            if (error) *error = IP1ArchiveError(3011, @"ZIP içinde desteklenmeyen sıkıştırma yöntemi var.");
            return nil;
        }

        if (![[entry objectForKey:@"directory"] boolValue]) {
            required += [[entry objectForKey:@"size"] unsignedLongLongValue];
        }
    }

    unsigned long long freeBytes = [IP1DiskInfo freeBytesAtPath:destinationDirectory];
    unsigned long long reserve = 16ULL * 1024ULL * 1024ULL;
    if (freeBytes <= reserve || required > freeBytes - reserve) {
        if (error) *error = IP1ArchiveError(3012, @"Arşivi çıkarmak için yeterli boş alan yok.");
        return nil;
    }

    NSString *base = [[zipPath lastPathComponent] stringByDeletingPathExtension];
    if (![base length]) base = @"Archive";

    NSString *root =
        IP1UniquePath([destinationDirectory stringByAppendingPathComponent:base]);

    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm createDirectoryAtPath:root
       withIntermediateDirectories:NO
                        attributes:nil
                             error:error]) {
        return nil;
    }

    unzFile zip = unzOpen([zipPath fileSystemRepresentation]);
    if (!zip) {
        [fm removeItemAtPath:root error:nil];
        if (error) *error = IP1ArchiveError(3013, @"ZIP dosyası açılamadı.");
        return nil;
    }

    int rc = unzGoToFirstFile(zip);
    if (rc == UNZ_END_OF_LIST_OF_FILE) {
        unzClose(zip);
        return root;
    }

    unsigned char *buffer = (unsigned char *)malloc(IP1ArchiveBufferSize);
    if (!buffer) {
        unzClose(zip);
        [fm removeItemAtPath:root error:nil];
        if (error) *error = IP1ArchiveError(3014, @"Bellek ayrılamadı.");
        return nil;
    }

    BOOL ok = YES;

    while (rc == UNZ_OK && ok) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        unz_file_info info;
        char nameBuffer[4097];
        memset(&info, 0, sizeof(info));
        memset(nameBuffer, 0, sizeof(nameBuffer));

        if (unzGetCurrentFileInfo(zip, &info,
                                  nameBuffer, sizeof(nameBuffer) - 1,
                                  NULL, 0, NULL, 0) != UNZ_OK) {
            if (error) *error = IP1ArchiveError(3015, @"ZIP entry bilgisi okunamadı.");
            ok = NO;
            [pool drain];
            break;
        }

        NSString *name = IP1ZipString(nameBuffer);
        NSString *output = IP1SafeOutputPath(root, name);

        if (!output) {
            if (error) *error = IP1ArchiveError(3016, @"ZIP Slip/path traversal engellendi.");
            ok = NO;
            [pool drain];
            break;
        }

        unsigned long mode = (info.external_fa >> 16) & 0xffff;
        if ((mode & S_IFMT) == S_IFLNK) {
            if (error) *error = IP1ArchiveError(3017, @"Symbolic link entry reddedildi.");
            ok = NO;
            [pool drain];
            break;
        }

        if ([name hasSuffix:@"/"]) {
            if (![fm createDirectoryAtPath:output
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:error]) {
                ok = NO;
            }
        } else {
            NSString *parent = [output stringByDeletingLastPathComponent];
            if (![fm fileExistsAtPath:parent] &&
                ![fm createDirectoryAtPath:parent
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:error]) {
                ok = NO;
            }

            if (ok && [fm fileExistsAtPath:output]) {
                output = IP1UniquePath(output);
            }

            if (ok && unzOpenCurrentFile(zip) != UNZ_OK) {
                if (error) *error = IP1ArchiveError(3018, @"ZIP entry açılamadı; şifreli ZIP desteklenmiyor.");
                ok = NO;
            }

            FILE *out = NULL;
            if (ok) {
                out = fopen([output fileSystemRepresentation], "wb");
                if (!out) {
                    if (error) *error = IP1ArchiveError(3019, @"Çıktı dosyası oluşturulamadı.");
                    ok = NO;
                }
            }

            if (ok) {
                while (1) {
                    int got = unzReadCurrentFile(zip, buffer, IP1ArchiveBufferSize);
                    if (got < 0) {
                        if (error) *error = IP1ArchiveError(3020, @"ZIP verisi okunamadı.");
                        ok = NO;
                        break;
                    }
                    if (got == 0) break;

                    if (fwrite(buffer, 1, (size_t)got, out) != (size_t)got) {
                        if (error) *error = IP1ArchiveError(3021, @"Dosya yazılırken disk hatası oluştu.");
                        ok = NO;
                        break;
                    }
                }
            }

            if (out) fclose(out);

            int closeRC = unzCloseCurrentFile(zip);
            if (ok && closeRC != UNZ_OK) {
                if (error) *error = IP1ArchiveError(3022, @"ZIP entry CRC doğrulaması başarısız.");
                ok = NO;
            }

            if (!ok) [fm removeItemAtPath:output error:nil];
        }

        [pool drain];
        if (ok) rc = unzGoToNextFile(zip);
    }

    free(buffer);
    unzClose(zip);

    if (!ok || (rc != UNZ_END_OF_LIST_OF_FILE && rc != UNZ_OK)) {
        return nil;
    }

    return root;
}

- (NSString *)createZipNamed:(NSString *)name
                   fromPaths:(NSArray *)paths
                 inDirectory:(NSString *)destinationDirectory
                       error:(NSError **)error {
    if (![paths count]) {
        if (error) *error = IP1ArchiveError(3030, @"ZIP oluşturmak için öğe seçilmedi.");
        return nil;
    }

    NSString *zipName = [name length] ? name : @"Archive.zip";
    if (![[[zipName pathExtension] lowercaseString] isEqualToString:@"zip"]) {
        zipName = [zipName stringByAppendingPathExtension:@"zip"];
    }

    if ([zipName rangeOfString:@"/"].location != NSNotFound) {
        if (error) *error = IP1ArchiveError(3031, @"Geçersiz ZIP adı.");
        return nil;
    }

    NSString *zipPath =
        IP1UniquePath([destinationDirectory stringByAppendingPathComponent:zipName]);

    zipFile zip = zipOpen([zipPath fileSystemRepresentation], APPEND_STATUS_CREATE);
    if (!zip) {
        if (error) *error = IP1ArchiveError(3032, @"ZIP dosyası oluşturulamadı.");
        return nil;
    }

    BOOL ok = YES;

    for (NSString *path in paths) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        if (![self addPath:path
               archiveName:[path lastPathComponent]
                     toZip:zip
                     error:error]) {
            ok = NO;
            [pool drain];
            break;
        }
        [pool drain];
    }

    if (zipClose(zip, NULL) != ZIP_OK && ok) {
        if (error) *error = IP1ArchiveError(3033, @"ZIP kapatılırken hata oluştu.");
        ok = NO;
    }

    if (!ok) {
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
        return nil;
    }

    return zipPath;
}

- (BOOL)addPath:(NSString *)path
    archiveName:(NSString *)archiveName
          toZip:(zipFile)zip
          error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];

    BOOL isDirectory = NO;
    if (![fm fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (error) *error = IP1ArchiveError(3040, @"ZIP'e eklenecek öğe bulunamadı.");
        return NO;
    }

    if (isDirectory) {
        NSString *dirName =
            [archiveName hasSuffix:@"/"] ? archiveName : [archiveName stringByAppendingString:@"/"];

        zip_fileinfo zi;
        memset(&zi, 0, sizeof(zi));

        int rc = zipOpenNewFileInZip(zip,
                                     [dirName UTF8String],
                                     &zi,
                                     NULL, 0, NULL, 0, NULL,
                                     0, 0);
        if (rc != ZIP_OK || zipCloseFileInZip(zip) != ZIP_OK) {
            if (error) *error = IP1ArchiveError(3041, @"ZIP klasör entry oluşturulamadı.");
            return NO;
        }

        NSArray *children = [fm contentsOfDirectoryAtPath:path error:error];
        if (!children) return NO;

        for (NSString *child in children) {
            NSString *childPath = [path stringByAppendingPathComponent:child];
            NSString *childArchive = [dirName stringByAppendingString:child];

            if (![self addPath:childPath
                   archiveName:childArchive
                         toZip:zip
                         error:error]) {
                return NO;
            }
        }

        return YES;
    }

    NSDictionary *attrs = [fm attributesOfItemAtPath:path error:error];
    if (!attrs) return NO;

    unsigned long long size = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    if (size > 0xffffffffULL) {
        if (error) *error = IP1ArchiveError(3042, @"4 GB üzeri dosya ZIP64 gerektiriyor; ilk sürümde desteklenmiyor.");
        return NO;
    }

    zip_fileinfo zi;
    memset(&zi, 0, sizeof(zi));

    int rc = zipOpenNewFileInZip(zip,
                                 [archiveName UTF8String],
                                 &zi,
                                 NULL, 0, NULL, 0, NULL,
                                 Z_DEFLATED, Z_DEFAULT_COMPRESSION);
    if (rc != ZIP_OK) {
        if (error) *error = IP1ArchiveError(3043, @"ZIP dosya entry oluşturulamadı.");
        return NO;
    }

    FILE *in = fopen([path fileSystemRepresentation], "rb");
    if (!in) {
        zipCloseFileInZip(zip);
        if (error) *error = IP1ArchiveError(3044, @"ZIP'e eklenecek dosya açılamadı.");
        return NO;
    }

    unsigned char *buffer = (unsigned char *)malloc(IP1ArchiveBufferSize);
    if (!buffer) {
        fclose(in);
        zipCloseFileInZip(zip);
        if (error) *error = IP1ArchiveError(3045, @"Bellek ayrılamadı.");
        return NO;
    }

    BOOL ok = YES;
    while (1) {
        size_t got = fread(buffer, 1, IP1ArchiveBufferSize, in);

        if (got > 0 && zipWriteInFileInZip(zip, buffer, (unsigned int)got) != ZIP_OK) {
            if (error) *error = IP1ArchiveError(3046, @"ZIP verisi yazılamadı.");
            ok = NO;
            break;
        }

        if (got < IP1ArchiveBufferSize) {
            if (ferror(in)) {
                if (error) *error = IP1ArchiveError(3047, @"Kaynak dosya okunamadı.");
                ok = NO;
            }
            break;
        }
    }

    free(buffer);
    fclose(in);

    if (zipCloseFileInZip(zip) != ZIP_OK && ok) {
        if (error) *error = IP1ArchiveError(3048, @"ZIP dosya entry kapatılamadı.");
        ok = NO;
    }

    return ok;
}

@end
