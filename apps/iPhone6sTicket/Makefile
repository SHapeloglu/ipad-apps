# iPhone 6s iOS 11-15 icin arm64 profil.
# Theos altinda iOS 9+ destekleyen daha yeni bir SDK kurulu olmalidir.
ARCHS := arm64
TARGET := iphone:clang:15.6:9.0

THEOS_PACKAGE_SCHEME = rootless
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME := iPhone6sTicket

iPhone6sTicket_FILES := main.m AppDelegate.m TicketViewController.m APIClient.m QRScanner.m
iPhone6sTicket_FRAMEWORKS := UIKit Foundation AVFoundation QuartzCore CoreMedia CoreVideo
iPhone6sTicket_CFLAGS := -fno-objc-arc -Wall -Wno-deprecated-declarations
iPhone6sTicket_RESOURCE_FILES := Info.plist

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall iPhone6sTicket 2>/dev/null || true"
