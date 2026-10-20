ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1Karaoke

iPad1Karaoke_FILES = main.m \
    src/AppDelegate.m \
    src/KaraokeViewController.m \
    src/LRCParser.m

iPad1Karaoke_FRAMEWORKS = UIKit Foundation AVFoundation AudioToolbox
iPad1Karaoke_CFLAGS = -fno-objc-arc -Wall -Wextra
iPad1Karaoke_RESOURCE_DIRS = Resources
iPad1Karaoke_INFOPLIST_FILE = Info.plist

iPad1Karaoke_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
