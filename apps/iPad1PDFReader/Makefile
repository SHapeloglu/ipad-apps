ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1PDFReader

iPad1PDFReader_FILES = \
 main.m \
 AppDelegate.m \
 PDFLibraryViewController.m \
 PDFReaderViewController.m \
 PDFPageView.m \
 BookmarkStore.m \
 RecentStore.m \
 AppearanceStore.m \
 AnnotationStore.m \
 AnnotationOverlayView.m \
 ThumbnailViewController.m \
 OutlineViewController.m \
 PDFOutlineParser.m \
 SearchViewController.m \
 SimplePDFSearch.m \
 URLImportViewController.m \
 PageManager.m

iPad1PDFReader_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CFNetwork
iPad1PDFReader_CFLAGS = -fno-objc-arc -Wall
iPad1PDFReader_RESOURCE_DIRS = Resources
iPad1PDFReader_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/application.mk

after-install::
 install.exec "killall -9 SpringBoard || true"
