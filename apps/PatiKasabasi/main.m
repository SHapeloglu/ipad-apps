#import <UIKit/UIKit.h>
#import "src/PKAppDelegate.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = UIApplicationMain(argc, argv, nil, NSStringFromClass([PKAppDelegate class]));
    [pool drain];
    return result;
}
