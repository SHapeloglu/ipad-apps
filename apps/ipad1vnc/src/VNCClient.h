#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol VNCClientDelegate <NSObject>
- (void)vncClientStatus:(NSString *)status;
- (void)vncClientFramebuffer:(UIImage *)image width:(NSUInteger)width height:(NSUInteger)height;
- (void)vncClientDisconnected:(NSString *)reason;
@end

@interface VNCClient : NSObject {
    NSString *_host;
    NSInteger _port;
    NSString *_password;
    id<VNCClientDelegate> _delegate;
    int _sock;
    BOOL _running;
    NSUInteger _fbWidth;
    NSUInteger _fbHeight;
    NSMutableData *_framebuffer;
    NSLock *_writeLock;
}
@property (nonatomic, assign) id<VNCClientDelegate> delegate;
@property (nonatomic, readonly) NSUInteger framebufferWidth;
@property (nonatomic, readonly) NSUInteger framebufferHeight;
- (id)initWithHost:(NSString *)host port:(NSInteger)port password:(NSString *)password;
- (void)connect;
- (void)disconnect;
- (void)sendPointerX:(NSUInteger)x y:(NSUInteger)y buttons:(uint8_t)buttons;
- (void)sendKeySym:(uint32_t)keysym down:(BOOL)down;
@end
