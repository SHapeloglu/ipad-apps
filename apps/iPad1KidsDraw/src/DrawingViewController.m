#import "DrawingViewController.h"
#import "DrawingView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#define TOP_HEIGHT 108.0f
#define BOTTOM_HEIGHT 64.0f
#define AUTOSAVE_DELAY 2.0

@implementation DrawingViewController

- (UIColor *)colorWithR:(CGFloat)r g:(CGFloat)g b:(CGFloat)b { return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]; }
- (UIButton *)textButton:(NSString *)title tag:(NSInteger)tag
{
    UIButton *b=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font=[UIFont boldSystemFontOfSize:14.0f];
    b.titleLabel.textAlignment=UITextAlignmentCenter;
    b.titleLabel.numberOfLines=2;
    b.titleLabel.adjustsFontSizeToFitWidth=YES;
    b.titleLabel.minimumFontSize=10.0f;
    b.tag=tag;
    [b addTarget:self action:@selector(toolPressed:) forControlEvents:UIControlEventTouchUpInside];
    return b;
}

- (NSArray *)paintColors
{
    return [NSArray arrayWithObjects:
        [UIColor blackColor],
        [self colorWithR:90 g:90 b:90],
        [UIColor whiteColor],
        [self colorWithR:230 g:45 b:55],
        [self colorWithR:255 g:105 b:35],
        [self colorWithR:255 g:210 b:20],
        [self colorWithR:180 g:245 b:40],
        [self colorWithR:45 g:190 b:80],
        [self colorWithR:30 g:210 b:190],
        [self colorWithR:35 g:170 b:245],
        [self colorWithR:35 g:80 b:215],
        [self colorWithR:115 g:70 b:210],
        [self colorWithR:205 g:55 b:220],
        [self colorWithR:250 g:80 b:160],
        [self colorWithR:145 g:85 b:45],
        [self colorWithR:255 g:245 b:125],
        nil];
}

- (void)loadView
{
    UIView *root=[[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    root.backgroundColor=[UIColor colorWithWhite:.88 alpha:1];
    self.view=root;

    _topToolbar=[[UIView alloc] initWithFrame:CGRectZero];
    _topToolbar.backgroundColor=[UIColor colorWithWhite:.94 alpha:1];
    [self.view addSubview:_topToolbar];

    _bottomToolbar=[[UIView alloc] initWithFrame:CGRectZero];
    _bottomToolbar.backgroundColor=[UIColor colorWithWhite:.94 alpha:1];
    [self.view addSubview:_bottomToolbar];

    _drawingView=[[DrawingView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_drawingView];
    _lastPaintColor=[[UIColor blackColor] retain];

    _lineSizeIndex=2;   /* 7 px */
    _stampSizeIndex=1;  /* orta */
    _sprayDensityIndex=1;
    _spraySizeIndex=1;
    _neonStrengthIndex=1;
    _opacityIndex=3;
    _eraserSizeIndex=2;
    _secondaryBrushIndex=0;
    _smudgeStrengthIndex=1;
    _mixerStrengthIndex=1;
    _stampRotationIndex=0;
    _smoothingIndex=1;
    NSArray *savedFav=[[NSUserDefaults standardUserDefaults] objectForKey:@"KidsDrawFavoriteDrawings"];
    _favoriteDrawings=[[NSMutableSet alloc] initWithArray:(savedFav?savedFav:[NSArray array])];
    NSArray *savedBrushFav=[[NSUserDefaults standardUserDefaults] objectForKey:@"KidsDrawFavoriteBrushes"];
    _favoriteBrushes=[[NSMutableArray alloc] initWithArray:(savedBrushFav?savedBrushFav:[NSArray array])];
    NSArray *savedRecent=[[NSUserDefaults standardUserDefaults] objectForKey:@"KidsDrawRecentBrushes"];
    _recentBrushes=[[NSMutableArray alloc] initWithArray:(savedRecent?savedRecent:[NSArray array])];
    _galleryFilter=0;
    _drawingView.lineWidth=7.0f;
    _drawingView.stampScale=1.0f;
    _drawingView.sprayDensity=1.0f;
    _drawingView.spraySize=1.0f;
    _drawingView.neonStrength=1.0f;
    _drawingView.globalOpacity=1.0f;
    _drawingView.eraserWidth=28.0f;
    _secondaryPaintColor=[[UIColor blueColor] retain];
    _drawingView.secondaryStrokeColor=_secondaryPaintColor;
    _drawingView.secondaryBrushStyle=KidsBrushNormal;
    _drawingView.smoothingEnabled=YES;
    _drawingView.smoothingStrength=0.35f;
    _drawingView.smudgeStrength=0.55f;
    _drawingView.mixerStrength=0.50f;

    _stampPinch=[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleStampPinch:)];
    [_drawingView addGestureRecognizer:_stampPinch];

    _replayFrames=[[NSMutableArray alloc] initWithCapacity:18];
    _stars=(NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:@"KidsDrawStars"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"KidsDrawSoundEnabled"]==nil) _soundEnabled=YES;
    else _soundEnabled=[[NSUserDefaults standardUserDefaults] boolForKey:@"KidsDrawSoundEnabled"];

    NSArray *colors=[self paintColors];
    int i;
    for(i=0;i<16;i++){
        UIButton *b=[UIButton buttonWithType:UIButtonTypeCustom];
        b.backgroundColor=[colors objectAtIndex:i];
        b.tag=100+i;
        [b addTarget:self action:@selector(colorPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_topToolbar addSubview:b];
    }

    [_topToolbar addSubview:[self textButton:@"Fırça" tag:201]];
    [_topToolbar addSubview:[self textButton:@"Kalınlık" tag:202]];
    [_topToolbar addSubview:[self textButton:@"Sprey\nYoğunluğu" tag:203]];
    [_topToolbar addSubview:[self textButton:@"Fosfor" tag:204]];
    [_topToolbar addSubview:[self textButton:@"Sprey\nBoyutu" tag:205]];
    [_topToolbar addSubview:[self textButton:@"Opaklık" tag:206]];
    [_topToolbar addSubview:[self textButton:@"2. Kalem" tag:207]];
    [_topToolbar addSubview:[self textButton:@"Özel\nRenk" tag:208]];
    [_topToolbar addSubview:[self textButton:@"Dağıt" tag:209]];
    [_topToolbar addSubview:[self textButton:@"Karıştır" tag:210]];
    [_topToolbar addSubview:[self textButton:@"Damlalık" tag:211]];
    [_topToolbar addSubview:[self textButton:@"Damga\nDöndür" tag:212]];
    [_topToolbar addSubview:[self textButton:@"Renk\nSeçici" tag:213]];
    [_topToolbar addSubview:[self textButton:@"Önizle" tag:214]];
    [_topToolbar addSubview:[self textButton:@"Yumuşat" tag:215]];

    _starLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    _starLabel.backgroundColor=[UIColor clearColor];
    _starLabel.textAlignment=UITextAlignmentCenter;
    _starLabel.font=[UIFont boldSystemFontOfSize:15.0f];
    [_topToolbar addSubview:_starLabel];
    [self updateStarLabel];

    NSArray *bottom=[NSArray arrayWithObjects:
        @"↶ Geri",@"İleri ↷",@"Dolgu",@"Silgi",@"Damga",@"Damga Boyut",
        @"Boyama",@"Şekil",@"Simetri",@"Yazı",@"Oynat",@"Ödüller",
        @"Ses",@"Temizle",@"Çizimlerim",@"Kaydet",nil];

    for(i=0;i<16;i++) [_bottomToolbar addSubview:[self textButton:[bottom objectAtIndex:i] tag:301+i]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canvasChanged:) name:@"KidsDrawCanvasChanged" object:_drawingView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorPicked:) name:@"KidsDrawColorPicked" object:_drawingView];
    _brushPreview=[[UIView alloc] initWithFrame:CGRectZero];
    _brushPreview.backgroundColor=[UIColor colorWithWhite:0.98f alpha:1.0f];
    _brushPreview.layer.borderWidth=1.0f;
    _brushPreview.hidden=YES;
    _brushPreviewLabel=[[UILabel alloc] initWithFrame:CGRectZero];
    _brushPreviewLabel.backgroundColor=[UIColor clearColor];
    _brushPreviewLabel.textAlignment=UITextAlignmentCenter;
    _brushPreviewLabel.font=[UIFont boldSystemFontOfSize:13.0f];
    [_brushPreview addSubview:_brushPreviewLabel];
    [self.view addSubview:_brushPreview];

    [self performSelector:@selector(loadAutosaveDraft) withObject:nil afterDelay:0.1];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect b=self.view.bounds;

    _topToolbar.frame=CGRectMake(0,0,b.size.width,TOP_HEIGHT);
    _bottomToolbar.frame=CGRectMake(0,b.size.height-BOTTOM_HEIGHT,b.size.width,BOTTOM_HEIGHT);
    _drawingView.frame=CGRectMake(0,TOP_HEIGHT,b.size.width,b.size.height-TOP_HEIGHT-BOTTOM_HEIGHT);

    /*
     * iPad 1 / iOS 5 için üst araçlar iki satıra ayrıldı.
     * 1. satır: renkler + yıldız
     * 2. satır: metinli araçlar
     * Böylece hit alanları ve yazılar sıkışmaz.
     */
    CGFloat left=6.0f;
    CGFloat gap=4.0f;
    CGFloat starWidth=72.0f;
    CGFloat colorsWidth=b.size.width-left*2.0f-starWidth-gap;
    CGFloat colorW=(colorsWidth-gap*15.0f)/16.0f;
    CGFloat x=left;
    int i;

    for(i=0;i<16;i++){
        UIView *v=[_topToolbar viewWithTag:100+i];
        v.frame=CGRectMake(x,7.0f,colorW,36.0f);
        x+=colorW+gap;
    }

    _starLabel.frame=CGRectMake(b.size.width-left-starWidth,7.0f,starWidth,36.0f);
    _starLabel.font=[UIFont boldSystemFontOfSize:16.0f];

    CGFloat toolGap=5.0f;
    CGFloat toolW=(b.size.width-left*2.0f-toolGap*14.0f)/15.0f;
    CGFloat toolY=51.0f;
    x=left;

    for(i=201;i<=215;i++){
        UIView *v=[_topToolbar viewWithTag:i];
        v.frame=CGRectMake(x,toolY,toolW,49.0f);
        x+=toolW+toolGap;
    }

    CGFloat bottomGap=2.0f;
    CGFloat bw=(b.size.width-bottomGap*17.0f)/16.0f;
    x=bottomGap;
    for(i=0;i<16;i++){
        UIView *v=[_bottomToolbar viewWithTag:301+i];
        v.frame=CGRectMake(x,9,bw,46);
        x+=bw+bottomGap;
    }

    _brushPreview.frame=CGRectMake(b.size.width-170.0f,TOP_HEIGHT+8.0f,160.0f,54.0f);
    _brushPreviewLabel.frame=_brushPreview.bounds;
    if(_galleryOverlay) _galleryOverlay.frame=self.view.bounds;
    if(_replayOverlay) _replayOverlay.frame=_drawingView.frame;
}


