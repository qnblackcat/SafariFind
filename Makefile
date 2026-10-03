TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = MobileSafari
ARCHS = arm64 arm64e
# Default: roothide. For rootless: make package THEOS_PACKAGE_SCHEME=rootless
THEOS_PACKAGE_SCHEME ?= roothide

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SafariFind
SafariFind_FILES = Tweak.x
SafariFind_CFLAGS = -fobjc-arc
SafariFind_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
