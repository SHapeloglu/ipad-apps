# iPad 1 PDF Reader v2.0.0

Hedef: iPad 1 / iOS 5.1.1. Theos + iPhoneOS 6.1 legacy SDK.

## Eklenenler
- Swipe ile sayfa değiştirme
- Tek dokunma ile toolbar/navigation gizleme
- Thumbnail sayfa listesi
- Sayfaya git
- Normal / Sepia / Gece modu
- Favori ve yeniden adlandırma
- HTTP / FTP indirme
- Open In ile PDF alma
- PDF Outline başlıklarını listeleme
- Basit ham PDF metin araması
- Serbest çizim, highlight, not, yazılı imza
- Annotation temizleme
- Sayfa dışa aktarma altyapısı (PageManager)

## Bilinçli sınırlamalar
- Annotation'lar orijinal PDF içine gömülmez; yan veri olarak tutulur.
- Arama, Core Graphics'in metin çıkarma API'si olmadığı için basit ham-PDF taramasıdır; sıkıştırılmış/font-encoded PDF'lerde sonuç vermeyebilir.
- Outline başlıkları gösterilir; karmaşık destination çözümlemesi tam değildir.
- AcroForm alanlarını gerçek PDF nesneleri olarak düzenleme yoktur.
- Gece modu hafif render temasıdır; tam renk invert değildir.

## Derleme
```bash
cd ~/projects/ipad1pdfreader/iPad1PDFReader-v2.0.0
make clean
rm -rf .theos
make package FINALPACKAGE=1
```
