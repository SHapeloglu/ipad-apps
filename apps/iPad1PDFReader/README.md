# iPad 1 PDF Reader v3.1.0 — Memory Safe

Hedef cihaz değişmez:

- iPad 1
- 256 MB RAM
- A4
- iOS 5.1.1

## Mimari kurallar

1. PDF tamamen bitmap'e çevrilmez.
2. Reader aynı anda yalnızca aktif sayfayı render eder.
3. Thumbnail üretimi yalnızca görünür hücrelerde yapılır.
4. Thumbnail cache en fazla 8 küçük görsel tutar.
5. Memory warning geldiğinde thumbnail ve search sonuç cache'i temizlenir.
6. Search PDF'i sayfa sayfa tarar ve maksimum 40 sonuç tutar.
7. Reflow artık tüm belgeyi tek NSString'e yüklemez; tek sayfa yükler.
8. OCR cihaz üzerinde yapılmaz.
9. Ağ indirmeleri streaming/connection mantığında tutulur.
10. Ağır animasyon, blur ve yüksek çözünürlüklü çoklu page cache kullanılmaz.

## RAM hedefi

- Normal okuma: yaklaşık 30–50 MB hedef
- Thumbnail / arama / reflow: mümkün olduğunca 70–90 MB altında
- Bu değerler garanti değil; PDF sayfa boyutu ve iOS durumuna göre değişebilir.

## Özellik yaklaşımı

Yeşil:
- bookmark
- tek sayfa render
- annotation
- HTTP/FTP/WebDAV
- page management

Sarı:
- thumbnail
- search
- reflow
- SMB/SFTP

Kırmızı:
- cihaz içi OCR
- AI
- tüm PDF'yi RAM'e alan motor
- yüksek çözünürlüklü çoklu bitmap cache

## Build

```bash
cd ~/projects/ipad1pdfreader-v31/iPad1PDFReader-v3.1.0-memorysafe
make clean
rm -rf .theos
make package FINALPACKAGE=1
```

Beklenen:
`packages/com.olap.ipad1pdfreader_3.1.0_iphoneos-arm.deb`
