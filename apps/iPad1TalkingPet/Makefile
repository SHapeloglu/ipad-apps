ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1TalkingPet
iPad1TalkingPet_FILES = main.m \
    src/AppDelegate.m \
    src/HomeViewController.m \
    src/PetNeedsManager.m
iPad1TalkingPet_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics
iPad1TalkingPet_CFLAGS = -fno-objc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