- (void)selectPaintMode
{
    _drawingView.bucketMode=NO;
    _drawingView.stampType=KidsStampNone;
    _drawingView.shapeType=KidsShapeNone;
    _drawingView.strokeColor=_lastPaintColor;
}

- (void)colorPressed:(UIButton *)sender
{
    NSArray *colors=[self paintColors];
    NSInteger idx=sender.tag-100;
    if(idx>=0 && idx<[colors count]){
        UIColor *c=[colors objectAtIndex:idx];
        [_lastPaintColor release];
        _lastPaintColor=[c retain];
        _drawingView.strokeColor=c;
    }
}

- (void)chooseBrush
{
    /*
     * iOS 5 UIAlertView landscape modunda çok fazla buton gerçek hit-test
     * alanının dışına taşabiliyor. Bu nedenle fırçaları iki kısa sayfaya böleriz.
     */
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Fırça / Kalem"
                                               message:@"Temel çizim aracını seç."
                                              delegate:self
                                     cancelButtonTitle:@"Vazgeç"
                                     otherButtonTitles:@"Normal",
                                                       @"Kurşun Kalem",
                                                       @"Keçeli Kalem",
                                                       @"Pastel",
                                                       @"Efektler…",
                                                       nil] autorelease];
    a.tag=640;
    [a show];
}

- (void)chooseEffectBrush
{
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Efekt Fırçaları"
                                               message:@"Bir efekt seç."
                                              delegate:self
                                     cancelButtonTitle:@"Geri"
                                     otherButtonTitles:@"Fosfor",
                                                       @"Gökkuşağı",
                                                       @"Boya Spreyi",
                                                       @"Tebeşir",
                                                       @"Parmakla Dağıt",
                                                       @"Renk Karıştır",
                                                       @"Sulu Boya",
                                                       nil] autorelease];
    a.tag=643;
    [a show];
}

- (void)cycleLineSize:(UIButton *)button
{
    static const CGFloat sizes[]={2.0f,4.0f,7.0f,12.0f,18.0f,28.0f};
    static NSString *names[]={@"Çok İnce",@"İnce",@"Orta",@"Kalın",@"Çok Kalın",@"XXL"};
    _lineSizeIndex=(_lineSizeIndex+1)%6;
    _drawingView.lineWidth=sizes[_lineSizeIndex];
    [button setTitle:names[_lineSizeIndex] forState:UIControlStateNormal];
}

- (void)cycleStampSize:(UIButton *)button
{
    static const CGFloat scales[]={0.55f,0.80f,1.0f,1.25f,1.55f,1.90f};
    static NSString *names[]={@"Damga XS",@"Damga S",@"Damga M",@"Damga L",@"Damga XL",@"Damga XXL"};
    _stampSizeIndex=(_stampSizeIndex+1)%6;
    _drawingView.stampScale=scales[_stampSizeIndex];
    [button setTitle:names[_stampSizeIndex] forState:UIControlStateNormal];
}


