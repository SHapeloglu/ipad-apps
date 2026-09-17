# Derleme ve iPad'e Kurulum

## 1. Legacy Theos ortamı

```bash
cd ~/projects/PatiKasabasi
```

Theos, iPhoneOS 6.1 SDK ve armv7 toolchain daha önceki iPad 1 projeleriyle aynı biçimde hazır olmalıdır.

## 2. Doğrula ve derle

```bash
./scripts/validate_project.sh
make clean
FINALPACKAGE=1 make package
```

Başarılı derlemeden sonra:

```bash
ls -lh packages/
```

## 3. Paketi gönder

`IPAD_IP` yerine cihazın adresini yaz:

```bash
scp \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  packages/com.olapteknoloji.patikasabasi_0.3.0-alpha3_iphoneos-arm.deb \
  root@IPAD_IP:/var/mobile/
```

## 4. Cihazda kur

```bash
ssh \
  -o HostKeyAlgorithms=+ssh-rsa \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  root@IPAD_IP
```

iPad terminalinde:

```bash
dpkg -i /var/mobile/com.olapteknoloji.patikasabasi_0.3.0-alpha3_iphoneos-arm.deb
uicache
killall -9 SpringBoard
```

## 5. Fiziksel test

`TESTING.md` içindeki tüm senaryoları uygula. Özellikle 0.1/0.2 kayıt geçişini, dolap ve oda dokunmalarını, 12 görev döngüsünü, fotoğraf belleğini ve 15 dakikalık ekran dolaşımını gerçek iPad 1 üzerinde doğrula. Cihazda görülmeyen davranış doğrulanmış kabul edilmez.
