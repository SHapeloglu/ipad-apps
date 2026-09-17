#import "VNCClient.h"
#import <CommonCrypto/CommonCryptor.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/socket.h>
#import <unistd.h>
#import <netinet/tcp.h>

static BOOL recvAll(int s, void *buf, size_t len) {
    uint8_t *p=(uint8_t *)buf;
    while (len) { ssize_t n=recv(s,p,len,0); if(n<=0) return NO; p+=n; len-=n; }
    return YES;
}
static BOOL sendAll(int s, const void *buf, size_t len) {
    const uint8_t *p=(const uint8_t *)buf;
    while (len) { ssize_t n=send(s,p,len,0); if(n<=0) return NO; p+=n; len-=n; }
    return YES;
}
static uint16_t readBE16(const uint8_t *p){ return (uint16_t)((p[0]<<8)|p[1]); }
static uint32_t readBE32(const uint8_t *p){ return ((uint32_t)p[0]<<24)|((uint32_t)p[1]<<16)|((uint32_t)p[2]<<8)|p[3]; }
static void putBE16(uint8_t *p,uint16_t v){p[0]=v>>8;p[1]=v;}
static void putBE32(uint8_t *p,uint32_t v){p[0]=v>>24;p[1]=v>>16;p[2]=v>>8;p[3]=v;}
static uint8_t reverseBits(uint8_t b){ b=(b&0xF0)>>4|(b&0x0F)<<4; b=(b&0xCC)>>2|(b&0x33)<<2; return (b&0xAA)>>1|(b&0x55)<<1; }

@implementation VNCClient
@synthesize delegate=_delegate;
- (NSUInteger)framebufferWidth{return _fbWidth;}
- (NSUInteger)framebufferHeight{return _fbHeight;}

- (id)initWithHost:(NSString *)host port:(NSInteger)port password:(NSString *)password {
    if((self=[super init])){ _host=[host copy]; _port=port; _password=[password copy]; _sock=-1; _writeLock=[[NSLock alloc]init]; }
    return self;
}
- (void)dealloc { [self disconnect]; [_host release]; [_password release]; [_framebuffer release]; [_writeLock release]; [super dealloc]; }

- (void)notifyStatus:(NSString *)s { if([_delegate respondsToSelector:@selector(vncClientStatus:)]) [_delegate vncClientStatus:s]; }
- (void)notifyDisconnected:(NSString *)s { if([_delegate respondsToSelector:@selector(vncClientDisconnected:)]) [_delegate vncClientDisconnected:s]; }
- (void)statusOnMain:(NSString *)s { [self notifyStatus:s]; }
- (void)disconnectOnMain:(NSString *)s { [self notifyDisconnected:s]; }
- (void)frameOnMain:(UIImage *)img { if([_delegate respondsToSelector:@selector(vncClientFramebuffer:width:height:)]) [_delegate vncClientFramebuffer:img width:_fbWidth height:_fbHeight]; }

- (void)connect { if(_running)return; _running=YES; [NSThread detachNewThreadSelector:@selector(networkThread) toTarget:self withObject:nil]; }
- (void)disconnect { _running=NO; if(_sock>=0){ shutdown(_sock,SHUT_RDWR); close(_sock); _sock=-1; } }

- (BOOL)openSocket {
    struct addrinfo hints,*res=NULL,*it; memset(&hints,0,sizeof(hints)); hints.ai_family=AF_UNSPEC; hints.ai_socktype=SOCK_STREAM;
    char portbuf[16]; snprintf(portbuf,sizeof(portbuf),"%ld",(long)_port);
    if(getaddrinfo([_host UTF8String],portbuf,&hints,&res)!=0) return NO;
    for(it=res;it;it=it->ai_next){
        int s=socket(it->ai_family,it->ai_socktype,it->ai_protocol); if(s<0)continue;
        int yes=1; setsockopt(s,SOL_SOCKET,SO_KEEPALIVE,&yes,sizeof(yes)); setsockopt(s,IPPROTO_TCP,TCP_NODELAY,&yes,sizeof(yes));
        if(connect(s,it->ai_addr,it->ai_addrlen)==0){_sock=s;break;} close(s);
    }
    freeaddrinfo(res); return _sock>=0;
}

