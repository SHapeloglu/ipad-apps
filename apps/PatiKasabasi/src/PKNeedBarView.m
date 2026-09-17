#import "PKNeedBarView.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

@implementation PKNeedBarView

@synthesize value = _value;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, frame.size.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [PKTheme inkColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        _titleLabel.text = title;
        [self addSubview:_titleLabel];

        _trackView = [[UIView alloc] initWithFrame:CGRectMake(102.0f, 10.0f, frame.size.width - 150.0f, frame.size.height - 20.0f)];
        _trackView.backgroundColor = [UIColor colorWithWhite:0.84f alpha:1.0f];
        _trackView.layer.cornerRadius = 8.0f;
        _trackView.clipsToBounds = YES;
        [self addSubview:_trackView];

        _fillView = [[UIView alloc] initWithFrame:_trackView.bounds];
        _fillView.backgroundColor = color;
        _fillView.layer.cornerRadius = 8.0f;
        [_trackView addSubview:_fillView];

        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 44.0f, 0.0f, 44.0f, frame.size.height)];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textColor = [PKTheme inkColor];
        _valueLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _valueLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:_valueLabel];

        self.value = 50;
    }
    return self;
}

- (void)setValue:(NSInteger)value {
    if (value < 0) value = 0;
    if (value > 100) value = 100;
    _value = value;
    _valueLabel.text = [NSString stringWithFormat:@"%ld", (long)value];
    CGRect fillFrame = _trackView.bounds;
    fillFrame.size.width = floorf(_trackView.bounds.size.width * ((CGFloat)value / 100.0f));
    _fillView.frame = fillFrame;
}

- (void)dealloc {
    [_titleLabel release];
    [_valueLabel release];
    [_trackView release];
    [_fillView release];
    [super dealloc];
}

@end
