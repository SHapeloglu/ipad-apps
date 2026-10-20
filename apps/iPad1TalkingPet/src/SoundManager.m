#import "SoundManager.h"

@implementation SoundManager

+ (SoundManager *)sharedManager {
    static SoundManager *s=nil;
    if(!s) s=[[SoundManager alloc] init];
    return s;
}

- (id)init {
    self=[super init];
    if(self) _players=[[NSMutableDictionary alloc] init];
    return self;
}

- (NSString *)pathFor:(NSString *)name {
    return [[NSBundle mainBundle] pathForResource:name ofType:@"wav" inDirectory:@"Sounds"];
}

- (void)play:(NSString *)name {
    NSString *p=[self pathFor:name];
    if(!p) return;
    NSError *e=nil;
    AVAudioPlayer *pl=[[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:p] error:&e] autorelease];
    if(!pl || e) return;
    [_players setObject:pl forKey:name];
    [pl prepareToPlay];
    [pl play];
}

- (BOOL)musicEnabled {
    NSUserDefaults *d=[NSUserDefaults standardUserDefaults];
    if([d objectForKey:@"audio.musicEnabled"]==nil) return YES;
    return [d boolForKey:@"audio.musicEnabled"];
}

- (void)setMusicEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"audio.musicEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(enabled) [self startMusic]; else [self stopMusic];
}

- (void)startMusic {
    if(![self musicEnabled] || _musicPlayer) return;
    NSString *p=[self pathFor:@"room_music"];
    if(!p) return;
    NSError *e=nil;
    _musicPlayer=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:p] error:&e];
    if(!_musicPlayer || e){ [_musicPlayer release]; _musicPlayer=nil; return; }
    _musicPlayer.numberOfLoops=-1;
    _musicPlayer.volume=0.35f;
    [_musicPlayer prepareToPlay];
    [_musicPlayer play];
}

- (void)stopMusic {
    [_musicPlayer stop]; [_musicPlayer release]; _musicPlayer=nil;
}

- (void)dealloc {
    [self stopMusic];
    [_players release];
    [super dealloc];
}
@end
