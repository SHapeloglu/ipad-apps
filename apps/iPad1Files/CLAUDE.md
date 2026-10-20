# CLAUDE.md

Hard rules: iPad 1, 256 MB, iOS 5.1.1, armv7, Theos, Objective-C, non-ARC/MRC, no modern-only APIs.

iPad1Files = local file management + shared storage + Open With.

Canonical root:
```text
/var/mobile/Media/iPad1Files
```

`IP1AppRegistry` mapping authority; `IP1AppLauncher` absolute-path hand-off.

Do not add FTP/SFTP/SMB/WebDAV engines, PDF engine features, OCR, AI/ML, background indexer.

Read SESSION/ARCHITECTURE/INTEGRATION/TESTING/TASKS/AGENTS first.
