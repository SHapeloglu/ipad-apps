#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>

@interface NFCDelegate : NSObject
@end

@implementation NFCDelegate

- (void)readerSession:(id)session didDetectTags:(NSArray *)tags
{
    printf("\n=== TAG DETECTED ===\n");

    for (id tag in tags) {
        printf("Tag: %s\n", [[tag description] UTF8String]);

        SEL sel;

        sel = NSSelectorFromString(@"UID");
        if ([tag respondsToSelector:sel]) {
            NSData *uid = ((id (*)(id, SEL))objc_msgSend)(tag, sel);
            printf("UID: %s\n", [[uid description] UTF8String]);
        }

        sel = NSSelectorFromString(@"tagID");
        if ([tag respondsToSelector:sel]) {
            NSData *tagID = ((id (*)(id, SEL))objc_msgSend)(tag, sel);
            printf("Tag ID: %s\n", [[tagID description] UTF8String]);
        }

        sel = NSSelectorFromString(@"atqa");
        if ([tag respondsToSelector:sel]) {
            NSData *atqa = ((id (*)(id, SEL))objc_msgSend)(tag, sel);
            printf("ATQA: %s\n", [[atqa description] UTF8String]);
        }

        sel = NSSelectorFromString(@"sak");
        if ([tag respondsToSelector:sel]) {
            NSData *sak = ((id (*)(id, SEL))objc_msgSend)(tag, sel);
            printf("SAK: %s\n", [[sak description] UTF8String]);
        }

        sel = NSSelectorFromString(@"technology");
        if ([tag respondsToSelector:sel]) {
            unsigned int tech =
                ((unsigned int (*)(id, SEL))objc_msgSend)(tag, sel);

            printf("Technology: %u\n", tech);
        }

        SEL connectSel = NSSelectorFromString(@"connectTag:");

        if ([session respondsToSelector:connectSel]) {
            BOOL connected =
                ((BOOL (*)(id, SEL, id))objc_msgSend)(
                    session,
                    connectSel,
                    tag
                );

            printf("Connect: %s\n",
                   connected ? "YES" : "NO");
        }
    }
}

@end

int main(void)
{
    @autoreleasepool {
        printf("=== iPhone 6s NFC Reader ===\n");

        void *handle = dlopen(
            "/System/Library/PrivateFrameworks/NearField.framework/NearField",
            RTLD_NOW
        );

        if (!handle) {
            printf("NearField load failed: %s\n", dlerror());
            return 1;
        }

        Class hwClass = objc_getClass("NFHardwareManager");

        if (!hwClass) {
            printf("NFHardwareManager missing\n");
            return 2;
        }

        id manager =
            ((id (*)(id, SEL))objc_msgSend)(
                (id)hwClass,
                NSSelectorFromString(@"sharedHardwareManager")
            );

        if (!manager) {
            printf("Hardware manager unavailable\n");
            return 3;
        }

        printf("[+] Hardware manager ready\n");

        NFCDelegate *delegate = [NFCDelegate new];

        SEL startSel =
            NSSelectorFromString(@"startReaderSession:");

        if (![manager respondsToSelector:startSel]) {
            printf("startReaderSessionWithActionSheetUI missing\n");
            return 4;
        }

        void (^callback)(id, NSError *) =
        ^(id session, NSError *error) {

            if (error) {
                printf("Reader session error: %s\n",
                       [[error description] UTF8String]);
                return;
            }

            if (!session) {
                printf("Reader session is NULL\n");
                return;
            }

            printf("[+] Reader session created: %s\n",
                   [[session description] UTF8String]);

            SEL delegateSel =
                NSSelectorFromString(@"setDelegate:");

            if ([session respondsToSelector:delegateSel]) {
                ((void (*)(id, SEL, id))objc_msgSend)(
                    session,
                    delegateSel,
                    delegate
                );

                printf("[+] Delegate installed\n");
            }

            SEL pollSel =
                NSSelectorFromString(@"startPolling");

            if ([session respondsToSelector:pollSel]) {
                BOOL ok =
                    ((BOOL (*)(id, SEL))objc_msgSend)(
                        session,
                        pollSel
                    );

                printf("[+] startPolling = %s\n",
                       ok ? "YES" : "NO");
            }
        };

        ((id (*)(id, SEL, id))objc_msgSend)(
            manager,
            startSel,
            callback
        );

        printf("[+] Waiting for NFC tag...\n");
        printf("[+] Hold a tag near the top of the iPhone\n");

        [[NSRunLoop currentRunLoop] run];
    }

    return 0;
}
