#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    VNCQualityFast = 0,
    VNCQualityBalanced = 1,
    VNCQualityQuality = 2
} VNCQualityProfile;

@protocol VNCClientDelegate <NSObject>
- (void)vncClientStatus:(NSString *)status;
- (void)vncClientFramebuffer:(UIImage *)image width:(NSUInteger)width height:(NSUInteger)height;
- (void)vncClientDisconnected:(NSString *)reason;
@optional
- (void)vncClientClipboardText:(NSString *)text;
- (void)vncClientStatsFPS:(CGFloat)fps kbps:(CGFloat)kbps encoding:(NSString *)encoding quality:(NSString *)quality;
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
    VNCQualityProfile _qualityProfile;
    NSUInteger _serverBytesPerPixel;
    BOOL _adaptiveQualityEnabled;
    NSUInteger _slowFrames;
    NSUInteger _fastFrames;
    NSTimeInterval _lastQualityChange;
    BOOL _preferTight;
    NSTimeInterval _statsStart;
    NSUInteger _statsFrames;
    unsigned long long _statsBytes;
    NSString *_lastEncoding;
}
@property (nonatomic, assign) id<VNCClientDelegate> delegate;
@property (nonatomic, readonly) NSUInteger framebufferWidth;
@property (nonatomic, readonly) NSUInteger framebufferHeight;
@property (nonatomic, assign) VNCQualityProfile qualityProfile;
@property (nonatomic, assign) BOOL adaptiveQualityEnabled;
@property (nonatomic, assign) BOOL preferTight;
- (id)initWithHost:(NSString *)host port:(NSInteger)port password:(NSString *)password;
- (void)connect;
- (void)disconnect;
- (void)sendPointerX:(NSUInteger)x y:(NSUInteger)y buttons:(uint8_t)buttons;
- (void)sendKeySym:(uint32_t)keysym down:(BOOL)down;
- (void)sendClipboardText:(NSString *)text;
@end
