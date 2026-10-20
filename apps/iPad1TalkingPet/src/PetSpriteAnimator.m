#import "PetSpriteAnimator.h"

@implementation PetSpriteAnimator

- (id)initWithImageView:(UIImageView *)imageView {
    self=[super init];
    if(self) _imageView=[imageView retain];
    return self;
}

- (NSArray *)frames:(NSString *)name count:(NSInteger)count {
    NSMutableArray *a=[NSMutableArray arrayWithCapacity:count];
    for(NSInteger i=1;i<=count;i++){
        NSString *fn=[NSString stringWithFormat:@"Animations/%@_%02ld.png",name,(long)i];
        UIImage *im=[UIImage imageNamed:fn];
        if(im) [a addObject:im];
    }
    return a;
}

- (void)playNamed:(NSString *)name frameCount:(NSInteger)count duration:(NSTimeInterval)duration repeat:(NSInteger)repeatCount {
    NSArray *a=[self frames:name count:count];
    if([a count]==0) return;
    _imageView.animationImages=a;
    _imageView.animationDuration=duration;
    _imageView.animationRepeatCount=repeatCount;
    [_imageView startAnimating];
}

- (void)startIdle {
    if(_idleTimer) return;
    [self playNamed:@"idle" frameCount:6 duration:1.2 repeat:0];
    _idleTimer=[[NSTimer scheduledTimerWithTimeInterval:3.2 target:self selector:@selector(idleTick) userInfo:nil repeats:YES] retain];
}

- (void)idleTick {
    if(!_busy && (arc4random()%3)==0) [self blink];
}

- (void)blink {
    if(_busy) return;
    _busy=YES;
    [self playNamed:@"blink" frameCount:4 duration:0.28 repeat:1];
    [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.32];
}
- (void)happy {
    _busy=YES; [self playNamed:@"happy" frameCount:5 duration:0.55 repeat:1];
    [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.60];
}
- (void)sad {
    _busy=YES; [self playNamed:@"sad" frameCount:4 duration:0.55 repeat:1];
    [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.60];
}
- (void)touch {
    _busy=YES; [self playNamed:@"touch" frameCount:5 duration:0.45 repeat:1];
    [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.50];
}
- (void)talkStart {
    _busy=YES; [self playNamed:@"talk" frameCount:4 duration:0.30 repeat:0];
}
- (void)talkStop { [_imageView stopAnimating]; _busy=NO; [self playNamed:@"idle" frameCount:6 duration:1.2 repeat:0]; }
- (void)chew {
    _busy=YES; [self playNamed:@"chew" frameCount:4 duration:0.42 repeat:2];
    [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.90];
}
- (void)sleep {
    _busy=YES; [self playNamed:@"sleep" frameCount:4 duration:1.0 repeat:2];
    [self performSelector:@selector(endBusy) withObject:nil afterDelay:2.1];
}

- (void)lookLeft { if(_busy)return; _busy=YES; [self playNamed:@"look_left" frameCount:5 duration:0.7 repeat:1]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.75]; }
- (void)lookRight { if(_busy)return; _busy=YES; [self playNamed:@"look_right" frameCount:5 duration:0.7 repeat:1]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.75]; }
- (void)wave { if(_busy)return; _busy=YES; [self playNamed:@"wave" frameCount:5 duration:0.75 repeat:1]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.80]; }
- (void)laugh { if(_busy)return; _busy=YES; [self playNamed:@"laugh" frameCount:5 duration:0.75 repeat:1]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.80]; }
- (void)surprise { if(_busy)return; _busy=YES; [self playNamed:@"surprise" frameCount:5 duration:0.7 repeat:1]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.75]; }
- (void)stretch { if(_busy)return; _busy=YES; [self playNamed:@"stretch" frameCount:5 duration:0.85 repeat:1]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.9]; }
- (void)dance { if(_busy)return; _busy=YES; [self playNamed:@"dance" frameCount:5 duration:0.85 repeat:2]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:1.75]; }
- (void)jump { if(_busy)return; _busy=YES; [self playNamed:@"jump" frameCount:5 duration:0.65 repeat:1]; [self performSelector:@selector(endBusy) withObject:nil afterDelay:0.7]; }

- (void)endBusy {
    _busy=NO;
    [self playNamed:@"idle" frameCount:6 duration:1.2 repeat:0];
}

- (void)stop {
    [_idleTimer invalidate]; [_idleTimer release]; _idleTimer=nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_imageView stopAnimating];
}
- (void)dealloc { [self stop]; [_imageView release]; [super dealloc]; }

@end
