#import <UIKit/UIKit.h>

@class PKPetAvatarView;

@interface PKPetCardControl : UIControl {
    NSString *_speciesIdentifier;
    PKPetAvatarView *_avatarView;
    UILabel *_nameLabel;
    UILabel *_detailLabel;
}

@property(nonatomic, copy) NSString *speciesIdentifier;

- (id)initWithFrame:(CGRect)frame
  speciesIdentifier:(NSString *)speciesIdentifier
                name:(NSString *)name
              detail:(NSString *)detail;

@end
