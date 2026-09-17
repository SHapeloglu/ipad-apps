#import "ReflowViewController.h"
#import "PDFTextExtractor.h"
@implementation ReflowViewController
- (id)initWithPDFPath:(NSString *)path {
    if((self=[super initWithNibName:nil bundle:nil])) {
        _pdfPath=[path copy];
        _document=CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path]);
        self.title=@"Reflow";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _fontControl=[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"A-",@"A",@"A+",nil]];
    _fontControl.selectedSegmentIndex=1;
    [_fontControl addTarget:self action:@selector(fontChanged) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithCustomView:_fontControl] autorelease];
    _textView=[[UITextView alloc] initWithFrame:self.view.bounds];
    _textView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _textView.editable=NO; _textView.font=[UIFont systemFontOfSize:19];
    [self.view addSubview:_textView];
    NSMutableString *all=[NSMutableString string];
    size_t pages=_document?CGPDFDocumentGetNumberOfPages(_document):0;
    for(size_t i=1;i<=pages;i++) {
        NSString *txt=[PDFTextExtractor textForPage:CGPDFDocumentGetPage(_document,i)];
        if([txt length]) [all appendFormat:@"\n\n—— Sayfa %lu ——\n\n%@",(unsigned long)i,txt];
    }
    _textView.text=all;
}
- (void)fontChanged {
    CGFloat sizes[]={15,19,25}; NSInteger i=_fontControl.selectedSegmentIndex; if(i<0||i>2)i=1;
    _textView.font=[UIFont systemFontOfSize:sizes[i]];
}
- (void)dealloc { [_pdfPath release]; [_textView release]; [_fontControl release]; if(_document)CGPDFDocumentRelease(_document); [super dealloc]; }
@end