- (void)cycleSprayDensity:(UIButton *)button
{
    static const CGFloat vals[]={0.55f,1.0f,1.45f};
    static NSString *names[]={@"Sprey Az",@"Sprey Orta",@"Sprey Çok"};
    _sprayDensityIndex=(_sprayDensityIndex+1)%3;
    _drawingView.sprayDensity=vals[_sprayDensityIndex];
    [button setTitle:names[_sprayDensityIndex] forState:UIControlStateNormal];
}

- (void)cycleNeonStrength:(UIButton *)button
{
    static const CGFloat vals[]={0.65f,1.0f,1.35f};
    static NSString *names[]={@"Fosfor Az",@"Fosfor Orta",@"Fosfor Çok"};
    _neonStrengthIndex=(_neonStrengthIndex+1)%3;
    _drawingView.neonStrength=vals[_neonStrengthIndex];
    [button setTitle:names[_neonStrengthIndex] forState:UIControlStateNormal];
}


- (void)cycleSpraySize:(UIButton *)button
{
    static const CGFloat vals[]={0.70f,1.0f,1.35f,1.70f};
    static NSString *names[]={@"Sprey S",@"Sprey M",@"Sprey L",@"Sprey XL"};
    _spraySizeIndex=(_spraySizeIndex+1)%4;
    _drawingView.spraySize=vals[_spraySizeIndex];
    [button setTitle:names[_spraySizeIndex] forState:UIControlStateNormal];
}

- (void)cycleOpacity:(UIButton *)button
{
    static const CGFloat vals[]={0.25f,0.50f,0.75f,1.0f};
    static NSString *names[]={@"%25",@"%50",@"%75",@"%100"};
    _opacityIndex=(_opacityIndex+1)%4;
    _drawingView.globalOpacity=vals[_opacityIndex];
    [button setTitle:names[_opacityIndex] forState:UIControlStateNormal];
}

- (void)chooseSecondaryPen
{
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"2. Kalem"
                                               message:@"İkinci parmak için kalem seç."
                                              delegate:self
                                     cancelButtonTitle:@"Vazgeç"
                                     otherButtonTitles:@"Mavi Normal",@"Kırmızı Normal",@"Yeşil Normal",@"Mor Normal",@"Mavi Fosfor",@"Kırmızı Fosfor",@"Mavi Sprey",@"Yeşil Sprey",nil] autorelease];
    a.tag=641;
    [a show];
}

- (void)chooseCustomColor
{
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Özel Renk"
                                               message:@"Hazır özel renklerden birini seç."
                                              delegate:self
                                     cancelButtonTitle:@"Vazgeç"
                                     otherButtonTitles:@"Turkuaz",@"Limon",@"Mercan",@"Lavanta",@"Mint",@"Koyu Lacivert",@"Altın",@"Gül",nil] autorelease];
    a.tag=642;
    [a show];
}

- (void)cycleEraserSize
{
    static const CGFloat vals[]={12.0f,20.0f,28.0f,40.0f,56.0f};
    _eraserSizeIndex=(_eraserSizeIndex+1)%5;
    _drawingView.eraserWidth=vals[_eraserSizeIndex];
}

- (void)handleStampPinch:(UIPinchGestureRecognizer *)g
{
    if(_drawingView.stampType==KidsStampNone) return;
    if(g.state==UIGestureRecognizerStateChanged){
        CGFloat s=_drawingView.stampScale*g.scale;
        if(s<0.45f) s=0.45f;
        if(s>2.20f) s=2.20f;
        _drawingView.stampScale=s;
        g.scale=1.0f;
    }
}


- (void)cycleSmudgeStrength:(UIButton *)button
{
    static const CGFloat vals[]={0.35f,0.55f,0.80f};
    static NSString *names[]={@"Dağıt Az",@"Dağıt Orta",@"Dağıt Çok"};
    _smudgeStrengthIndex=(_smudgeStrengthIndex+1)%3;
    _drawingView.smudgeStrength=vals[_smudgeStrengthIndex];
    _drawingView.brushStyle=KidsBrushSmudge;
    [button setTitle:names[_smudgeStrengthIndex] forState:UIControlStateNormal];
}

- (void)cycleMixerStrength:(UIButton *)button
{
    static const CGFloat vals[]={0.30f,0.50f,0.75f};
    static NSString *names[]={@"Karış Az",@"Karış Orta",@"Karış Çok"};
    _mixerStrengthIndex=(_mixerStrengthIndex+1)%3;
    _drawingView.mixerStrength=vals[_mixerStrengthIndex];
    _drawingView.brushStyle=KidsBrushMixer;
    [button setTitle:names[_mixerStrengthIndex] forState:UIControlStateNormal];
}


- (void)colorPicked:(NSNotification *)n
{
    UIColor *c=[[n userInfo] objectForKey:@"color"];
    if(!c) return;
    [_lastPaintColor release];
    _lastPaintColor=[c retain];
    _drawingView.strokeColor=c;
    [self showBrushPreviewWithText:@"Renk alındı"];
}

- (void)activateEyedropper
{
    _drawingView.eyedropperMode=YES;
    _drawingView.bucketMode=NO;
    _drawingView.stampType=KidsStampNone;
    _drawingView.shapeType=KidsShapeNone;
    [self showBrushPreviewWithText:@"Tuvalden renk seç"];
}

- (void)cycleStampRotation:(UIButton *)button
{
    static const CGFloat vals[]={0.0f,0.785398f,1.570796f,2.356194f,3.141593f,3.926991f,4.712389f,5.497787f};
    static NSString *names[]={@"0°",@"45°",@"90°",@"135°",@"180°",@"225°",@"270°",@"315°"};
    _stampRotationIndex=(_stampRotationIndex+1)%8;
    _drawingView.stampRotation=vals[_stampRotationIndex];
    [button setTitle:names[_stampRotationIndex] forState:UIControlStateNormal];
}

- (void)chooseAdvancedColor
{
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Renk Seçici"
                                               message:@"Renk ailesini seç."
                                              delegate:self
                                     cancelButtonTitle:@"Vazgeç"
                                     otherButtonTitles:@"Kırmızılar",@"Turuncu/Sarı",@"Yeşiller",@"Maviler",@"Mor/Pembe",@"Toprak/Gri",nil] autorelease];
    a.tag=644;
    [a show];
}

