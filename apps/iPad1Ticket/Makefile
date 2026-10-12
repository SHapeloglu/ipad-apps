ARCHS := armv7
TARGET := iphone:clang:6.1:5.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME := iPad1Ticket

ZBAR := $(THEOS_PROJECT_DIR)/ZBar-src

iPad1Ticket_FILES := \
	main.m \
	AppDelegate.m \
	TicketViewController.m \
	APIClient.m \
	QRScanner.m \
	$(ZBAR)/zbar/config.c \
	$(ZBAR)/zbar/decoder.c \
	$(ZBAR)/zbar/decoder/codabar.c \
	$(ZBAR)/zbar/decoder/code128.c \
	$(ZBAR)/zbar/decoder/code39.c \
	$(ZBAR)/zbar/decoder/code93.c \
	$(ZBAR)/zbar/decoder/databar.c \
	$(ZBAR)/zbar/decoder/ean.c \
	$(ZBAR)/zbar/decoder/i25.c \
	$(ZBAR)/zbar/decoder/qr_finder.c \
	$(ZBAR)/zbar/error.c \
	$(ZBAR)/zbar/image.c \
	$(ZBAR)/zbar/img_scanner.c \
	$(ZBAR)/zbar/qrcode/bch15_5.c \
	$(ZBAR)/zbar/qrcode/binarize.c \
	$(ZBAR)/zbar/qrcode/isaac.c \
	$(ZBAR)/zbar/qrcode/qrdec.c \
	$(ZBAR)/zbar/qrcode/qrdectxt.c \
	$(ZBAR)/zbar/qrcode/rs.c \
	$(ZBAR)/zbar/qrcode/util.c \
	$(ZBAR)/zbar/refcnt.c \
	$(ZBAR)/zbar/scanner.c \
	$(ZBAR)/zbar/symbol.c \
	$(ZBAR)/iphone/ZBarHelpController.m \
	$(ZBAR)/iphone/ZBarReaderController.m \
	$(ZBAR)/iphone/ZBarSymbol.m \
	$(ZBAR)/iphone/ZBarImage.m \
	$(ZBAR)/iphone/ZBarImageScanner.m \
	$(ZBAR)/iphone/ZBarCaptureReader.m \
	$(ZBAR)/iphone/ZBarReaderViewController.m \
	$(ZBAR)/iphone/ZBarReaderView.m \
	$(ZBAR)/iphone/ZBarCVImage.m \
	$(ZBAR)/iphone/ZBarReaderViewImpl_Capture.m

iPad1Ticket_FRAMEWORKS := \
	UIKit \
	Foundation \
	AVFoundation \
	CoreGraphics \
	CoreMedia \
	CoreVideo \
	QuartzCore

iPad1Ticket_LIBRARIES := iconv

iPad1Ticket_CFLAGS := \
	-fno-objc-arc \
	-Wall \
	-Wno-error \
	-Wno-shift-op-parentheses \
	-Wno-logical-op-parentheses \
	-Wno-logical-not-parentheses \
	-I$(ZBAR)/include \
	-I$(ZBAR)/zbar \
	-I$(ZBAR)/iphone \
	-I$(ZBAR)/iphone/include

iPad1Ticket_RESOURCE_FILES := Info.plist

include $(THEOS_MAKE_PATH)/application.mk
