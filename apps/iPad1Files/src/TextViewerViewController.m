#import "TextViewerViewController.h"
#import "IP1FileManager.h"

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

    NSString *parent = [_path stringByDeletingLastPathComponent];
    BOOL protectedArea = [[IP1FileManager sharedManager] isProtectedSystemDirectory:parent];
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:_path error:nil];
    unsigned long long fileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];

    if (!protectedArea && fileSize <= (2ULL * 1024ULL * 1024ULL)) {
        UIBarButtonItem *edit =
            [[[UIBarButtonItem alloc] initWithTitle:@"Düzenle"
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(toggleEditing)] autorelease];
        self.navigationItem.rightBarButtonItem = edit;
    }

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

- (void)toggleEditing {
    if (!_textView.editable) {
        NSString *parent = [_path stringByDeletingLastPathComponent];
        if ([[IP1FileManager sharedManager] isProtectedSystemDirectory:parent]) return;

        _textView.editable = YES;
        self.navigationItem.rightBarButtonItem.title = @"Kaydet";
        [_textView becomeFirstResponder];
        return;
    }

    NSError *error = nil;
    BOOL ok = [_textView.text writeToFile:_path
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:&error];
    if (!ok) {
        UIAlertView *a = [[[UIAlertView alloc] initWithTitle:@"Kaydedilemedi"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Tamam"
                                          otherButtonTitles:nil] autorelease];
        [a show];
        return;
    }

    _textView.editable = NO;
    self.navigationItem.rightBarButtonItem.title = @"Düzenle";
    [_textView resignFirstResponder];
}

- (void)dealloc {
    [_path release];
    [_textView release];
    [super dealloc];
}

@end
