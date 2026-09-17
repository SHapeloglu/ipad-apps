#import "DrawingViewController.h"
#import "DrawingView.h"

#define TOP_HEIGHT 68.0f
#define BOTTOM_HEIGHT 62.0f
#define AUTOSAVE_DELAY 2.0

@implementation DrawingViewController

- (UIColor *)colorWithR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b { return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]; }
- (UIButton *)textButton:(NSString *)title tag:(NSInteger)tag { UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];[b setTitle:title forState:UIControlStateNormal];b.titleLabel.font=[UIFont boldSystemFontOfSize:12];b.tag=tag;[b addTarget:self action:@selector(toolPressed:) forControlEvents:UIControlEventTouchUpInside];return b; }

- (void)loadView
{
    UIView *root=[[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease]; root.backgroundColor=[UIColor colorWithWhite:.88 alpha:1]; self.view=root;
    _topToolbar=[[UIView alloc] initWithFrame:CGRectZero]; _topToolbar.backgroundColor=[UIColor colorWithWhite:.94 alpha:1]; [self.view addSubview:_topToolbar];
    _bottomToolbar=[[UIView alloc] initWithFrame:CGRectZero]; _bottomToolbar.backgroundColor=[UIColor colorWithWhite:.94 alpha:1]; [self.view addSubview:_bottomToolbar];
    _drawingView=[[DrawingView alloc] initWithFrame:CGRectZero]; [self.view addSubview:_drawingView]; _lastPaintColor=[[UIColor blackColor] retain];
    NSArray *colors=[NSArray arrayWithObjects:[UIColor blackColor],[self colorWithR:245 g:70 b:75],[self colorWithR:255 g:145 b:55],[self colorWithR:255 g:220 b:70],[self colorWithR:70 g:200 b:110],[self colorWithR:60 g:150 b:240],[self colorWithR:145 g:95 b:220],[self colorWithR:245 g:95 b:180],nil];
    int i; for(i=0;i<8;i++){UIButton *b=[UIButton buttonWithType:UIButtonTypeCustom];b.backgroundColor=[colors objectAtIndex:i];b.tag=100+i;[b addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];[_topToolbar addSubview:b];}
    NSArray *top=[NSArray arrayWithObjects:@"İnce",@"Orta",@"Kalın",@"Normal",@"Pastel",@"Fosfor",@"Gökkuşağı",nil]; for(i=0;i<7;i++)[_topToolbar addSubview:[self textButton:[top objectAtIndex:i] tag:201+i]];
    NSArray *bottom=[NSArray arrayWithObjects:@"↶ Geri",@"İleri ↷",@"Dolgu",@"Silgi",@"Damga",@"Boyama",@"Şekil",@"Simetri",@"Yazı",@"Çizimlerim",@"Kaydet",nil]; for(i=0;i<11;i++)[_bottomToolbar addSubview:[self textButton:[bottom objectAtIndex:i] tag:301+i]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canvasChanged:) name:@"KidsDrawCanvasChanged" object:_drawingView];
    [self performSelector:@selector(loadAutosaveDraft) withObject:nil afterDelay:0.1];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews]; CGRect b=self.view.bounds; _topToolbar.frame=CGRectMake(0,0,b.size.width,TOP_HEIGHT); _bottomToolbar.frame=CGRectMake(0,b.size.height-BOTTOM_HEIGHT,b.size.width,BOTTOM_HEIGHT); _drawingView.frame=CGRectMake(0,TOP_HEIGHT,b.size.width,b.size.height-TOP_HEIGHT-BOTTOM_HEIGHT);
    CGFloat x=8; int i; for(i=0;i<8;i++){UIView *v=[_topToolbar viewWithTag:100+i];v.frame=CGRectMake(x,12,42,42);x+=48;} for(i=0;i<7;i++){UIView *v=[_topToolbar viewWithTag:201+i];v.frame=CGRectMake(x,10,62,46);x+=65;}
    CGFloat gap=4,bw=(b.size.width-gap*12)/11.0f;x=gap; for(i=0;i<11;i++){UIView *v=[_bottomToolbar viewWithTag:301+i];v.frame=CGRectMake(x,8,bw,46);x+=bw+gap;}
    if(_galleryOverlay) _galleryOverlay.frame=self.view.bounds;
}

- (void)selectPaintMode { _drawingView.bucketMode=NO; _drawingView.stampType=KidsStampNone; _drawingView.shapeType=KidsShapeNone; _drawingView.strokeColor=_lastPaintColor; }
- (void)colorPressed:(UIButton *)sender
{
    NSArray *colors=[NSArray arrayWithObjects:[UIColor blackColor],[self colorWithR:245 g:70 b:75],[self colorWithR:255 g:145 b:55],[self colorWithR:255 g:220 b:70],[self colorWithR:70 g:200 b:110],[self colorWithR:60 g:150 b:240],[self colorWithR:145 g:95 b:220],[self colorWithR:245 g:95 b:180],nil]; NSInteger idx=sender.tag-100; if(idx>=0&&idx<[colors count]){UIColor *c=[colors objectAtIndex:idx];[_lastPaintColor release];_lastPaintColor=[c retain];_drawingView.strokeColor=c;}
}

