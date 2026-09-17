ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = KidsDraw
KidsDraw_FILES = main.m \
                 src/AppDelegate.m \
                 src/DrawingView.m \
                 src/DrawingViewController.m
KidsDraw_FRAMEWORKS = UIKit CoreGraphics AudioToolbox QuartzCore
KidsDraw_CFLAGS = -fno-objc-arc
KidsDraw_RESOURCE_FILES = Resources/Icon-72.png Resources/Default-Landscape.png

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 KidsDraw || true"
