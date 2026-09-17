#import "KaraokeViewController.h"
#import "LRCParser.h"

@implementation KaraokeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    NSError *sessionError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    [audioSession setActive:YES error:&sessionError];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 24, 964, 46)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:28.0f];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.text = @"CRUSH - Crush! (Karaoke)";
    [self.view addSubview:_titleLabel];

    _lyricLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 120, 904, 430)];
    _lyricLabel.backgroundColor = [UIColor clearColor];
    _lyricLabel.textColor = [UIColor yellowColor];
    _lyricLabel.font = [UIFont boldSystemFontOfSize:42.0f];
    _lyricLabel.textAlignment = UITextAlignmentCenter;
    _lyricLabel.numberOfLines = 4;
    _lyricLabel.text = @"Hazır olduğunda Oynat'a bas";
    [self.view addSubview:_lyricLabel];

    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(80, 620, 760, 44)];
    [_progressSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_progressSlider];

    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(850, 620, 120, 44)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:20.0f];
    _timeLabel.textAlignment = UITextAlignmentRight;
    _timeLabel.text = @"00:00 / 00:00";
    [self.view addSubview:_timeLabel];

    _playPauseButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    _playPauseButton.frame = CGRectMake(412, 685, 200, 58);
    [_playPauseButton setTitle:@"Oynat" forState:UIControlStateNormal];
    [_playPauseButton addTarget:self action:@selector(playPauseTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playPauseButton];

    NSString *songPath = [[NSBundle mainBundle] pathForResource:@"CRUSH-Karaoke" ofType:@"mp3" inDirectory:@"Songs"];
    NSError *error = nil;
    NSURL *songURL = songPath ? [NSURL fileURLWithPath:songPath] : nil;
    if (songURL) _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songURL error:&error];

    if (!_audioPlayer || error) {
        _lyricLabel.text = @"Test şarkısı açılamadı";
        _playPauseButton.enabled = NO;
        return;
    }

    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    _progressSlider.minimumValue = 0.0f;
    _progressSlider.maximumValue = (float)_audioPlayer.duration;

    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:@"CRUSH-Karaoke" ofType:@"lrc" inDirectory:@"Songs"];
    _lyrics = [[LRCParser parseFileAtPath:lrcPath] retain];
    _currentLyricIndex = -1;
    [self updateTimeDisplay];
}

- (void)playPauseTapped:(id)sender {
    (void)sender;
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer pause];
        [_playPauseButton setTitle:@"Oynat" forState:UIControlStateNormal];
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    } else {
        [_audioPlayer play];
        [_playPauseButton setTitle:@"Duraklat" forState:UIControlStateNormal];
        if (!_timer) {
            _timer = [[NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES] retain];
        }
    }
}

- (void)sliderChanged:(UISlider *)slider {
    _audioPlayer.currentTime = slider.value;
    _currentLyricIndex = -1;
    [self updateLyrics];
    [self updateTimeDisplay];
}

- (void)timerTick:(NSTimer *)timer {
    (void)timer;
    _progressSlider.value = (float)_audioPlayer.currentTime;
    [self updateTimeDisplay];
    [self updateLyrics];
}

- (void)updateTimeDisplay {
    NSInteger current = (NSInteger)_audioPlayer.currentTime;
    NSInteger total = (NSInteger)_audioPlayer.duration;
    _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld",
                       (long)(current / 60), (long)(current % 60),
                       (long)(total / 60), (long)(total % 60)];
}

- (void)updateLyrics {
    if ([_lyrics count] == 0) {
        _lyricLabel.text = @"Enstrümantal karaoke testi";
        return;
    }

    NSInteger found = -1;
    NSTimeInterval currentTime = _audioPlayer.currentTime;
    for (NSInteger i = 0; i < (NSInteger)[_lyrics count]; i++) {
        LRCLyricLine *line = [_lyrics objectAtIndex:i];
        if (line.time <= currentTime) found = i;
        else break;
    }

    if (found != _currentLyricIndex && found >= 0) {
        _currentLyricIndex = found;
        LRCLyricLine *line = [_lyrics objectAtIndex:found];
        _lyricLabel.text = line.text;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    (void)player;
    (void)flag;
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    [_playPauseButton setTitle:@"Oynat" forState:UIControlStateNormal];
    _progressSlider.value = 0.0f;
    _lyricLabel.text = @"Şarkı tamamlandı";
    [self updateTimeDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsLandscape(orientation);
}

- (void)dealloc {
    [_timer invalidate];
    [_timer release];
    [_audioPlayer stop];
    [_audioPlayer release];
    [_titleLabel release];
    [_lyricLabel release];
    [_timeLabel release];
    [_playPauseButton release];
    [_progressSlider release];
    [_lyrics release];
    [super dealloc];
}
@end
