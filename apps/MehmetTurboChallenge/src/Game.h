#import <Foundation/Foundation.h>

@interface Game : NSObject {
    float _speed;
    float _playerX;
    float _roadScroll;
    float _elapsed;
    BOOL _left;
    BOOL _right;
    BOOL _accelerate;
    BOOL _brake;
}
@property(nonatomic, readonly) float speed;
@property(nonatomic, readonly) float playerX;
@property(nonatomic, readonly) float roadScroll;
@property(nonatomic, readonly) float elapsed;
- (void)setLeft:(BOOL)v;
- (void)setRight:(BOOL)v;
- (void)setAccelerate:(BOOL)v;
- (void)setBrake:(BOOL)v;
- (void)update:(float)dt;
- (void)reset;
@end
