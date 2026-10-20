#import <UIKit/UIKit.h>
@class TicketViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *_window;
    TicketViewController *_ticketViewController;
}
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) TicketViewController *ticketViewController;
@end
