# iPad1Files

iPad1Files is a lightweight shared file manager and common storage foundation for jailbroken iPad 1 devices running iOS 5.1.1.

## Goal

Provide one common filesystem layer for the iPad1 application family:

- iPad1PDFReader
- iPad1FTPDownloader
- iPad1VNC
- future iPad1Media / iPad1Archive / iPad1Browser tools

## Shared storage

The application creates:

```text
/var/mobile/Media/iPad1Files/
├── Downloads/
├── Documents/
├── PDFs/
├── Images/
├── Music/
├── Videos/
├── Archives/
├── Shared/
├── Temp/
└── AppData/
```

## v1.0.0-alpha1 features

- Directory browser
- Folder-first sorting
- Create folder
- Rename
- Delete
- File information
- Current-folder search
- Show/hide hidden files
- Text preview
- Image preview with zoom
- PDF hand-off hook through `ipad1pdf://`
- Common `iPad1FilesKit` headers
- Shared storage bootstrap
- File type detection
- Recursive size calculation
- Copy/move APIs with collision-safe destination names
- URL scheme: `ipad1files://`

## Build

Requires a Theos toolchain capable of targeting iOS 5.1.

```bash
make clean
make package FINALPACKAGE=1
```

To deploy to the iPad:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    packages/com.olap.ipad1files_1.0.0-alpha1_iphoneos-arm.deb \
    root@192.168.1.2:/var/mobile/
```

On the iPad:

```bash
ssh -o HostKeyAlgorithms=+ssh-rsa \
    -o PubkeyAcceptedAlgorithms=+ssh-rsa \
    root@192.168.1.2

dpkg -i /var/mobile/com.olap.ipad1files_1.0.0-alpha1_iphoneos-arm.deb
killall SpringBoard
```

## Integration example

Any iPad1 application can use the same path contract:

```objc
NSString *pdfFolder = @"/var/mobile/Media/iPad1Files/PDFs";
```

Or, when the shared kit is embedded:

```objc
#import "iPad1FilesKit.h"

NSArray *pdfs = [[IP1FileManager sharedManager]
    filesWithExtension:@"pdf"
    underPath:[[IP1SharedStorage sharedStorage] rootPath]];
```

## PDF Reader URL contract

iPad1Files attempts to launch:

```text
ipad1pdf://open?path=<percent-encoded-path>
```

The PDF reader must add the `ipad1pdf` URL scheme and parse the `path` parameter for this integration to become active.

## Status

`1.0.0-alpha1` is the first implementation scaffold. It is intentionally conservative for iPad 1 memory and iOS 5 compatibility.
