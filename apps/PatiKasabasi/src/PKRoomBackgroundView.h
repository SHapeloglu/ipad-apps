#import <UIKit/UIKit.h>

@interface PKRoomBackgroundView : UIView {
    NSArray *_placedItems;
    NSString *_dayPart;
    NSString *_season;
}

@property(nonatomic, copy) NSArray *placedItems;
@property(nonatomic, copy) NSString *dayPart;
@property(nonatomic, copy) NSString *season;

- (NSString *)itemIdentifierAtPoint:(CGPoint)point;

@end