- (void)showColorFamily:(NSInteger)family
{
    NSArray *titles=nil;
    if(family==0) titles=[NSArray arrayWithObjects:@"Koyu Kırmızı",@"Kırmızı",@"Açık Kırmızı",@"Mercan",nil];
    else if(family==1) titles=[NSArray arrayWithObjects:@"Turuncu",@"Altın",@"Sarı",@"Limon",nil];
    else if(family==2) titles=[NSArray arrayWithObjects:@"Koyu Yeşil",@"Yeşil",@"Mint",@"Lime",nil];
    else if(family==3) titles=[NSArray arrayWithObjects:@"Lacivert",@"Mavi",@"Açık Mavi",@"Turkuaz",nil];
    else if(family==4) titles=[NSArray arrayWithObjects:@"Mor",@"Lavanta",@"Pembe",@"Gül",nil];
    else titles=[NSArray arrayWithObjects:@"Kahve",@"Taba",@"Gri",@"Siyah",nil];

    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Renk Tonu"
                                               message:@"Bir ton seç."
                                              delegate:self
                                     cancelButtonTitle:@"Geri"
                                     otherButtonTitles:nil] autorelease];
    NSInteger i;
    for(i=0;i<[titles count];i++) [a addButtonWithTitle:[titles objectAtIndex:i]];
    a.tag=645+family;
    [a show];
}

- (UIColor *)advancedColorForFamily:(NSInteger)family item:(NSInteger)item
{
    static const int rgb[6][4][3]={
        {{120,20,25},{220,35,45},{250,105,110},{245,110,90}},
        {{245,125,30},{235,185,40},{255,215,35},{220,240,40}},
        {{20,110,55},{45,185,80},{140,235,190},{180,245,40}},
        {{25,45,110},{35,80,215},{35,170,245},{30,200,190}},
        {{125,60,190},{190,150,240},{250,80,160},{220,80,120}},
        {{110,70,45},{175,115,70},{110,110,110},{20,20,20}}
    };
    if(family<0||family>5||item<0||item>3) return [UIColor blackColor];
    return [self colorWithR:rgb[family][item][0] g:rgb[family][item][1] b:rgb[family][item][2]];
}

- (void)showBrushPreviewWithText:(NSString *)text
{
    _brushPreviewLabel.text=text;
    _brushPreview.hidden=NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBrushPreview) object:nil];
    [self performSelector:@selector(hideBrushPreview) withObject:nil afterDelay:1.2];
}

- (void)hideBrushPreview
{
    _brushPreview.hidden=YES;
}

- (NSString *)currentBrushName
{
    switch(_drawingView.brushStyle){
        case KidsBrushNormal:return @"Normal";
        case KidsBrushPencil:return @"Kurşun Kalem";
        case KidsBrushMarker:return @"Keçeli Kalem";
        case KidsBrushPastel:return @"Pastel";
        case KidsBrushNeon:return @"Fosfor";
        case KidsBrushRainbow:return @"Gökkuşağı";
        case KidsBrushSpray:return @"Boya Spreyi";
        case KidsBrushChalk:return @"Tebeşir";
        case KidsBrushSmudge:return @"Dağıt";
        case KidsBrushMixer:return @"Karıştır";
        case KidsBrushWatercolor:return @"Sulu Boya";
        default:return @"Fırça";
    }
}

- (void)showCurrentBrushPreview
{
    NSString *s=[NSString stringWithFormat:@"%@ • %.0f px • %d%%",
                 [self currentBrushName],
                 _drawingView.lineWidth,
                 (int)(_drawingView.globalOpacity*100.0f)];
    [self showBrushPreviewWithText:s];
}


- (void)cycleSmoothing:(UIButton *)button
{
    static const CGFloat vals[]={0.0f,0.25f,0.40f,0.55f};
    static NSString *names[]={@"Yumuşatma Kapalı",@"Yumuşat Az",@"Yumuşat Orta",@"Yumuşat Çok"};
    _smoothingIndex=(_smoothingIndex+1)%4;
    _drawingView.smoothingEnabled=(_smoothingIndex!=0);
    _drawingView.smoothingStrength=vals[_smoothingIndex];
    [button setTitle:names[_smoothingIndex] forState:UIControlStateNormal];
    [self showCurrentBrushPreview];
}

- (void)persistFavorites
{
    NSArray *arr=[_favoriteDrawings allObjects];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"KidsDrawFavoriteDrawings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleFavoriteForCurrentDrawing
{
    NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"KidsDrawCurrentGalleryPath"];
    if(!path){
        NSArray *all=[self galleryPaths];
        if([all count]>0) path=[all objectAtIndex:0];
    }
    if(!path) return;
    if([_favoriteDrawings containsObject:path]) [_favoriteDrawings removeObject:path];
    else [_favoriteDrawings addObject:path];
    [self persistFavorites];
}


- (void)rememberBrushStyle:(KidsBrushStyle)style
{
    NSNumber *n=[NSNumber numberWithInteger:(NSInteger)style];
    [_recentBrushes removeObject:n];
    [_recentBrushes insertObject:n atIndex:0];
    while([_recentBrushes count]>5) [_recentBrushes removeLastObject];
    [[NSUserDefaults standardUserDefaults] setObject:_recentBrushes forKey:@"KidsDrawRecentBrushes"];
}

- (void)toggleFavoriteBrush
{
    NSNumber *n=[NSNumber numberWithInteger:(NSInteger)_drawingView.brushStyle];
    if([_favoriteBrushes containsObject:n]) [_favoriteBrushes removeObject:n];
    else [_favoriteBrushes addObject:n];
    [[NSUserDefaults standardUserDefaults] setObject:_favoriteBrushes forKey:@"KidsDrawFavoriteBrushes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showBrushPreviewWithText:([_favoriteBrushes containsObject:n]?@"Fırça ★ favoride":@"Fırça favoriden çıktı")];
}

- (NSString *)brushNameForStyle:(KidsBrushStyle)style
{
    switch(style){
        case KidsBrushNormal:return @"Normal";
        case KidsBrushPencil:return @"Kurşun Kalem";
        case KidsBrushMarker:return @"Keçeli Kalem";
        case KidsBrushPastel:return @"Pastel";
        case KidsBrushNeon:return @"Fosfor";
        case KidsBrushRainbow:return @"Gökkuşağı";
        case KidsBrushSpray:return @"Boya Spreyi";
        case KidsBrushChalk:return @"Tebeşir";
        case KidsBrushSmudge:return @"Dağıt";
        case KidsBrushMixer:return @"Karıştır";
        case KidsBrushWatercolor:return @"Sulu Boya";
        default:return @"Fırça";
    }
}

- (void)showBrushList:(NSArray *)styles title:(NSString *)title tag:(NSInteger)tag
{
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:title
                                               message:@"Bir fırça seç."
                                              delegate:self
                                     cancelButtonTitle:@"Geri"
                                     otherButtonTitles:nil] autorelease];
    NSInteger i, max=MIN((NSInteger)[styles count],5);
    for(i=0;i<max;i++){
        KidsBrushStyle s=(KidsBrushStyle)[[styles objectAtIndex:i] integerValue];
        [a addButtonWithTitle:[self brushNameForStyle:s]];
    }
    a.tag=tag;
    [a show];
}

