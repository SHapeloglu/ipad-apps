#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>

static void printMethods(Class cls)
{
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);

    printf("\n[%s] %u methods\n", class_getName(cls), count);

    for (unsigned int i = 0; i < count; i++) {
        SEL selector = method_getName(methods[i]);
        printf("  %s\n", sel_getName(selector));
    }

    free(methods);
}

static id sendId(id obj, SEL sel)
{
    return ((id (*)(id, SEL))objc_msgSend)(obj, sel);
}

static unsigned int sendUInt(id obj, SEL sel)
{
    return ((unsigned int (*)(id, SEL))objc_msgSend)(obj, sel);
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        printf("=== iPhone 6s NFC Probe ===\n\n");

        const char *path =
            "/System/Library/PrivateFrameworks/"
            "NearField.framework/NearField";

        void *handle = dlopen(path, RTLD_NOW);

        if (!handle) {
            printf("[-] NearField load FAILED\n");
            printf("    %s\n", dlerror());
            return 1;
        }

        printf("[+] NearField loaded\n");

        Class managerClass = objc_getClass("NFHardwareManager");
        Class readerClass = objc_getClass("NFReaderSession");
        Class tagClass = objc_getClass("NFTag");

        printf("[+] NFHardwareManager: %s\n",
               managerClass ? "FOUND" : "NOT FOUND");

        printf("[+] NFReaderSession: %s\n",
               readerClass ? "FOUND" : "NOT FOUND");

        printf("[+] NFTag: %s\n",
               tagClass ? "FOUND" : "NOT FOUND");

        if (!managerClass)
            return 2;

        SEL sharedSelector =
            sel_registerName("sharedHardwareManager");

        id manager =
            ((id (*)(id, SEL))objc_msgSend)(
                (id)managerClass,
                sharedSelector
            );

        printf("\n[+] sharedHardwareManager = %p\n",
               (__bridge void *)manager);

        if (!manager) {
            printf("[-] Hardware manager unavailable\n");
            return 3;
        }

        SEL supportSelector =
            sel_registerName("getHwSupport");

        if ([manager respondsToSelector:supportSelector]) {
            unsigned int hwSupport =
                sendUInt(manager, supportSelector);

            printf("[+] getHwSupport = 0x%08x (%u)\n",
                   hwSupport,
                   hwSupport);
        }

        SEL controllerSelector =
            sel_registerName("controllerInfo");

        if ([manager respondsToSelector:controllerSelector]) {
            id info =
                sendId(manager, controllerSelector);

            printf("[+] Controller info: %s\n",
                   info ? [[info description] UTF8String] : "(null)");
        }

        printf("\n=== NFReaderSession methods ===\n");

        if (readerClass)
            printMethods(readerClass);

        printf("\n=== NFTag methods ===\n");

        if (tagClass)
            printMethods(tagClass);

        printf("\n[+] Probe finished\n");

        dlclose(handle);
    }

    return 0;
}
