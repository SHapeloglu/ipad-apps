#import "Game.h"

@implementation Game
@synthesize speed = _speed, playerX = _playerX, roadScroll = _roadScroll, elapsed = _elapsed;

- (id)init { if ((self = [super init])) [self reset]; return self; }
- (void)reset { _speed=0.0f; _playerX=0.0f; _roadScroll=0.0f; _elapsed=0.0f; _left=_right=_accelerate=_brake=NO; }
- (void)setLeft:(BOOL)v { _left=v; }
- (void)setRight:(BOOL)v { _right=v; }
- (void)setAccelerate:(BOOL)v { _accelerate=v; }
- (void)setBrake:(BOOL)v { _brake=v; }
- (void)update:(float)dt {
    if (dt > 0.05f) dt = 0.05f;
    if (_accelerate) _speed += 95.0f * dt; else _speed -= 28.0f * dt;
    if (_brake) _speed -= 130.0f * dt;
    if (_speed < 0) _speed = 0;
    if (_speed > 260) _speed = 260;
    float steer = 145.0f * dt * (0.35f + _speed / 260.0f);
    if (_left) _playerX -= steer;
    if (_right) _playerX += steer;
    if (_playerX < -0.92f) _playerX = -0.92f;
    if (_playerX > 0.92f) _playerX = 0.92f;
    _roadScroll += _speed * dt;
    while (_roadScroll >= 40.0f) _roadScroll -= 40.0f;
    if (_speed > 1.0f) _elapsed += dt;
}
@end