- (BOOL)authenticateVNC:(const uint8_t *)challenge {
    uint8_t key[8]={0}; NSData *d=[_password dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];
    NSUInteger n=MIN((NSUInteger)8,[d length]); if(n) memcpy(key,[d bytes],n); for(int i=0;i<8;i++) key[i]=reverseBits(key[i]);
    uint8_t response[16]; size_t moved=0;
    CCCryptorStatus st=CCCrypt(kCCEncrypt,kCCAlgorithmDES,kCCOptionECBMode,key,8,NULL,challenge,16,response,16,&moved);
    return st==kCCSuccess && moved==16 && sendAll(_sock,response,16);
}

- (BOOL)handshake {
    uint8_t ver[12]; if(!recvAll(_sock,ver,12)) return NO;
    if(memcmp(ver,"RFB ",4)!=0) return NO;
    // Speak 3.8; older servers normally negotiate down acceptably.
    if(!sendAll(_sock,"RFB 003.008\n",12)) return NO;
    uint8_t count=0; if(!recvAll(_sock,&count,1)) return NO;
    if(count==0){ uint8_t l[4]; if(!recvAll(_sock,l,4))return NO; uint32_t n=readBE32(l); if(n){char *tmp=malloc(n+1);recvAll(_sock,tmp,n);tmp[n]=0;free(tmp);} return NO; }
    uint8_t types[255]; if(!recvAll(_sock,types,count)) return NO;
    uint8_t selected=0; for(int i=0;i<count;i++) if(types[i]==2) selected=2; if(!selected) for(int i=0;i<count;i++) if(types[i]==1) selected=1;
    if(!selected) return NO; if(!sendAll(_sock,&selected,1)) return NO;
    if(selected==2){ uint8_t ch[16]; if(!recvAll(_sock,ch,16) || ![self authenticateVNC:ch])return NO; }
    uint8_t result[4]; if(!recvAll(_sock,result,4) || readBE32(result)!=0) return NO;
    uint8_t shared=1; if(!sendAll(_sock,&shared,1))return NO;
    uint8_t init[24]; if(!recvAll(_sock,init,24))return NO; _fbWidth=readBE16(init); _fbHeight=readBE16(init+2); uint32_t nameLen=readBE32(init+20);
    if(nameLen){ char *name=malloc(nameLen+1); if(!recvAll(_sock,name,nameLen)){free(name);return NO;} name[nameLen]=0; free(name); }
    [_framebuffer release]; _framebuffer=[[NSMutableData alloc] initWithLength:_fbWidth*_fbHeight*4];
    // Pixel format: 32 bpp, depth 24, little-endian, true color, RGB max 255, shifts 16/8/0 => memory B,G,R,0 on little endian.
    uint8_t pf[20]={0}; pf[0]=0; pf[4]=32; pf[5]=24; pf[6]=0; pf[7]=1; putBE16(pf+8,255); putBE16(pf+10,255); putBE16(pf+12,255); pf[14]=16; pf[15]=8; pf[16]=0;
    if(!sendAll(_sock,pf,sizeof(pf)))return NO;
    // SetEncodings: RAW only.
    uint8_t enc[8]={2,0,0,1,0,0,0,0}; if(!sendAll(_sock,enc,sizeof(enc)))return NO;
    return YES;
}

- (void)requestUpdateIncremental:(BOOL)inc {
    uint8_t m[10]={3,inc?1:0,0,0,0,0,0,0,0,0}; putBE16(m+6,(uint16_t)_fbWidth); putBE16(m+8,(uint16_t)_fbHeight); sendAll(_sock,m,10);
}

