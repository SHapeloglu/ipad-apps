#import <UIKit/UIKit.h>
@interface SearchViewController:UITableViewController<UISearchBarDelegate>{NSString*_pdfPath;NSArray*_results;UISearchBar*_bar;}
- (id)initWithPDFPath:(NSString*)path;
@end
