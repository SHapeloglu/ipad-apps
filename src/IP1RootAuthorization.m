#import "IP1RootAuthorization.h"
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
