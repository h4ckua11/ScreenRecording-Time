ARCHS = arm64 arm64e
TARGET = iphone:clang:13.3:11.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ScreenRecordingTime

ScreenRecordingTime_FILES = Tweak.xm
ScreenRecordingTime_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