- (void)showToolInfoMenu
{
    BOOL fav=[_favoriteBrushes containsObject:[NSNumber numberWithInteger:(NSInteger)_drawingView.brushStyle]];
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Fırça Araçları"
                                               message:[NSString stringWithFormat:@"%@ • %.0f px • %d%%",
                                                        [self currentBrushName],
                                                        _drawingView.lineWidth,
                                                        (int)(_drawingView.globalOpacity*100.0f)]
                                              delegate:self
                                     cancelButtonTitle:@"Kapat"
                                     otherButtonTitles:(fav?@"★ Favoriden Çıkar":@"☆ Favoriye Ekle"),
                                                       @"Favori Fırçalar",
                                                       @"Son Kullanılanlar",
                                                       nil] autorelease];
    a.tag=646;
    [a show];
}

- (NSString *)thumbnailCacheDirectory
{
    NSArray *dirs=NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *d=[[dirs objectAtIndex:0] stringByAppendingPathComponent:@"KidsDrawThumbs"];
    [[NSFileManager defaultManager] createDirectoryAtPath:d withIntermediateDirectories:YES attributes:nil error:NULL];
    return d;
}

- (NSString *)thumbnailPathForDrawing:(NSString *)path
{
    NSString *name=[[[path lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"-160x120.jpg"];
    return [[self thumbnailCacheDirectory] stringByAppendingPathComponent:name];
}

- (UIImage *)cachedThumbnailForPath:(NSString *)path size:(CGSize)s
{
    NSString *tp=[self thumbnailPathForDrawing:path];
    UIImage *cached=[UIImage imageWithContentsOfFile:tp];
    if(cached) return cached;

    UIImage *im=[UIImage imageWithContentsOfFile:path];
    if(!im) return nil;
    UIImage *thumb=[self thumbnailForImage:im size:s];
    NSData *jpg=UIImageJPEGRepresentation(thumb,0.65f);
    [jpg writeToFile:tp atomically:YES];
    return thumb;
}

- (NSArray *)filteredGalleryPaths
{
    NSArray *all=[self galleryPaths];
    if(_galleryFilter==1){
        NSMutableArray *fav=[NSMutableArray array];
        NSString *p;
        for(p in all) if([_favoriteDrawings containsObject:p]) [fav addObject:p];
        return fav;
    }
    if(_galleryFilter==2){
        NSInteger max=MIN((NSInteger)[all count],10);
        return [all subarrayWithRange:NSMakeRange(0,max)];
    }
    return all;
}

- (void)setGalleryFilter:(UIButton *)sender
{
    _galleryFilter=sender.tag-920;
    [self showGallery];
}

- (void)toolPressed:(UIButton *)s
{
    switch(s.tag){
        case 201:[self chooseBrush];break;
        case 202:[self cycleLineSize:s];[self showCurrentBrushPreview];break;
        case 203:[self cycleSprayDensity:s];break;
        case 204:[self cycleNeonStrength:s];break;
        case 205:[self cycleSpraySize:s];break;
        case 206:[self cycleOpacity:s];[self showCurrentBrushPreview];break;
        case 207:[self chooseSecondaryPen];break;
        case 208:[self chooseCustomColor];break;
        case 209:[self cycleSmudgeStrength:s];break;
        case 210:[self cycleMixerStrength:s];break;
        case 211:[self activateEyedropper];break;
        case 212:[self cycleStampRotation:s];break;
        case 213:[self chooseAdvancedColor];break;
        case 214:[self showToolInfoMenu];break;
        case 215:[self cycleSmoothing:s];break;

        case 301:[_drawingView undo];break;
        case 302:[_drawingView redo];break;
        case 303:
            _drawingView.bucketMode=YES; _drawingView.stampType=KidsStampNone;
            _drawingView.shapeType=KidsShapeNone; _drawingView.strokeColor=_lastPaintColor;
            break;
        case 304:
            [self cycleEraserSize];
            _drawingView.bucketMode=NO; _drawingView.stampType=KidsStampNone;
            _drawingView.shapeType=KidsShapeNone; _drawingView.brushStyle=KidsBrushNormal;
            _drawingView.lineWidth=_drawingView.eraserWidth; _drawingView.strokeColor=_drawingView.canvasColor;
            break;
        case 305:[self chooseStamp];break;
        case 306:[self cycleStampSize:s];break;
        case 307:[self chooseColoringPage];break;
        case 308:[self chooseShape];break;
        case 309:
            _drawingView.mirrorMode=!_drawingView.mirrorMode;
            [s setTitle:(_drawingView.mirrorMode?@"Simetri ✓":@"Simetri") forState:UIControlStateNormal];
            break;
        case 310:[self promptText];break;
        case 311:[self playReplay];break;
        case 312:[self showRewards];break;
        case 313:[self toggleSound];break;
        case 314:[self confirmClear];break;
        case 315:[self showGallery];break;
        case 316:[self saveDrawing];break;
        default:break;
    }
}

- (void)chooseStamp
{
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Damga Kategorisi" message:@"Bir kategori seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Temel",@"Doğa",@"Eğlence",@"Nesneler",nil] autorelease];
    a.tag=650; [a show];
}
- (void)showStampCategory:(NSInteger)c
{
    NSArray *titles=nil;
    if(c==0) titles=[NSArray arrayWithObjects:@"Yıldız",@"Kalp",@"Gülen",@"Daire",@"Kare",@"Üçgen",nil];
    else if(c==1) titles=[NSArray arrayWithObjects:@"Çiçek",@"Güneş",@"Bulut",@"Balık",@"Kelebek",@"Ağaç",nil];
    else if(c==2) titles=[NSArray arrayWithObjects:@"Ay",@"Balon",@"Kedi",@"Robot",@"Taç",@"Müzik",nil];
    else titles=[NSArray arrayWithObjects:@"Araba",@"Elmas",@"Elma",@"Ev",@"Roket",@"Şimşek",nil];

    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Damgalar" message:@"Bir damga seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:nil] autorelease];
    NSInteger i; for(i=0;i<[titles count];i++) [a addButtonWithTitle:[titles objectAtIndex:i]];
    a.tag=660+c; [a show];
}
- (KidsStampType)stampForCategory:(NSInteger)c item:(NSInteger)item
{
    static const NSInteger map[4][6]={
        {1,2,3,4,5,6},
        {7,8,9,11,12,17},
        {13,15,20,21,22,23},
        {10,14,16,18,19,24}
    };
    if(c<0||c>3||item<0||item>5) return KidsStampNone;
    return (KidsStampType)map[c][item];
}

