#import "SearchViewController.h"
#import "SimplePDFSearch.h"
@implementation SearchViewController
- (id)initWithPDFPath:(NSString*)p{if((self=[super initWithStyle:UITableViewStylePlain])){_pdfPath=[p copy];self.title=@"PDF Ara";}return self;}
- (void)viewDidLoad{[super viewDidLoad];_bar=[[UISearchBar alloc]initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,44)];_bar.delegate=self;self.tableView.tableHeaderView=_bar;}
- (void)searchBarSearchButtonClicked:(UISearchBar*)s{[_results release];_results=[[SimplePDFSearch searchTerm:s.text inPath:_pdfPath]retain];[self.tableView reloadData];[s resignFirstResponder];}
- (NSInteger)tableView:(UITableView*)t numberOfRowsInSection:(NSInteger)s{return [_results count];}
- (UITableViewCell*)tableView:(UITableView*)t cellForRowAtIndexPath:(NSIndexPath*)i{static NSString*cid=@"s";UITableViewCell*c=[t dequeueReusableCellWithIdentifier:cid];if(!c)c=[[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cid]autorelease];c.textLabel.text=[NSString stringWithFormat:@"Eşleşme %ld",(long)i.row+1];c.detailTextLabel.text=[_results objectAtIndex:i.row];return c;}
- (void)dealloc{[_pdfPath release];[_results release];[_bar release];[super dealloc];}
@end
