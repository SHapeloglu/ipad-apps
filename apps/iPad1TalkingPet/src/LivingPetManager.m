#import "LivingPetManager.h"
#import "PetCharacterView.h"
#import "PetNeedsManager.h"
#import "PetMoodManager.h"

@implementation LivingPetManager

- (id)initWithPet:(PetCharacterView *)pet needs:(PetNeedsManager *)needs {
    self=[super init];
    if(self) {
        _pet=[pet retain];
        _needs=[needs retain];
    }
    return self;
}

- (void)start {
    if(_timer) return;
    _timer=[[NSTimer scheduledTimerWithTimeInterval:7.5
                                             target:self
                                           selector:@selector(tick)
                                           userInfo:nil
                                            repeats:YES] retain];
}

- (void)performImmediateMoodReaction {
    [self tick];
}

- (void)tick {
    PetMood mood=[[PetMoodManager sharedManager] moodForNeeds:_needs];

    if(mood==PetMoodSleepy) {
        [_pet sleep];
        return;
    }
    if(mood==PetMoodHungry) {
        NSInteger r=arc4random()%3;
        if(r==0) [_pet sad];
        else if(r==1) [_pet lookLeft];
        else [_pet lookRight];
        return;
    }
    if(mood==PetMoodDirty) {
        NSInteger r=arc4random()%2;
        if(r==0) [_pet sad];
        else [_pet stretch];
        return;
    }
    if(mood==PetMoodBored) {
        NSInteger r=arc4random()%3;
        if(r==0) [_pet wave];
        else if(r==1) [_pet surprise];
        else [_pet jump];
        return;
    }
    if(mood==PetMoodHappy) {
        NSInteger r=arc4random()%3;
        if(r==0) [_pet laugh];
        else if(r==1) [_pet dance];
        else [_pet happy];
        return;
    }

    NSInteger r=arc4random()%6;
    if(r==0) [_pet lookLeft];
    else if(r==1) [_pet lookRight];
    else if(r==2) [_pet wave];
    else if(r==3) [_pet surprise];
    else if(r==4) [_pet stretch];
    else [_pet blink];
}

- (void)stop {
    [_timer invalidate];
    [_timer release];
    _timer=nil;
}

- (void)dealloc {
    [self stop];
    [_pet release];
    [_needs release];
    [super dealloc];
}

@end
