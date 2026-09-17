#import <UIKit/UIKit.h>
#import "URLImportViewController.h"
@interface PDFLibraryViewController:UITableViewController<URLImportViewControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{NSArray*_pdfFiles;UILabel*_emptyLabel;NSIndexPath*_actionIndexPath;}
- (void)reloadPDFList;
- (void)importExternalPDFURL:(NSURL*)url;
@end