- (void)chooseColoringPage
{
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Boyama Kategorisi" message:@"Bir kategori seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Doğa",@"Hayvanlar",@"Araçlar",@"Eğlence",nil] autorelease];
    a.tag=670; [a show];
}
- (void)showColoringCategory:(NSInteger)c
{
    NSArray *titles=nil;
    if(c==0) titles=[NSArray arrayWithObjects:@"Çiçek",@"Ağaç",@"Güneş",@"Mantar",@"Kalp",@"Yaprak",@"Dağ",@"Bulut",@"Gökkuşağı",@"Bahçe",nil];
    else if(c==1) titles=[NSArray arrayWithObjects:@"Balık",@"Kelebek",@"Kedi",@"Kaplumbağa",@"Kuş",@"Tavşan",@"Balina",@"Köpek",@"Arı",@"Uğur Böceği",nil];
    else if(c==2) titles=[NSArray arrayWithObjects:@"Araba",@"Roket",@"Gemi",@"Tren",@"Uçurtma",@"Otobüs",@"Uçak",@"Bisiklet",@"Kamyon",@"Helikopter",nil];
    else titles=[NSArray arrayWithObjects:@"Ev",@"Robot",@"Dondurma",@"Şemsiye",@"Hediye",@"Kale",@"Balon",@"Yıldız",@"Taç",@"Oyuncak",nil];

    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Boyama" message:@"Bir resim seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:nil] autorelease];
    NSInteger i; for(i=0;i<[titles count];i++) [a addButtonWithTitle:[titles objectAtIndex:i]];
    a.tag=680+c; [a show];
}
- (NSInteger)templateForCategory:(NSInteger)c item:(NSInteger)item
{
    static const NSInteger map[4][10]={
        {0,7,8,13,19,20,21,22,23,24},
        {2,3,6,14,18,25,26,27,28,29},
        {4,5,10,15,12,30,31,32,33,34},
        {1,9,11,16,17,35,36,37,38,39}
    };
    if(c<0||c>3||item<0||item>9) return 0;
    return map[c][item];
}

