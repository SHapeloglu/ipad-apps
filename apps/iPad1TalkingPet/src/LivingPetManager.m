#import "LivingPetManager.h"
#import "PetCharacterView.h"

@implementation LivingPetManager

- (id)initWithPet:(PetCharacterView *)pet {
    self=[super init];
    if(self) _pet=[pet retain];
    return self;
}

- (void)start {
    if(_timer) return;
    _timer=[[NSTimer scheduledTimerWithTimeInterval:7.5 target:self selector:@selector(tick) userInfo:nil repeats:YES] retain];
}

- (void)tick {
    NSInteger r=arc4random()%8;
    if(r==0) [_pet lookLeft];
    else if(r==1) [_pet lookRight];
    else if(r==2) [_pet wave];
    else if(r==3) [_pet laugh];
    else if(r==4) [_pet surprise];
    else if(r==5) [_pet stretch];
    else if(r==6) [_pet dance];
    else [_pet jump];
}

- (void)stop {
    [_timer invalidate];
    [_timer release];
    _timer=nil;
}

- (void)dealloc {
    [self stop];
    [_pet release];
    [super dealloc];
}

@end
