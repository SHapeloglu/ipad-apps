#import "PhotoAlbumViewController.h"

@implementation PhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.92 green:0.95 blue:1 alpha:1];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(30,30,708,60)] autorelease];
    title.text=@"Fotoğraf Albümü";
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:34];
    title.backgroundColor=[UIColor clearColor];
    [self.view addSubview:title];

    NSString *dir=[self albumDirectory];
    NSArray *files=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    NSInteger shown=0;
    for(NSString *fn in files) {
        if(![[fn pathExtension].lowercaseString isEqualToString:@"png"]) continue;
        UIImage *im=[UIImage imageWithContentsOfFile:[dir stringByAppendingPathComponent:fn]];
        if(!im) continue;
        NSInteger row=shown/3, col=shown%3;
        UIImageView *iv=[[[UIImageView alloc] initWithImage:im] autorelease];
        iv.frame=CGRectMake(45+col*240,130+row*220,210,190);
        iv.contentMode=UIViewContentModeScaleAspectFill;
        iv.clipsToBounds=YES;
        [self.view addSubview:iv];
        shown++;
        if(shown>=9) break;
    }

    if(shown==0) {
        UILabel *empty=[[[UILabel alloc] initWithFrame:CGRectMake(100,320,568,120)] autorelease];
        empty.text=@"Henüz fotoğraf yok.\nAna ekrandaki Kamera düğmesini kullan.";
        empty.numberOfLines=2;
        empty.textAlignment=UITextAlignmentCenter;
        empty.font=[UIFont systemFontOfSize:24];
        empty.backgroundColor=[UIColor clearColor];
        [self.view addSubview:empty];
    }

    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame=CGRectMake(30,930,160,55);
    [back setTitle:@"Geri" forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
}

- (NSString *)albumDirectory {
    NSString *docs=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *dir=[docs stringByAppendingPathComponent:@"Album"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

- (void)goBack { [self dismissModalViewControllerAnimated:YES]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return o==UIInterfaceOrientationPortrait; }

@end
