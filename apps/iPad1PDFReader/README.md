# iPad 1 PDF Reader v3.0.0

iPad 1 / iOS 5.1.1 için gelişmiş hafif PDF okuyucu.

Eklenenler:
- CGPDFScanner tabanlı içerik-akışı metin arama
- Reflow okuma modu
- WebDAV istemci altyapısı
- HTTP/HTTPS/FTP ağ merkezi
- SMB/SFTP connector yuvaları (harici libsmb2/libssh2 gerekir)
- Sayfa silme, sıralama, döndürme ve yeni PDF üretme
- PDF birleştirme API
- Annotation'ları flatten ederek kalıcı PDF dışa aktarma
- Thumbnail, bookmark, tema, Open In, File Sharing

Sınırlar:
- Search/Reflow bazı özel font encoding kullanan PDF'lerde eksik olabilir.
- Annotation export görünür ve kalıcıdır ama Acrobat tarzı düzenlenebilir /Annots nesnesi değildir.
- SMB/SFTP iOS 5'te yerleşik olmadığından harici kütüphane olmadan aktif değildir.

Derleme:
make clean
rm -rf .theos
make package FINALPACKAGE=1