- (void)toolPressed:(UIButton *)s
{
    switch(s.tag){
        case 201:[self selectPaintMode];_drawingView.lineWidth=3;break; case 202:[self selectPaintMode];_drawingView.lineWidth=7;break; case 203:[self selectPaintMode];_drawingView.lineWidth=14;break;
        case 204:[self selectPaintMode];_drawingView.brushStyle=KidsBrushNormal;break; case 205:[self selectPaintMode];_drawingView.brushStyle=KidsBrushPastel;break; case 206:[self selectPaintMode];_drawingView.brushStyle=KidsBrushNeon;break; case 207:[self selectPaintMode];_drawingView.brushStyle=KidsBrushRainbow;break;
        case 301:[_drawingView undo];break; case 302:[_drawingView redo];break;
        case 303:_drawingView.bucketMode=YES;_drawingView.stampType=KidsStampNone;_drawingView.shapeType=KidsShapeNone;_drawingView.strokeColor=_lastPaintColor;break;
        case 304:_drawingView.bucketMode=NO;_drawingView.stampType=KidsStampNone;_drawingView.shapeType=KidsShapeNone;_drawingView.brushStyle=KidsBrushNormal;_drawingView.lineWidth=24;_drawingView.strokeColor=_drawingView.canvasColor;break;
        case 305:[self chooseStamp];break; case 306:[self chooseColoringPage];break; case 307:[self chooseShape];break; case 308:_drawingView.mirrorMode=!_drawingView.mirrorMode;[s setTitle:(_drawingView.mirrorMode?@"Simetri ✓":@"Simetri") forState:UIControlStateNormal];break; case 309:[self promptText];break; case 310:[self showGallery];break; case 311:[self saveDrawing];break; default:break;
    }
}

