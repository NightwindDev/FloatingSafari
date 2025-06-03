TARGET := iphone:clang:latest:15.0
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = MobileSafari

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FloatingSafari

FloatingSafari_FILES = Tweak.x
FloatingSafari_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
