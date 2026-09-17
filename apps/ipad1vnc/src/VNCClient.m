#import "VNCClient.h"
#import <CommonCrypto/CommonCryptor.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/socket.h>
#import <unistd.h>
#import <netinet/tcp.h>

static BOOL recvAll(int s, void *buf, size_t len){uint8_t*p=(uint8_t*)buf;while(len){ssize_t n=recv(s,p,len,0);if(n<=0)return NO;p+=n;len-=n;}return YES;}
static BOOL sendAll(int s,const void*buf,size_t len){const uint8_t*p=(const uint8_t*)buf;while(len){ssize_t n=send(s,p,len,0);if(n<=0)return NO;p+=n;len-=n;}return YES;}
static uint16_t readBE16(const uint8_t*p){return(uint16_t)((p[0]<<8)|p[1]);}
static uint32_t readBE32(const uint8_t*p){return((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|p[3];}
static void putBE16(uint8_t*p,uint16_t v){p[0]=v>>8;p[1]=v;}
static void putBE32(uint8_t*p,uint32_t v){p[0]=v>>24;p[1]=v>>16;p[2]=v>>8;p[3]=v;}
static uint8_t reverseBits(uint8_t b){b=(b&0xF0)>>4|(b&0x0F)<<4;b=(b&0xCC)>>2|(b&0x33)<<2;return(b&0xAA)>>1|(b&0x55)<<1;}

@implementation VNCClient
@synthesize delegate=_delegate,qualityProfile=_qualityProfile,adaptiveQualityEnabled=_adaptiveQualityEnabled;
- (NSUInteger)framebufferWidth{return _fbWidth;}
- (NSUInteger)framebufferHeight{return _fbHeight;}

- (id)initWithHost:(NSString*)host port:(NSInteger)port password:(NSString*)password{
    if((self=[super init])){_host=[host copy];_port=port;_password=[password copy];_sock=-1;_writeLock=[[NSLock alloc]init];_qualityProfile=VNCQualityBalanced;_serverBytesPerPixel=2;_adaptiveQualityEnabled=NO;_slowFrames=0;_fastFrames=0;_lastQualityChange=0;}
    return self;
}
- (void)dealloc{[self disconnect];[_host release];[_password release];[_framebuffer release];[_writeLock release];[super dealloc];}
- (void)notifyStatus:(NSString*)s{if([_delegate respondsToSelector:@selector(vncClientStatus:)])[_delegate vncClientStatus:s];}
- (void)notifyDisconnected:(NSString*)s{if([_delegate respondsToSelector:@selector(vncClientDisconnected:)])[_delegate vncClientDisconnected:s];}
- (void)statusOnMain:(NSString*)s{[self notifyStatus:s];}
- (void)disconnectOnMain:(NSString*)s{[self notifyDisconnected:s];}
- (void)frameOnMain:(UIImage*)img{if([_delegate respondsToSelector:@selector(vncClientFramebuffer:width:height:)])[_delegate vncClientFramebuffer:img width:_fbWidth height:_fbHeight];}
- (void)clipboardOnMain:(NSString*)text{if([_delegate respondsToSelector:@selector(vncClientClipboardText:)])[_delegate vncClientClipboardText:text];}

- (void)connect{if(_running)return;_running=YES;[NSThread detachNewThreadSelector:@selector(networkThread) toTarget:self withObject:nil];}
- (void)disconnect{_running=NO;if(_sock>=0){shutdown(_sock,SHUT_RDWR);close(_sock);_sock=-1;}}

- (BOOL)openSocket{
    struct addrinfo hints,*res=NULL,*it;memset(&hints,0,sizeof(hints));hints.ai_family=AF_UNSPEC;hints.ai_socktype=SOCK_STREAM;
    char portbuf[16];snprintf(portbuf,sizeof(portbuf),"%ld",(long)_port);
    if(getaddrinfo([_host UTF8String],portbuf,&hints,&res)!=0)return NO;
    for(it=res;it;it=it->ai_next){int s=socket(it->ai_family,it->ai_socktype,it->ai_protocol);if(s<0)continue;int yes=1;setsockopt(s,SOL_SOCKET,SO_KEEPALIVE,&yes,sizeof(yes));setsockopt(s,IPPROTO_TCP,TCP_NODELAY,&yes,sizeof(yes));if(connect(s,it->ai_addr,it->ai_addrlen)==0){_sock=s;break;}close(s);}
    freeaddrinfo(res);return _sock>=0;
}
- (BOOL)authenticateVNC:(const uint8_t*)challenge{
    uint8_t key[8]={0};NSData*d=[_password dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];NSUInteger n=MIN((NSUInteger)8,[d length]);if(n)memcpy(key,[d bytes],n);for(int i=0;i<8;i++)key[i]=reverseBits(key[i]);
    uint8_t response[16];size_t moved=0;CCCryptorStatus st=CCCrypt(kCCEncrypt,kCCAlgorithmDES,kCCOptionECBMode,key,8,NULL,challenge,16,response,16,&moved);
    return st==kCCSuccess&&moved==16&&sendAll(_sock,response,16);
}
- (BOOL)sendPixelFormat{
    uint8_t pf[20]={0};pf[0]=0;pf[6]=0;pf[7]=1;
    if(_qualityProfile==VNCQualityFast){pf[4]=8;pf[5]=8;putBE16(pf+8,7);putBE16(pf+10,7);putBE16(pf+12,3);pf[14]=5;pf[15]=2;pf[16]=0;_serverBytesPerPixel=1;}
    else if(_qualityProfile==VNCQualityBalanced){pf[4]=16;pf[5]=16;putBE16(pf+8,31);putBE16(pf+10,63);putBE16(pf+12,31);pf[14]=11;pf[15]=5;pf[16]=0;_serverBytesPerPixel=2;}
    else{pf[4]=32;pf[5]=24;putBE16(pf+8,255);putBE16(pf+10,255);putBE16(pf+12,255);pf[14]=16;pf[15]=8;pf[16]=0;_serverBytesPerPixel=4;}
    [_writeLock lock];BOOL ok=sendAll(_sock,pf,sizeof(pf));[_writeLock unlock];return ok;
}
- (BOOL)sendEncodings{
    // Hextile (5), Raw (0), DesktopSize (-223)
    uint8_t enc[16]={2,0,0,3, 0,0,0,5, 0,0,0,0, 0xFF,0xFF,0xFF,0x21};
    [_writeLock lock];BOOL ok=sendAll(_sock,enc,sizeof(enc));[_writeLock unlock];return ok;
}
- (BOOL)handshake{
    uint8_t ver[12];if(!recvAll(_sock,ver,12)||memcmp(ver,"RFB ",4)!=0)return NO;
    if(!sendAll(_sock,"RFB 003.008\n",12))return NO;
    uint8_t count=0;if(!recvAll(_sock,&count,1))return NO;
    if(count==0){uint8_t l[4];if(!recvAll(_sock,l,4))return NO;uint32_t n=readBE32(l);if(n){char*tmp=malloc(n+1);recvAll(_sock,tmp,n);free(tmp);}return NO;}
    uint8_t types[255];if(!recvAll(_sock,types,count))return NO;uint8_t selected=0;
    for(int i=0;i<count;i++)if(types[i]==2)selected=2;if(!selected)for(int i=0;i<count;i++)if(types[i]==1)selected=1;
    if(!selected||!sendAll(_sock,&selected,1))return NO;
    if(selected==2){uint8_t ch[16];if(!recvAll(_sock,ch,16)||![self authenticateVNC:ch])return NO;}
    uint8_t result[4];if(!recvAll(_sock,result,4)||readBE32(result)!=0)return NO;
    uint8_t shared=1;if(!sendAll(_sock,&shared,1))return NO;
    uint8_t init[24];if(!recvAll(_sock,init,24))return NO;_fbWidth=readBE16(init);_fbHeight=readBE16(init+2);uint32_t nameLen=readBE32(init+20);
    if(nameLen){char*name=malloc(nameLen+1);if(!recvAll(_sock,name,nameLen)){free(name);return NO;}free(name);}
    [_framebuffer release];_framebuffer=[[NSMutableData alloc]initWithLength:_fbWidth*_fbHeight*4];
    return [self sendPixelFormat]&&[self sendEncodings];
}
- (void)requestUpdateIncremental:(BOOL)inc{
    uint8_t m[10]={3,inc?1:0,0,0,0,0,0,0,0,0};putBE16(m+6,(uint16_t)_fbWidth);putBE16(m+8,(uint16_t)_fbHeight);
    [_writeLock lock];sendAll(_sock,m,10);[_writeLock unlock];
}
- (void)pixelBytes:(const uint8_t*)sp toBGRA:(uint8_t*)dst{
    uint8_t r=0,g=0,b=0;
    if(_serverBytesPerPixel==4){b=sp[0];g=sp[1];r=sp[2];}
    else if(_serverBytesPerPixel==2){uint16_t v=(uint16_t)(sp[0]|(sp[1]<<8));r=(uint8_t)((((v>>11)&31)*255)/31);g=(uint8_t)((((v>>5)&63)*255)/63);b=(uint8_t)(((v&31)*255)/31);}
    else{uint8_t v=sp[0];r=(uint8_t)((((v>>5)&7)*255)/7);g=(uint8_t)((((v>>2)&7)*255)/7);b=(uint8_t)(((v&3)*255)/3);}
    dst[0]=b;dst[1]=g;dst[2]=r;dst[3]=0;
}
- (BOOL)recvOnePixel:(uint8_t*)bgra{uint8_t p[4]={0};if(!recvAll(_sock,p,_serverBytesPerPixel))return NO;[self pixelBytes:p toBGRA:bgra];return YES;}
- (void)fillRectX:(NSUInteger)x y:(NSUInteger)y w:(NSUInteger)w h:(NSUInteger)h color:(const uint8_t*)c{
    uint8_t*fb=(uint8_t*)[_framebuffer mutableBytes];
    for(NSUInteger yy=0;yy<h&&y+yy<_fbHeight;yy++){for(NSUInteger xx=0;xx<w&&x+xx<_fbWidth;xx++){uint8_t*d=fb+(((y+yy)*_fbWidth)+(x+xx))*4;memcpy(d,c,4);}}
}
- (BOOL)decodeRawX:(uint16_t)x y:(uint16_t)y w:(uint16_t)w h:(uint16_t)h{
    size_t rowBytes=(size_t)w*_serverBytesPerPixel;uint8_t*tmp=malloc(rowBytes);if(!tmp)return NO;
    for(uint16_t row=0;row<h;row++){if(!recvAll(_sock,tmp,rowBytes)){free(tmp);return NO;}if(y+row<_fbHeight&&x+w<=_fbWidth){uint8_t*dst=(uint8_t*)[_framebuffer mutableBytes]+((size_t)(y+row)*_fbWidth+x)*4;for(uint16_t col=0;col<w;col++)[self pixelBytes:tmp+col*_serverBytesPerPixel toBGRA:dst+col*4];}}
    free(tmp);return YES;
}
- (BOOL)decodeHextileX:(uint16_t)x y:(uint16_t)y w:(uint16_t)w h:(uint16_t)h{
    uint8_t bg[4]={0,0,0,0},fg[4]={255,255,255,0};
    for(uint16_t ty=0;ty<h;ty+=16){for(uint16_t tx=0;tx<w;tx+=16){
        uint16_t tw=MIN((uint16_t)16,(uint16_t)(w-tx)),th=MIN((uint16_t)16,(uint16_t)(h-ty));uint8_t sub=0;if(!recvAll(_sock,&sub,1))return NO;
        if(sub&1){if(![self decodeRawX:x+tx y:y+ty w:tw h:th])return NO;continue;}
        if(sub&2){if(![self recvOnePixel:bg])return NO;}[self fillRectX:x+tx y:y+ty w:tw h:th color:bg];
        if(sub&4){if(![self recvOnePixel:fg])return NO;}
        if(sub&8){uint8_t count=0;if(!recvAll(_sock,&count,1))return NO;for(uint8_t i=0;i<count;i++){uint8_t color[4];const uint8_t*use=fg;if(sub&16){if(![self recvOnePixel:color])return NO;use=color;}uint8_t xywh[2];if(!recvAll(_sock,xywh,2))return NO;uint8_t sx=xywh[0]>>4,sy=xywh[0]&15,sw=(xywh[1]>>4)+1,sh=(xywh[1]&15)+1;[self fillRectX:x+tx+sx y:y+ty+sy w:sw h:sh color:use];}}
    }}return YES;
}
- (UIImage*)currentImage{
    if(!_framebuffer||!_fbWidth||!_fbHeight)return nil;CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();NSData*copy=[NSData dataWithData:_framebuffer];CGDataProviderRef provider=CGDataProviderCreateWithCFData((CFDataRef)copy);CGBitmapInfo bi=kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst;CGImageRef cg=CGImageCreate(_fbWidth,_fbHeight,8,32,_fbWidth*4,cs,bi,provider,NULL,false,kCGRenderingIntentDefault);UIImage*img=[UIImage imageWithCGImage:cg];CGImageRelease(cg);CGDataProviderRelease(provider);CGColorSpaceRelease(cs);return img;
}
- (void)maybeAdapt:(NSTimeInterval)duration{
    if(!_adaptiveQualityEnabled)return;NSTimeInterval now=[NSDate timeIntervalSinceReferenceDate];if(now-_lastQualityChange<8.0)return;
    if(duration>0.28){_slowFrames++;_fastFrames=0;}else if(duration<0.09){_fastFrames++;if(_slowFrames)_slowFrames--;}else{if(_slowFrames)_slowFrames--;if(_fastFrames)_fastFrames--;}
    VNCQualityProfile next=_qualityProfile;
    if(_slowFrames>=3&&_qualityProfile>VNCQualityFast){next=(VNCQualityProfile)(_qualityProfile-1);_slowFrames=0;}
    else if(_fastFrames>=12&&_qualityProfile<VNCQualityQuality){next=(VNCQualityProfile)(_qualityProfile+1);_fastFrames=0;}
    if(next!=_qualityProfile){_qualityProfile=next;_lastQualityChange=now;[self sendPixelFormat];[self requestUpdateIncremental:NO];NSString*n=(_qualityProfile==VNCQualityFast?@"Fast":(_qualityProfile==VNCQualityBalanced?@"Balanced":@"Quality"));[self performSelectorOnMainThread:@selector(statusOnMain:) withObject:[NSString stringWithFormat:@"Auto quality: %@",n] waitUntilDone:NO];}
}
- (BOOL)handleFramebufferUpdate{
    NSTimeInterval started=[NSDate timeIntervalSinceReferenceDate];uint8_t hdr[3];if(!recvAll(_sock,hdr,3))return NO;uint16_t rects=readBE16(hdr+1);
    for(uint16_t r=0;r<rects;r++){uint8_t rh[12];if(!recvAll(_sock,rh,12))return NO;uint16_t x=readBE16(rh),y=readBE16(rh+2),w=readBE16(rh+4),h=readBE16(rh+6);int32_t enc=(int32_t)readBE32(rh+8);
        if(enc==0){if(![self decodeRawX:x y:y w:w h:h])return NO;}
        else if(enc==5){if(![self decodeHextileX:x y:y w:w h:h])return NO;}
        else if(enc==-223){_fbWidth=w;_fbHeight=h;[_framebuffer release];_framebuffer=[[NSMutableData alloc]initWithLength:_fbWidth*_fbHeight*4];}
        else return NO;
    }
    UIImage*img=[self currentImage];if(img)[self performSelectorOnMainThread:@selector(frameOnMain:) withObject:img waitUntilDone:NO];
    [self maybeAdapt:[NSDate timeIntervalSinceReferenceDate]-started];return YES;
}
- (void)networkThread{
    NSAutoreleasePool*pool=[[NSAutoreleasePool alloc]init];[self performSelectorOnMainThread:@selector(statusOnMain:) withObject:@"Connecting…" waitUntilDone:NO];
    if(![self openSocket]||![self handshake]){[self disconnect];[self performSelectorOnMainThread:@selector(disconnectOnMain:) withObject:@"Connection/authentication failed" waitUntilDone:NO];[pool drain];return;}
    [self performSelectorOnMainThread:@selector(statusOnMain:) withObject:@"Connected" waitUntilDone:NO];[self requestUpdateIncremental:NO];
    while(_running){uint8_t type;if(!recvAll(_sock,&type,1))break;if(type==0){if(![self handleFramebufferUpdate])break;[self requestUpdateIncremental:YES];}
        else if(type==2){uint8_t pad;if(!recvAll(_sock,&pad,1))break;}
        else if(type==3){uint8_t h[7];if(!recvAll(_sock,h,7))break;uint32_t n=readBE32(h+3);char*tmp=malloc(n+1);BOOL ok=recvAll(_sock,tmp,n);if(ok){tmp[n]=0;NSString*clip=[[[NSString alloc]initWithBytes:tmp length:n encoding:NSUTF8StringEncoding]autorelease];if(!clip)clip=[[[NSString alloc]initWithBytes:tmp length:n encoding:NSISOLatin1StringEncoding]autorelease];if(clip)[self performSelectorOnMainThread:@selector(clipboardOnMain:) withObject:clip waitUntilDone:NO];}free(tmp);if(!ok)break;}
        else break;}
    [self disconnect];[self performSelectorOnMainThread:@selector(disconnectOnMain:) withObject:@"Disconnected" waitUntilDone:NO];[pool drain];
}
- (void)sendPointerX:(NSUInteger)x y:(NSUInteger)y buttons:(uint8_t)buttons{if(!_running||_sock<0)return;uint8_t m[6]={5,buttons,0,0,0,0};putBE16(m+2,(uint16_t)MIN(x,65535));putBE16(m+4,(uint16_t)MIN(y,65535));[_writeLock lock];sendAll(_sock,m,6);[_writeLock unlock];}
- (void)sendKeySym:(uint32_t)keysym down:(BOOL)down{if(!_running||_sock<0)return;uint8_t m[8]={4,down?1:0,0,0,0,0,0,0};putBE32(m+4,keysym);[_writeLock lock];sendAll(_sock,m,8);[_writeLock unlock];}
- (void)sendClipboardText:(NSString*)text{if(!_running||_sock<0||![text length])return;NSData*data=[text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];if(!data)return;NSUInteger len=MIN([data length],(NSUInteger)(1024*1024));NSMutableData*msg=[NSMutableData dataWithLength:8+len];uint8_t*p=(uint8_t*)[msg mutableBytes];p[0]=6;putBE32(p+4,(uint32_t)len);memcpy(p+8,[data bytes],len);[_writeLock lock];sendAll(_sock,[msg bytes],[msg length]);[_writeLock unlock];}
@end
