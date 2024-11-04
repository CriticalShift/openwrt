#
# Copyright (C) 2013-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=u-boot-compulab
PKG_VERSION:=u-boot-compulab_v2023.04
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/CriticalShift/u-boot-compulab.git
PKG_SOURCE_VERSION:=u-boot-compulab_v2023.04
PKG_MIRROR_HASH:=skip

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
	BUILD_TARGET:=imx
	BUILD_SUBTARGET:=imx8
	UBOOT_IMAGE:=flash.bin
	ENV_SIZE:=0x4000
endef

define U-Boot/compulab_iot-gate-imx8mplus
	NAME:=iot-gate-imx8mplus lpddr4 board
	UBOOT_CONFIG:=iot-gate-imx8plus
	DEPENDS:=+firmware-imx
endef

define U-Boot/compulab_ucm-imx8m-plus
	NAME:=ucm-imx8m-plus lpddr4 board
	DEPENDS:=+firmware-imx
	UBOOT_CONFIG:=ucm-imx8m-plus
endef


UBOOT_TARGETS := \
	compulab_iot-gate-imx8mplus \
	compulab_ucm-imx8m-plus

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)/imx-mkimage/iMX8M/
	$(CP) $(PKG_BUILD_DIR)/flash.bin $(STAGING_DIR_IMAGE)/imx-mkimage/iMX8M/
	$(CP) $(PKG_BUILD_DIR)/flash.bin $(STAGING_DIR_IMAGE)/

	$(PKG_BUILD_DIR)/tools/mkenvimage -s $(ENV_SIZE) \
		-o $(STAGING_DIR_IMAGE)/$(UBOOT_CONFIG)-uboot-env.bin \
		files/$(UBOOT_CONFIG)_config

	$(PKG_BUILD_DIR)/tools/mkimage -C none -O Linux -A arm -T script \
		-d files/$(UBOOT_CONFIG)_bootscript $(STAGING_DIR_IMAGE)/boot.scr
endef

define Package/u-boot/install/default
endef

define Build/compulab-append-boot
	# Append the uboot, firmware etc.
	dd if=$(STAGING_DIR_IMAGE)/flash.bin >> $@
endef

$(eval $(call BuildPackage/U-Boot))