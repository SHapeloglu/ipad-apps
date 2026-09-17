#import <UIKit/UIKit.h>

@interface PKRoomBackgroundView : UIView {
    NSArray *_placedItems;
    NSString *_dayPart;
    NSString *_season;
    NSString *_highlightedItemIdentifier;
}

@property(nonatomic, copy) NSArray *placedItems;
@property(nonatomic, copy) NSString *dayPart;
@property(nonatomic, copy) NSString *season;
@property(nonatomic, copy) NSString *highlightedItemIdentifier;

- (NSString *)itemIdentifierAtPoint:(CGPoint)point;

@end
