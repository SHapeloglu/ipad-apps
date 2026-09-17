#import "ThumbnailViewController.h"
@implementation ThumbnailViewController
@synthesize delegate=_delegate;
- (id)initWithPDFPath:(NSString*)path { if((self=[super initWithStyle:UITableViewStylePlain])){_pdfPath=[path copy];_doc=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);_count=_doc?CGPDFDocumentGetNumberOfPages(_doc):0;self.title=@"Sayfalar";}return self; }
- (NSInteger)tableView:(UITableView*)t numberOfRowsInSection:(NSInteger)s{return _count;}
- (UITableViewCell*)tableView:(UITableView*)t cellForRowAtIndexPath:(NSIndexPath*)i{static NSString*cid=@"thumb";UITableViewCell*c=[t dequeueReusableCellWithIdentifier:cid];if(!c)c=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid]autorelease];c.textLabel.text=[NSString stringWithFormat:@"Sayfa %ld",(long)i.row+1];CGPDFPageRef p=CGPDFDocumentGetPage(_doc,i.row+1);if(p){CGSize z=CGSizeMake(70,90);UIGraphicsBeginImageContext(z);CGContextRef x=UIGraphicsGetCurrentContext();CGContextSetRGBFillColor(x,1,1,1,1);CGContextFillRect(x,(CGRect){CGPointZero,z});CGContextTranslateCTM(x,0,z.height);CGContextScaleCTM(x,1,-1);CGContextConcatCTM(x,CGPDFPageGetDrawingTransform(p,kCGPDFMediaBox,(CGRect){CGPointZero,z},0,true));CGContextDrawPDFPage(x,p);c.imageView.image=UIGraphicsGetImageFromCurrentImageContext();UIGraphicsEndImageContext();}return c;}
- (void)tableView:(UITableView*)t didSelectRowAtIndexPath:(NSIndexPath*)i{if([_delegate respondsToSelector:@selector(thumbnailControllerSelectedPage:)])[_delegate thumbnailControllerSelectedPage:i.row+1];[self.navigationController popViewControllerAnimated:YES];}
- (void)dealloc{[_pdfPath release];if(_doc)CGPDFDocumentRelease(_doc);[super dealloc];}
@end
