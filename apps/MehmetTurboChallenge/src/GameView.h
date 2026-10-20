#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GameView : UIView {
    CADisplayLink *_displayLink;
    CFTimeInterval _lastTime;

    float _playerX;
    float _steer;
    float _steerTarget;

    float _roadScroll;
    float _distance;
    float _raceTime;
    int _lap;
    int _score;

    BOOL _touchLeft;
    BOOL _touchRight;
    BOOL _paused;
}

- (void)pauseGame;
- (void)resumeGame;

@end
