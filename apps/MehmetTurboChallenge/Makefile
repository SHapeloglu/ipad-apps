ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MehmetTurboChallenge
MehmetTurboChallenge_FILES = src/main.m \
    src/AppDelegate.m \
    src/GameView.m \
    src/Game.m \
    src/Car.m \
    src/Road.m

MehmetTurboChallenge_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics
MehmetTurboChallenge_INFO_PLIST = Resources/Info.plist
MehmetTurboChallenge_CFLAGS = -fno-objc-arc

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
