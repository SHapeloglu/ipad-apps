ARCHS = arm64
TARGET = iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TOOL_NAME = nfcprobe

nfcprobe_FILES = main.m
nfcprobe_CFLAGS = -fobjc-arc -fblocks
nfcprobe_FRAMEWORKS = Foundation
nfcprobe_LDFLAGS = -ldl

include $(THEOS_MAKE_PATH)/tool.mk
