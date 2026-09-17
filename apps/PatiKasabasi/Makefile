ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = PatiKasabasi

PatiKasabasi_FILES = main.m \
	$(wildcard src/*.m)
PatiKasabasi_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore AudioToolbox AVFoundation
PatiKasabasi_CFLAGS = -fno-objc-arc -Wall -Wextra -Wno-deprecated-declarations
PatiKasabasi_RESOURCE_DIRS = Resources

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
