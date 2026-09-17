# Architecture

## Principles

1. iOS 5.1.1 first.
2. No ARC.
3. Minimal framework dependencies.
4. Common files live under `/var/mobile/Media/iPad1Files`.
5. Application-specific metadata belongs under `AppData/<ApplicationName>`.
6. File operations are isolated behind `IP1FileManager`.
7. App-to-app opening uses URL schemes instead of private UIKit APIs.

## Components

### IP1SharedStorage
Defines and creates the common directory structure.

### IP1FileManager
Wraps NSFileManager for browse, create, rename, delete, copy, move, recursive search and size operations.

### IP1FileItem
Small metadata object for table rendering.

### IP1FileTypeDetector
Maps legacy-friendly filename extensions into application file categories.

### IP1AppLauncher
Central place for app URL schemes. First integration target is iPad1PDFReader.

### FileBrowserViewController
Main UI. Uses UITableView, UISearchBar, UIAlertView and UIActionSheet because they are available on iOS 5.

## Future

- clipboard-style copy/move UI
- multi-select operations
- favorites
- HTTP download manager
- FTP/SFTP/WebDAV
- ZIP
- SMB
- media preview
- per-app registration database