- (UIImage *)currentImage {
    if(!_framebuffer||!_fbWidth||!_fbHeight)return nil;
    CGColorSpaceRef cs=CGColorSpaceCreateDeviceRGB();
    NSData *copy=[NSData dataWithData:_framebuffer];
    CGDataProviderRef provider=CGDataProviderCreateWithCFData((CFDataRef)copy);
    CGBitmapInfo bi=kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst;
    CGImageRef cg=CGImageCreate(_fbWidth,_fbHeight,8,32,_fbWidth*4,cs,bi,provider,NULL,false,kCGRenderingIntentDefault);
    UIImage *img=[UIImage imageWithCGImage:cg]; CGImageRelease(cg); CGDataProviderRelease(provider); CGColorSpaceRelease(cs); return img;
}

- (BOOL)handleFramebufferUpdate {
    uint8_t hdr[3]; if(!recvAll(_sock,hdr,3))return NO; uint16_t rects=readBE16(hdr+1);
    for(uint16_t r=0;r<rects;r++){
        uint8_t rh[12]; if(!recvAll(_sock,rh,12))return NO; uint16_t x=readBE16(rh),y=readBE16(rh+2),w=readBE16(rh+4),h=readBE16(rh+6); int32_t enc=(int32_t)readBE32(rh+8);
        if(enc!=0) return NO;
        size_t rowBytes=(size_t)w*4; uint8_t *tmp=malloc(rowBytes);
        for(uint16_t row=0;row<h;row++){ if(!recvAll(_sock,tmp,rowBytes)){free(tmp);return NO;} if(y+row<_fbHeight && x+w<=_fbWidth) memcpy((uint8_t *)[_framebuffer mutableBytes]+((size_t)(y+row)*_fbWidth+x)*4,tmp,rowBytes); }
        free(tmp);
    }
    UIImage *img=[self currentImage]; if(img)[self performSelectorOnMainThread:@selector(frameOnMain:) withObject:img waitUntilDone:NO]; return YES;
}

- (void)networkThread {
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    [self performSelectorOnMainThread:@selector(statusOnMain:) withObject:@"Connecting…" waitUntilDone:NO];
    if(![self openSocket] || ![self handshake]){ [self disconnect]; [self performSelectorOnMainThread:@selector(disconnectOnMain:) withObject:@"Connection/authentication failed" waitUntilDone:NO]; [pool drain]; return; }
    [self performSelectorOnMainThread:@selector(statusOnMain:) withObject:@"Connected" waitUntilDone:NO]; [self requestUpdateIncremental:NO];
    while(_running){ uint8_t type; if(!recvAll(_sock,&type,1))break; if(type==0){ if(![self handleFramebufferUpdate])break; [self requestUpdateIncremental:YES]; } else if(type==2){ uint8_t pad[1]; if(!recvAll(_sock,pad,1))break; } else if(type==3){ uint8_t h[7]; if(!recvAll(_sock,h,7))break; uint32_t n=readBE32(h+3); char *tmp=malloc(n); BOOL ok=recvAll(_sock,tmp,n); free(tmp); if(!ok)break; } else { break; } }
    [self disconnect]; [self performSelectorOnMainThread:@selector(disconnectOnMain:) withObject:@"Disconnected" waitUntilDone:NO]; [pool drain];
}

- (void)sendPointerX:(NSUInteger)x y:(NSUInteger)y buttons:(uint8_t)buttons {
    if(!_running||_sock<0)return; uint8_t m[6]={5,buttons,0,0,0,0}; putBE16(m+2,(uint16_t)MIN(x,65535)); putBE16(m+4,(uint16_t)MIN(y,65535)); [_writeLock lock]; sendAll(_sock,m,6); [_writeLock unlock];
}
- (void)sendKeySym:(uint32_t)keysym down:(BOOL)down {
    if(!_running||_sock<0)return; uint8_t m[8]={4,down?1:0,0,0,0,0,0,0}; putBE32(m+4,keysym); [_writeLock lock]; sendAll(_sock,m,8); [_writeLock unlock];
}
@end
