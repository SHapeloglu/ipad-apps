ARCHS = armv7
TARGET = iphone:clang:6.1:5.1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1Terminal

iPad1Terminal_FILES = \
	src/main.m \
	src/AppDelegate.m \
	src/HomeViewController.m \
	src/TerminalViewController.m \
	src/TerminalInputView.m \
	src/TerminalANSIParser.m \
	src/LocalTerminalSession.m

iPad1Terminal_FRAMEWORKS = UIKit Foundation
iPad1Terminal_CFLAGS = -fno-objc-arc -Wall -Wextra
iPad1Terminal_LDFLAGS =

include $(THEOS_MAKE_PATH)/application.mk