- (void)chooseStamp { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Damga 1/4" message:@"Bir damga seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Yıldız",@"Kalp",@"Gülen",@"Daire",@"Kare",@"Daha...",nil] autorelease];a.tag=610;[a show]; }
- (void)chooseStampPage2 { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Damga 2/4" message:@"Bir damga seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Üçgen",@"Çiçek",@"Güneş",@"Bulut",@"Araba",@"Daha...",nil] autorelease];a.tag=611;[a show]; }
- (void)chooseStampPage3 { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Damga 3/4" message:@"Bir damga seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Balık",@"Kelebek",@"Ay",@"Elmas",@"Balon",@"Daha...",nil] autorelease];a.tag=612;[a show]; }
- (void)chooseStampPage4 { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Damga 4/4" message:@"Bir damga seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Elma",@"Ağaç",@"Ev",@"Roket",@"Kedi",@"Daha...",nil] autorelease];a.tag=613;[a show]; }
- (void)chooseStampPage5 { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Damga 5/5" message:@"Bir damga seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Robot",@"Taç",@"Müzik",@"Şimşek",nil] autorelease];a.tag=614;[a show]; }
- (void)chooseColoringPage { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Boyama 1/4" message:@"Bir resim seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Çiçek",@"Ev",@"Balık",@"Kelebek",@"Araba",@"Daha...",nil] autorelease];a.tag=601;[a show]; }
- (void)chooseColoringPage2 { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Boyama 2/4" message:@"Bir resim seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Roket",@"Kedi",@"Ağaç",@"Güneş",@"Robot",@"Daha...",nil] autorelease];a.tag=603;[a show]; }
- (void)chooseColoringPage3 { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Boyama 3/4" message:@"Bir resim seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Gemi",@"Dondurma",@"Uçurtma",@"Mantar",@"Kaplumbağa",@"Daha...",nil] autorelease];a.tag=604;[a show]; }
- (void)chooseColoringPage4 { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Boyama 4/4" message:@"Bir resim seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Tren",@"Şemsiye",@"Hediye",@"Kuş",@"Kalp",nil] autorelease];a.tag=605;[a show]; }
- (void)chooseShape { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Şekil" message:@"Çizmek istediğin şekli seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Çizgi",@"Dikdörtgen",@"Daire/Oval",@"Üçgen",nil] autorelease];a.tag=620;[a show]; }
- (void)promptText { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Yazı Ekle" message:@"Yazını gir." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Ekle",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;a.tag=621;[a show]; }
- (void)confirmClear { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Resmi temizle?" message:@"Bütün çizim silinecek." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Temizle",nil] autorelease];a.tag=501;[a show]; }

- (void)alertView:(UIAlertView *)a clickedButtonAtIndex:(NSInteger)i
{
    if(a.tag==501&&i==1)[_drawingView clearCanvas];
    else if(a.tag==601&&i>=1&&i<=5)[_drawingView showColoringTemplate:i-1]; else if(a.tag==601&&i==6)[self chooseColoringPage2];
    else if(a.tag==603&&i>=1&&i<=5)[_drawingView showColoringTemplate:4+i]; else if(a.tag==603&&i==6)[self chooseColoringPage3];
    else if(a.tag==604&&i>=1&&i<=5)[_drawingView showColoringTemplate:9+i]; else if(a.tag==604&&i==6)[self chooseColoringPage4];
    else if(a.tag==605&&i>=1&&i<=5)[_drawingView showColoringTemplate:14+i];
    else if(a.tag==610&&i>=1&&i<=5){[self selectPaintMode];_drawingView.stampType=(KidsStampType)i;} else if(a.tag==610&&i==6)[self chooseStampPage2];
    else if(a.tag==611&&i>=1&&i<=5){[self selectPaintMode];_drawingView.stampType=(KidsStampType)(i+5);} else if(a.tag==611&&i==6)[self chooseStampPage3];
    else if(a.tag==612&&i>=1&&i<=5){[self selectPaintMode];_drawingView.stampType=(KidsStampType)(i+10);} else if(a.tag==612&&i==6)[self chooseStampPage4];
    else if(a.tag==613&&i>=1&&i<=5){[self selectPaintMode];_drawingView.stampType=(KidsStampType)(i+15);} else if(a.tag==613&&i==6)[self chooseStampPage5];
    else if(a.tag==614&&i>=1&&i<=4){[self selectPaintMode];_drawingView.stampType=(KidsStampType)(i+20);}
    else if(a.tag==620&&i>=1&&i<=4){[self selectPaintMode];_drawingView.shapeType=(KidsShapeType)i;}
    else if(a.tag==621&&i==1){NSString *text=[[a textFieldAtIndex:0] text];[_drawingView addText:text];}
}

- (NSString *)autosavePath
{
    NSArray *dirs=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    return [[dirs objectAtIndex:0] stringByAppendingPathComponent:@"KidsDraw-Autosave.png"];
}
- (void)canvasChanged:(NSNotification *)n
{
    if(_autosaveTimer){[_autosaveTimer invalidate];[_autosaveTimer release];_autosaveTimer=nil;}
    _autosaveTimer=[[NSTimer scheduledTimerWithTimeInterval:AUTOSAVE_DELAY target:self selector:@selector(writeAutosave:) userInfo:nil repeats:NO] retain];
}
- (void)writeAutosave:(NSTimer *)timer
{
    NSData *png=UIImagePNGRepresentation([_drawingView renderedImage]); if(png)[png writeToFile:[self autosavePath] atomically:YES];
    [_autosaveTimer release]; _autosaveTimer=nil;
}
- (void)loadAutosaveDraft
{
    UIImage *im=[UIImage imageWithContentsOfFile:[self autosavePath]]; if(im)[_drawingView setRenderedImage:im];
}
- (void)openExternalImageAtPath:(NSString *)path
{
    if(!path || [path length]==0) return; NSString *ext=[[path pathExtension] lowercaseString]; if(!([ext isEqualToString:@"png"]||[ext isEqualToString:@"jpg"]||[ext isEqualToString:@"jpeg"])) return;
    UIImage *im=[UIImage imageWithContentsOfFile:path]; if(im){[_drawingView setRenderedImage:im];[self canvasChanged:nil];}
}

- (NSString *)galleryDirectory
{
    NSArray *dirs=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES); NSString *d=[[dirs objectAtIndex:0] stringByAppendingPathComponent:@"KidsDrawGallery"]; [[NSFileManager defaultManager] createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:NULL]; return d;
}
- (NSArray *)galleryPaths
{
    NSString *d=[self galleryDirectory]; NSArray *names=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:d error:NULL]; names=[names sortedArrayUsingSelector:@selector(compare:)]; NSMutableArray *p=[NSMutableArray array]; NSInteger i; for(i=[names count]-1;i>=0;i--){NSString *n=[names objectAtIndex:i];if([[n pathExtension] caseInsensitiveCompare:@"png"]==NSOrderedSame)[p addObject:[d stringByAppendingPathComponent:n]];} return p;
}
- (UIImage *)thumbnailForImage:(UIImage *)im size:(CGSize)s { UIGraphicsBeginImageContext(s);[[UIColor whiteColor] setFill];UIRectFill(CGRectMake(0,0,s.width,s.height));CGFloat scale=MIN(s.width/im.size.width,s.height/im.size.height);CGSize z=CGSizeMake(im.size.width*scale,im.size.height*scale);[im drawInRect:CGRectMake((s.width-z.width)/2,(s.height-z.height)/2,z.width,z.height)];UIImage *out=UIGraphicsGetImageFromCurrentImageContext();UIGraphicsEndImageContext();return out; }
- (void)showGallery
{
    if(_galleryOverlay)[_galleryOverlay removeFromSuperview];[_galleryOverlay release];_galleryOverlay=[[UIView alloc] initWithFrame:self.view.bounds];_galleryOverlay.backgroundColor=[UIColor colorWithWhite:.12 alpha:.96];[self.view addSubview:_galleryOverlay];
    UIButton *close=[self textButton:@"Kapat" tag:900]; close.frame=CGRectMake(16,12,90,42);[close addTarget:self action:@selector(closeGallery) forControlEvents:UIControlEventTouchUpInside];[_galleryOverlay addSubview:close];
    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(125,12,600,42)] autorelease];title.backgroundColor=[UIColor clearColor];title.textColor=[UIColor whiteColor];title.font=[UIFont boldSystemFontOfSize:24];title.text=@"Çizimlerim";[_galleryOverlay addSubview:title];
    [_galleryFiles release];_galleryFiles=[[self galleryPaths] retain];
    if([_galleryFiles count]==0){UILabel *e=[[[UILabel alloc] initWithFrame:CGRectMake(0,250,self.view.bounds.size.width,60)] autorelease];e.backgroundColor=[UIColor clearColor];e.textColor=[UIColor whiteColor];e.textAlignment=UITextAlignmentCenter;e.font=[UIFont boldSystemFontOfSize:22];e.text=@"Henüz kaydedilmiş resim yok.";[_galleryOverlay addSubview:e];return;}
    UIScrollView *scroll=[[[UIScrollView alloc] initWithFrame:CGRectMake(20,70,self.view.bounds.size.width-40,self.view.bounds.size.height-90)] autorelease];[_galleryOverlay addSubview:scroll]; CGFloat tw=180,th=135,g=18; int cols=5; NSInteger i,max=MIN((NSInteger)[_galleryFiles count],30); for(i=0;i<max;i++){NSString *path=[_galleryFiles objectAtIndex:i];UIImage *im=[UIImage imageWithContentsOfFile:path];UIButton *b=[UIButton buttonWithType:UIButtonTypeCustom];b.frame=CGRectMake((i%cols)*(tw+g),(i/cols)*(th+g),tw,th);[b setImage:[self thumbnailForImage:im size:CGSizeMake(tw,th)] forState:UIControlStateNormal];b.tag=1000+i;[b addTarget:self action:@selector(openGalleryImage:) forControlEvents:UIControlEventTouchUpInside];[scroll addSubview:b];} scroll.contentSize=CGSizeMake(scroll.bounds.size.width,((max+cols-1)/cols)*(th+g));
}
- (void)closeGallery { [_galleryOverlay removeFromSuperview];[_galleryOverlay release];_galleryOverlay=nil;[_galleryFiles release];_galleryFiles=nil; }
- (void)openGalleryImage:(UIButton *)b { NSInteger i=b.tag-1000;if(i>=0&&i<[_galleryFiles count]){UIImage *im=[UIImage imageWithContentsOfFile:[_galleryFiles objectAtIndex:i]];[_drawingView setRenderedImage:im];[self closeGallery];} }

- (void)saveDrawing
{
    UIImage *im=[_drawingView renderedImage]; NSDateFormatter *f=[[[NSDateFormatter alloc] init] autorelease];[f setDateFormat:@"yyyyMMdd-HHmmss"];NSString *name=[NSString stringWithFormat:@"KidsDraw-%@.png",[f stringFromDate:[NSDate date]]];NSString *path=[[self galleryDirectory] stringByAppendingPathComponent:name];[UIImagePNGRepresentation(im) writeToFile:path atomically:YES]; UIImageWriteToSavedPhotosAlbum(im,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo { NSString *t=error?@"Galeriye kaydedildi":@"Kaydedildi";NSString *m=error?@"KidsDraw Çizimlerim'e kaydedildi; Fotoğraflar'a eklenemedi.":@"Resim Çizimlerim'e ve Fotoğraflar'a kaydedildi.";UIAlertView *a=[[[UIAlertView alloc] initWithTitle:t message:m delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return UIInterfaceOrientationIsLandscape(o); }
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self];if(_autosaveTimer){[_autosaveTimer invalidate];[_autosaveTimer release];}[_drawingView release];[_topToolbar release];[_bottomToolbar release];[_galleryOverlay release];[_galleryFiles release];[_lastPaintColor release];[super dealloc]; }
@end
