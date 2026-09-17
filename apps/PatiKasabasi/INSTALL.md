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
  packages/com.olapteknoloji.patikasabasi_0.5.0-alpha5_iphoneos-arm.deb \
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
dpkg -i /var/mobile/com.olapteknoloji.patikasabasi_0.5.0-alpha5_iphoneos-arm.deb
uicache
killall -9 SpringBoard
```

## 5. Fiziksel test

`TESTING.md` içindeki tüm senaryoları uygula. Özellikle Ev/oda/okul/park/meydan sürüklemelerini, görsel sahneleri, okulun `Evimiz` düğmesini, hayvan yatağını, hareketlerin ekran geçişinde durmasını, eski kayıt geçişini ve 15 dakikalık ekran dolaşımını gerçek iPad 1 üzerinde doğrula. Cihazda görülmeyen davranış doğrulanmış kabul edilmez.
