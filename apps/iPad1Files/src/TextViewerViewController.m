#import "TextViewerViewController.h"

@implementation TextViewerViewController

- (id)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = [path copy];
        self.title = [path lastPathComponent];
    }
    return self;
}

- (void)loadView {
    UIView *view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    view.backgroundColor = [UIColor whiteColor];

    _textView = [[UITextView alloc] initWithFrame:view.bounds];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.editable = NO;
    _textView.font = [UIFont fontWithName:@"Courier" size:14.0];
    [view addSubview:_textView];

    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSError *error = nil;
    NSString *text = [NSString stringWithContentsOfFile:_path
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];

    if (!text) {
        text = [NSString stringWithContentsOfFile:_path
                                    usedEncoding:NULL
                                           error:&error];
    }

    _textView.text = text ?: [NSString stringWithFormat:@"Dosya okunamadı.\n%@", error ?: @""];
}

- (void)dealloc {
    [_path release];
    [_textView release];
    [super dealloc];
}

@end