- (void)chooseShape { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Şekil" message:@"Çizmek istediğin şekli seç." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Çizgi",@"Dikdörtgen",@"Daire/Oval",@"Üçgen",nil] autorelease];a.tag=620;[a show]; }
- (void)promptText { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Yazı Ekle" message:@"Yazını gir." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Ekle",nil] autorelease];a.alertViewStyle=UIAlertViewStylePlainTextInput;a.tag=621;[a show]; }
- (void)confirmClear { UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Resmi temizle?" message:@"Bütün çizim silinecek." delegate:self cancelButtonTitle:@"Vazgeç" otherButtonTitles:@"Temizle",nil] autorelease];a.tag=501;[a show]; }

- (void)alertView:(UIAlertView *)a clickedButtonAtIndex:(NSInteger)i
{
    if(a.tag==646){
        if(i==1){ [self toggleFavoriteBrush]; return; }
        if(i==2){ [self showBrushList:_favoriteBrushes title:@"Favori Fırçalar" tag:647]; return; }
        if(i==3){ [self showBrushList:_recentBrushes title:@"Son Kullanılanlar" tag:648]; return; }
    }
    if((a.tag==647||a.tag==648)&&i>=1){
        NSArray *arr=(a.tag==647)?_favoriteBrushes:_recentBrushes;
        NSInteger idx=i-1;
        if(idx>=0&&idx<[arr count]){
            _drawingView.brushStyle=(KidsBrushStyle)[[arr objectAtIndex:idx] integerValue];
            [self selectPaintMode];
            [self rememberBrushStyle:_drawingView.brushStyle];
            [self showCurrentBrushPreview];
        }
        return;
    }
    if(a.tag==644&&i>=1&&i<=6){ [self showColorFamily:i-1]; return; }
    if(a.tag>=645&&a.tag<=650&&i>=1&&i<=4){
        UIColor *c=[self advancedColorForFamily:a.tag-645 item:i-1];
        [_lastPaintColor release];
        _lastPaintColor=[c retain];
        _drawingView.strokeColor=c;
        [self showBrushPreviewWithText:@"Renk seçildi"];
        return;
    }
    if(a.tag==641&&i>=1&&i<=8){
        UIColor *c=nil; KidsBrushStyle b=KidsBrushNormal;
        switch(i){
            case 1:c=[UIColor blueColor];b=KidsBrushNormal;break;
            case 2:c=[UIColor redColor];b=KidsBrushNormal;break;
            case 3:c=[UIColor greenColor];b=KidsBrushNormal;break;
            case 4:c=[self colorWithR:145 g:70 b:210];b=KidsBrushNormal;break;
            case 5:c=[UIColor blueColor];b=KidsBrushNeon;break;
            case 6:c=[UIColor redColor];b=KidsBrushNeon;break;
            case 7:c=[UIColor blueColor];b=KidsBrushSpray;break;
            case 8:c=[UIColor greenColor];b=KidsBrushSpray;break;
        }
        [_secondaryPaintColor release];
        _secondaryPaintColor=[c retain];
        _drawingView.secondaryStrokeColor=c;
        _drawingView.secondaryBrushStyle=b;
        return;
    }
    if(a.tag==642&&i>=1&&i<=8){
        NSArray *custom=[NSArray arrayWithObjects:
            [self colorWithR:30 g:200 b:190],
            [self colorWithR:220 g:240 b:40],
            [self colorWithR:245 g:110 b:90],
            [self colorWithR:190 g:150 b:240],
            [self colorWithR:140 g:235 b:190],
            [self colorWithR:25 g:45 b:110],
            [self colorWithR:235 g:185 b:40],
            [self colorWithR:220 g:80 b:120],nil];
        UIColor *c=[custom objectAtIndex:i-1];
        [_lastPaintColor release]; _lastPaintColor=[c retain];
        _drawingView.strokeColor=c;
        return;
    }
    if(a.tag==640){
        if(i>=1&&i<=4){
            [self selectPaintMode];
            _drawingView.brushStyle=(KidsBrushStyle)(i-1);
            [self rememberBrushStyle:_drawingView.brushStyle];
            [self playTinySound];
            return;
        }
        if(i==5){
            [self chooseEffectBrush];
            return;
        }
    }
    if(a.tag==643&&i>=1&&i<=7){
        [self selectPaintMode];
        /* 4=Fosfor,5=Gökkuşağı,6=Sprey,7=Tebeşir,8=Smudge,9=Mixer,10=Watercolor */
        _drawingView.brushStyle=(KidsBrushStyle)(i+3);
        [self rememberBrushStyle:_drawingView.brushStyle];
        [self playTinySound];
        return;
    }
    if(a.tag==650&&i>=1&&i<=4){[self showStampCategory:i-1];return;}
    if(a.tag>=660&&a.tag<=663&&i>=1&&i<=6){
        KidsStampType st=[self stampForCategory:a.tag-660 item:i-1];
        if(![self isStampUnlocked:st]){
            UIAlertView *lock=[[[UIAlertView alloc] initWithTitle:@"Kilitli" message:@"Bu damga için biraz daha yıldız kazanmalısın." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
            [lock show]; return;
        }
        [self selectPaintMode]; _drawingView.stampType=st; [self playTinySound]; return;
    }
    if(a.tag==670&&i>=1&&i<=4){[self showColoringCategory:i-1];return;}
    if(a.tag>=680&&a.tag<=683&&i>=1&&i<=10){
        NSInteger t=[self templateForCategory:a.tag-680 item:i-1];
        [_drawingView showColoringTemplate:t];
        [self playTinySound];
        [self showColorHintForTemplate:t];
        return;
    }

    if(a.tag==501&&i==1)[_drawingView clearCanvas];
    else if(a.tag==605&&i>=1&&i<=5)[_drawingView showColoringTemplate:14+i];
    else if(a.tag==620&&i>=1&&i<=4){[self selectPaintMode];_drawingView.shapeType=(KidsShapeType)i;}
    else if(a.tag==621&&i==1){NSString *text=[[a textFieldAtIndex:0] text];[_drawingView addText:text];}
}



- (void)playTinySound
{
    if(!_soundEnabled) return;
    AudioServicesPlaySystemSound(1104);
}

- (void)toggleSound
{
    _soundEnabled=!_soundEnabled;
    [[NSUserDefaults standardUserDefaults] setBool:_soundEnabled forKey:@"KidsDrawSoundEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIButton *b=(UIButton *)[self.view viewWithTag:313];
    [b setTitle:(_soundEnabled?@"Ses ✓":@"Ses ×") forState:UIControlStateNormal];
    if(_soundEnabled) [self playTinySound];
}

- (void)showRewards
{
    if(_rewardOverlay){[_rewardOverlay removeFromSuperview];[_rewardOverlay release];_rewardOverlay=nil;}

    _rewardOverlay=[[UIView alloc] initWithFrame:self.view.bounds];
    _rewardOverlay.backgroundColor=[UIColor colorWithWhite:0.97f alpha:0.98f];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(40,40,self.view.bounds.size.width-80,60)] autorelease];
    title.backgroundColor=[UIColor clearColor];
    title.textAlignment=UITextAlignmentCenter;
    title.font=[UIFont boldSystemFontOfSize:28.0f];
    title.text=[NSString stringWithFormat:@"Ödüllerin  ★ %u",(unsigned int)_stars];
    [_rewardOverlay addSubview:title];

    NSArray *names=[NSArray arrayWithObjects:@"Taç",@"Roket",@"Robot",@"Kelebek",@"Elmas",@"Müzik",nil];
    NSInteger thresholds[]={10,20,30,40,50,60};
    NSInteger i;
    for(i=0;i<6;i++){
        UILabel *l=[[[UILabel alloc] initWithFrame:CGRectMake(120,120+i*62,self.view.bounds.size.width-240,48)] autorelease];
        l.backgroundColor=[UIColor clearColor];
        l.font=[UIFont boldSystemFontOfSize:20.0f];
        BOOL unlocked=_stars>=(NSUInteger)thresholds[i];
        l.text=[NSString stringWithFormat:@"%@  %@  (%d ★)",
                unlocked?@"✓":@"🔒",[names objectAtIndex:i],thresholds[i]];
        [_rewardOverlay addSubview:l];
    }

    UIButton *close=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    close.frame=CGRectMake(self.view.bounds.size.width-150,24,120,44);
    [close setTitle:@"Kapat" forState:UIControlStateNormal];
    close.tag=901;
    [close addTarget:self action:@selector(closeRewards) forControlEvents:UIControlEventTouchUpInside];
    [_rewardOverlay addSubview:close];

    [self.view addSubview:_rewardOverlay];
}

- (void)closeRewards
{
    [_rewardOverlay removeFromSuperview];
    [_rewardOverlay release];
    _rewardOverlay=nil;
}

- (BOOL)isStampUnlocked:(KidsStampType)t
{
    if(t==KidsStampCrown) return _stars>=10;
    if(t==KidsStampRocket) return _stars>=20;
    if(t==KidsStampRobot) return _stars>=30;
    if(t==KidsStampButterfly) return _stars>=40;
    if(t==KidsStampDiamond) return _stars>=50;
    if(t==KidsStampMusic) return _stars>=60;
    return YES;
}

- (void)showColorHintForTemplate:(NSInteger)t
{
    NSString *hint=@"İstediğin renkleri kullanabilirsin!";
    switch(t){
        case 0: hint=@"Çiçeği kırmızı, sarı veya pembe deneyebilirsin."; break;
        case 2: hint=@"Balıkta mavi, turuncu ve sarı güzel durur."; break;
        case 4: hint=@"Arabayı sevdiğin renge boya."; break;
        case 5: hint=@"Rokette kırmızı, mavi ve sarı deneyebilirsin."; break;
        case 6: hint=@"Kediyi turuncu, gri veya mor deneyebilirsin."; break;
        case 7: hint=@"Ağaç için yeşil ve kahverengi güzel olur."; break;
        default: break;
    }
    UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Renk Önerisi" message:hint delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
    [a show];
}

- (void)updateStarLabel
{
    _starLabel.text=[NSString stringWithFormat:@"★ %u",(unsigned int)_stars];
}


- (UIImage *)replayThumbnail
{
    UIImage *im=[_drawingView renderedImage];
    if(!im) return nil;
    CGSize s=CGSizeMake(256.0f,192.0f);
    UIGraphicsBeginImageContext(s);
    [[UIColor whiteColor] setFill]; UIRectFill(CGRectMake(0,0,s.width,s.height));
    CGFloat scale=MIN(s.width/im.size.width,s.height/im.size.height);
    CGSize z=CGSizeMake(im.size.width*scale,im.size.height*scale);
    [im drawInRect:CGRectMake((s.width-z.width)/2.0f,(s.height-z.height)/2.0f,z.width,z.height)];
    UIImage *out=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return out;
}

- (void)captureReplayFrame
{
    UIImage *thumb=[self replayThumbnail];
    if(!thumb) return;
    [_replayFrames addObject:thumb];
    while([_replayFrames count]>18) [_replayFrames removeObjectAtIndex:0];
}

- (void)playReplay
{
    if([_replayFrames count]<2){
        UIAlertView *a=[[[UIAlertView alloc] initWithTitle:@"Oynatma" message:@"Oynatmak için biraz daha çizim yap." delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];
        [a show]; return;
    }
    if(_replayTimer){[_replayTimer invalidate];[_replayTimer release];_replayTimer=nil;}
    if(_replayOverlay){[_replayOverlay removeFromSuperview];[_replayOverlay release];_replayOverlay=nil;}

    _replayOverlay=[[UIImageView alloc] initWithFrame:_drawingView.frame];
    _replayOverlay.backgroundColor=[UIColor whiteColor];
    _replayOverlay.contentMode=UIViewContentModeScaleAspectFit;
    _replayOverlay.userInteractionEnabled=NO;
    [self.view addSubview:_replayOverlay];

    _replayIndex=0;
    _replayTimer=[[NSTimer scheduledTimerWithTimeInterval:0.22 target:self selector:@selector(replayTick:) userInfo:nil repeats:YES] retain];
}

- (void)replayTick:(NSTimer *)timer
{
    if(_replayIndex>=(NSInteger)[_replayFrames count]){
        [_replayTimer invalidate]; [_replayTimer release]; _replayTimer=nil;
        [_replayOverlay removeFromSuperview]; [_replayOverlay release]; _replayOverlay=nil;
        return;
    }
    _replayOverlay.image=[_replayFrames objectAtIndex:_replayIndex++];
}

- (void)addRewardStar
{
    _stars++;
    [self playTinySound];
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)_stars forKey:@"KidsDrawStars"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateStarLabel];
}

- (NSString *)autosavePath
{
    NSArray *dirs=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    return [[dirs objectAtIndex:0] stringByAppendingPathComponent:@"KidsDraw-Autosave.png"];
}
- (void)canvasChanged:(NSNotification *)n
{
    [self captureReplayFrame];
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
    if(_galleryOverlay) [_galleryOverlay removeFromSuperview];
    [_galleryOverlay release];
    _galleryOverlay=[[UIView alloc] initWithFrame:self.view.bounds];
    _galleryOverlay.backgroundColor=[UIColor colorWithWhite:.12 alpha:.96];

    UIButton *close=[self textButton:@"Kapat" tag:900];
    close.frame=CGRectMake(16,12,82,42);
    [close addTarget:self action:@selector(closeGallery) forControlEvents:UIControlEventTouchUpInside];
    [_galleryOverlay addSubview:close];

    UILabel *title=[[[UILabel alloc] initWithFrame:CGRectMake(112,12,260,42)] autorelease];
    title.backgroundColor=[UIColor clearColor];
    title.textColor=[UIColor whiteColor];
    title.font=[UIFont boldSystemFontOfSize:22];
    title.text=@"Çizimlerim";
    [_galleryOverlay addSubview:title];

    NSArray *filterTitles=[NSArray arrayWithObjects:@"Tümü",@"★ Favoriler",@"Son 10",nil];
    NSInteger fi;
    for(fi=0;fi<3;fi++){
        UIButton *f=[self textButton:[filterTitles objectAtIndex:fi] tag:920+fi];
        f.frame=CGRectMake(390+fi*120,12,112,42);
        [f addTarget:self action:@selector(setGalleryFilter:) forControlEvents:UIControlEventTouchUpInside];
        [_galleryOverlay addSubview:f];
    }

    [self.view addSubview:_galleryOverlay];

    [_galleryFiles release];
    _galleryFiles=[[self filteredGalleryPaths] retain];

    if([_galleryFiles count]==0){
        UILabel *e=[[[UILabel alloc] initWithFrame:CGRectMake(0,250,self.view.bounds.size.width,60)] autorelease];
        e.backgroundColor=[UIColor clearColor];
        e.textColor=[UIColor whiteColor];
        e.textAlignment=UITextAlignmentCenter;
        e.font=[UIFont boldSystemFontOfSize:22];
        e.text=@"Bu klasörde henüz çizim yok.";
        [_galleryOverlay addSubview:e];
        return;
    }

    UIScrollView *scroll=[[[UIScrollView alloc] initWithFrame:CGRectMake(20,70,self.view.bounds.size.width-40,self.view.bounds.size.height-90)] autorelease];
    [_galleryOverlay addSubview:scroll];

    CGFloat tw=160,th=120,g=22;
    int cols=5;
    NSInteger i,max=MIN((NSInteger)[_galleryFiles count],30);
    for(i=0;i<max;i++){
        NSString *path=[_galleryFiles objectAtIndex:i];
        UIButton *b=[UIButton buttonWithType:UIButtonTypeCustom];
        b.frame=CGRectMake((i%cols)*(tw+g),(i/cols)*(th+g),tw,th);
        UIImage *thumb=[self cachedThumbnailForPath:path size:CGSizeMake(tw,th)];
        if(thumb) [b setImage:thumb forState:UIControlStateNormal];
        b.tag=1000+i;
        [b addTarget:self action:@selector(openGalleryImage:) forControlEvents:UIControlEventTouchUpInside];

        if([_favoriteDrawings containsObject:path]){
            UILabel *star=[[[UILabel alloc] initWithFrame:CGRectMake(tw-34,4,30,28)] autorelease];
            star.backgroundColor=[UIColor colorWithWhite:0 alpha:.45];
            star.textColor=[UIColor yellowColor];
            star.text=@"★";
            star.textAlignment=UITextAlignmentCenter;
            star.font=[UIFont boldSystemFontOfSize:20];
            [b addSubview:star];
        }
        [scroll addSubview:b];
    }
    scroll.contentSize=CGSizeMake(scroll.bounds.size.width,((max+cols-1)/cols)*(th+g));
}
- (void)closeGallery { [_galleryOverlay removeFromSuperview];[_galleryOverlay release];_galleryOverlay=nil;[_galleryFiles release];_galleryFiles=nil; }
- (void)openGalleryImage:(UIButton *)b { NSInteger i=b.tag-1000;if(i>=0&&i<[_galleryFiles count]){NSString *path=[_galleryFiles objectAtIndex:i];UIImage *im=[UIImage imageWithContentsOfFile:path];[_drawingView setRenderedImage:im];[[NSUserDefaults standardUserDefaults] setObject:path forKey:@"KidsDrawCurrentGalleryPath"];[self closeGallery];} }

- (void)saveDrawing
{
    [self addRewardStar];
    UIImage *im=[_drawingView renderedImage]; NSDateFormatter *f=[[[NSDateFormatter alloc] init] autorelease];[f setDateFormat:@"yyyyMMdd-HHmmss"];NSString *name=[NSString stringWithFormat:@"KidsDraw-%@.png",[f stringFromDate:[NSDate date]]];NSString *path=[[self galleryDirectory] stringByAppendingPathComponent:name];[UIImagePNGRepresentation(im) writeToFile:path atomically:YES];[[NSUserDefaults standardUserDefaults] setObject:path forKey:@"KidsDrawCurrentGalleryPath"]; UIImageWriteToSavedPhotosAlbum(im,self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo { NSString *t=error?@"Galeriye kaydedildi":@"Kaydedildi";NSString *m=error?@"KidsDraw Çizimlerim'e kaydedildi; Fotoğraflar'a eklenemedi.":@"Resim Çizimlerim'e ve Fotoğraflar'a kaydedildi.";UIAlertView *a=[[[UIAlertView alloc] initWithTitle:t message:m delegate:nil cancelButtonTitle:@"Tamam" otherButtonTitles:nil] autorelease];[a show]; }
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)o { return UIInterfaceOrientationIsLandscape(o); }
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self];if(_autosaveTimer){[_autosaveTimer invalidate];[_autosaveTimer release];}if(_replayTimer){[_replayTimer invalidate];[_replayTimer release];}[_replayOverlay removeFromSuperview];[_replayOverlay release];[_replayFrames release];[_rewardOverlay removeFromSuperview];[_rewardOverlay release];[_secondaryPaintColor release];[_stampPinch release];[_brushPreviewLabel release];[_brushPreview release];[_favoriteDrawings release];[_favoriteBrushes release];[_recentBrushes release];[_starLabel release];[_drawingView release];[_topToolbar release];[_bottomToolbar release];[_galleryOverlay release];[_galleryFiles release];[_lastPaintColor release];[super dealloc]; }
@end
