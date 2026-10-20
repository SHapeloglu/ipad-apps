#import <UIKit/UIKit.h>

@interface PKTownMapView : UIView {
    NSString *_dayPart;
    NSString *_season;
    NSString *_requestLocation;
}

@property(nonatomic, copy) NSString *dayPart;
@property(nonatomic, copy) NSString *season;
@property(nonatomic, copy) NSString *requestLocation;

@end
