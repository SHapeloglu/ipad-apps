#import <Foundation/Foundation.h>
@interface IP1RootAuthorization : NSObject {
    BOOL _authorized;
}
+ (IP1RootAuthorization *)sharedAuthorization;
- (BOOL)isAuthorized;
- (void)markVerifiedForCurrentSession;
- (void)invalidate;
@end
