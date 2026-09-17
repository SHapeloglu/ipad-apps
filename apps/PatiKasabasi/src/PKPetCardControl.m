#import "PKPetCardControl.h"
#import "PKPetAvatarView.h"
#import "PKTheme.h"
#import <QuartzCore/QuartzCore.h>

@implementation PKPetCardControl

@synthesize speciesIdentifier = _speciesIdentifier;

- (id)initWithFrame:(CGRect)frame
  speciesIdentifier:(NSString *)speciesIdentifier
                name:(NSString *)name
              detail:(NSString *)detail {
    self = [super initWithFrame:frame];
    if (self) {
        _speciesIdentifier = [speciesIdentifier copy];
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.92f];
        self.layer.cornerRadius = 18.0f;
        self.layer.borderWidth = 3.0f;
        self.layer.borderColor = [UIColor colorWithWhite:0.82f alpha:1.0f].CGColor;

        _avatarView = [[PKPetAvatarView alloc] initWithFrame:CGRectMake(20.0f, 10.0f, frame.size.width - 40.0f, 185.0f)
                                            speciesIdentifier:speciesIdentifier];
        _avatarView.userInteractionEnabled = NO;
        [self addSubview:_avatarView];

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 195.0f, frame.size.width - 16.0f, 35.0f)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [PKTheme darkTealColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:24.0f];
        _nameLabel.textAlignment = UITextAlignmentCenter;
        _nameLabel.text = name;
        [self addSubview:_nameLabel];

        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 230.0f, frame.size.width - 24.0f, 50.0f)];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.textColor = [PKTheme inkColor];
        _detailLabel.font = [UIFont systemFontOfSize:15.0f];
        _detailLabel.textAlignment = UITextAlignmentCenter;
        _detailLabel.numberOfLines = 2;
        _detailLabel.text = detail;
        [self addSubview:_detailLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderColor = selected ? [PKTheme coralColor].CGColor : [UIColor colorWithWhite:0.82f alpha:1.0f].CGColor;
    self.backgroundColor = selected ? [UIColor colorWithRed:1.0f green:0.96f blue:0.87f alpha:1.0f] : [UIColor colorWithWhite:1.0f alpha:0.92f];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15f];
    self.transform = selected ? CGAffineTransformMakeScale(1.035f, 1.035f) : CGAffineTransformIdentity;
    [UIView commitAnimations];
}

- (void)dealloc {
    [_speciesIdentifier release];
    [_avatarView release];
    [_nameLabel release];
    [_detailLabel release];
    [super dealloc];
}

@end
