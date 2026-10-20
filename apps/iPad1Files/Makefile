ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1Files
iPad1Files_FILES = \
	src/main.m \
	src/AppDelegate.m \
	src/IP1FileItem.m \
	src/IP1FileTypeDetector.m \
	src/IP1SharedStorage.m \
	src/IP1FileManager.m \
	src/IP1AppLauncher.m \
	src/IP1FavoritesManager.m \
	src/IP1DiskInfo.m \
	src/IP1AppRegistry.m \
	src/ArchiveManager.m \
	src/ArchiveViewController.m \
	src/minizip/ioapi.c \
	src/minizip/unzip.c \
	src/minizip/zip.c \
	src/FolderPickerViewController.m \
	src/FavoritesViewController.m \
	src/FileBrowserViewController.m \
	src/FileInfoViewController.m \
	src/TextViewerViewController.m \
	src/ImageViewerViewController.m

iPad1Files_FRAMEWORKS = UIKit Foundation CoreGraphics
iPad1Files_LIBRARIES = z
iPad1Files_CFLAGS = -fno-objc-arc -Wall -Wextra -Wno-deprecated-declarations -DUSE_FILE32API -DNOCRYPT -Wno-unused-parameter -Wno-parentheses-equality -Wno-misleading-indentation
iPad1Files_LDFLAGS = -Wl,-dead_strip
iPad1Files_RESOURCE_DIRS = Resources

include $(THEOS_MAKE_PATH)/application.mk
