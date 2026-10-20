#import "IP1RecentManager.h"
#define IP1RecentPathsKey @"IP1RecentPaths"
#define IP1RecentMaximumCount 20
@implementation IP1RecentManager
+ (IP1RecentManager *)sharedManager {
    static IP1RecentManager *instance=nil;
    @synchronized(self) {
        if(!instance) instance=[[IP1RecentManager alloc] init];
    }
    return instance;
}
- (NSMutableArray *)mutableStoredPaths {
    NSArray *a=[[NSUserDefaults standardUserDefaults] arrayForKey:IP1RecentPathsKey];
    return a ? [NSMutableArray arrayWithArray:a] : [NSMutableArray array];
}
- (void)recordPath:(NSString *)path {
    if(![path length]) return;
    NSMutableArray *a=[self mutableStoredPaths];
    [a removeObject:path];
    [a insertObject:path atIndex:0];
    while([a count] > IP1RecentMaximumCount) [a removeLastObject];
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:IP1RecentPathsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray *)recentPaths {
    [self pruneMissingPaths];
    NSArray *a=[[NSUserDefaults standardUserDefaults] arrayForKey:IP1RecentPathsKey];
    return a ? a : [NSArray array];
}
- (void)removePath:(NSString *)path {
    NSMutableArray *a=[self mutableStoredPaths];
    [a removeObject:path];
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:IP1RecentPathsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)pruneMissingPaths {
    NSMutableArray *a=[self mutableStoredPaths];
    NSFileManager *fm=[NSFileManager defaultManager];
    NSInteger i=(NSInteger)[a count]-1;
    while(i>=0) {
        if(![fm fileExistsAtPath:[a objectAtIndex:(NSUInteger)i]])
            [a removeObjectAtIndex:(NSUInteger)i];
        i--;
    }
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:IP1RecentPathsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
