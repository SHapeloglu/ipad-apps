#import "APIClient.h"

// SUNUCU AYARLARI
// Uretimde mutlaka HTTPS kullanin.
static NSString * const IP1APIURL = @"https://SITENIZ.example/api/checkin-mobile.php";
static NSString * const IP1APIToken = @"BURAYA_CHECKIN_WRITE_API_TOKEN";

@implementation APIClient
@synthesize delegate = _delegate;

- (NSString *)tokenFromQRCodeText:(NSString *)text {
    if (text == nil) return nil;
    NSString *trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange marker = [trimmed rangeOfString:@"?t="];
    if (marker.location != NSNotFound) {
        NSString *token = [trimmed substringFromIndex:(marker.location + marker.length)];
        NSRange amp = [token rangeOfString:@"&"];
        if (amp.location != NSNotFound) token = [token substringToIndex:amp.location];
        return [token stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    marker = [trimmed rangeOfString:@"&t="];
    if (marker.location != NSNotFound) {
        NSString *token = [trimmed substringFromIndex:(marker.location + marker.length)];
        NSRange amp = [token rangeOfString:@"&"];
        if (amp.location != NSNotFound) token = [token substringToIndex:amp.location];
        return [token stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return trimmed;
}

- (void)verifyQRCodeText:(NSString *)qrText {
    [self cancel];
    NSString *token = [self tokenFromQRCodeText:qrText];
    if ([token length] < 16) {
        if ([_delegate respondsToSelector:@selector(apiClientDidFailWithMessage:)])
            [_delegate apiClientDidFailWithMessage:@"QR kodu gecersiz veya eksik."];
        return;
    }

    NSURL *url = [NSURL URLWithString:IP1APIURL];
    if (url == nil) {
        [_delegate apiClientDidFailWithMessage:@"API adresi yapilandirilmamis."];
        return;
    }

    NSDictionary *bodyObject = [NSDictionary dictionaryWithObject:token forKey:@"token"];
    NSError *jsonError = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:bodyObject options:0 error:&jsonError];
    if (body == nil) {
        [_delegate apiClientDidFailWithMessage:@"Istek hazirlanamadi."];
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:15.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if ([IP1APIToken length] > 0 && ![IP1APIToken hasPrefix:@"BURAYA_"]) {
        [request setValue:[NSString stringWithFormat:@"Bearer %@", IP1APIToken]
       forHTTPHeaderField:@"Authorization"];
    }
    [request setHTTPBody:body];

    _responseData = [[NSMutableData alloc] init];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&error];
    if (![obj isKindOfClass:[NSDictionary class]]) {
        [_delegate apiClientDidFailWithMessage:@"Sunucudan gecersiz cevap alindi."];
    } else {
        [_delegate apiClientDidReceiveResult:(NSDictionary *)obj];
    }
    [self cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"Baglanti hatasi: %@", [error localizedDescription]];
    [_delegate apiClientDidFailWithMessage:message];
    [self cancel];
}

- (void)cancel {
    if (_connection) {
        [_connection cancel];
        [_connection release];
        _connection = nil;
    }
    [_responseData release];
    _responseData = nil;
}

- (void)dealloc {
    [self cancel];
    [super dealloc];
}
@end
