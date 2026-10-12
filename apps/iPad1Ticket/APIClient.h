#import <Foundation/Foundation.h>

@protocol APIClientDelegate <NSObject>
- (void)apiClientDidReceiveResult:(NSDictionary *)result;
- (void)apiClientDidFailWithMessage:(NSString *)message;
@end

@interface APIClient : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    id<APIClientDelegate> _delegate;
    NSMutableData *_responseData;
    NSURLConnection *_connection;
}
@property (nonatomic, assign) id<APIClientDelegate> delegate;
- (void)verifyQRCodeText:(NSString *)qrText;
- (void)cancel;
@end
