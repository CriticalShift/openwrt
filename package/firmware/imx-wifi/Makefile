include $(TOPDIR)/rules.mk

PKG_NAME:=imx-wifi
PKG_SOURCE_VERSION:=lf-6.1.22_2.0.0
PKG_MIRROR_HASH:=skip
PKG_RELEASE=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nxp-imx/imx-firmware.git

include $(INCLUDE_DIR)/package.mk

define Package/imx-wifi-firmware
  SECTION:=firmware
  CATEGORY:=Firmware
  TITLE:=NXP IW612 firmware
  URL:=$(PKG_SOURCE_URL)
endef

define Package/imx-wifi-firmware/install
	$(INSTALL_DIR) $(1)/lib/firmware/nxp/
	$(CP) \
		$(PKG_BUILD_DIR)/nxp/FwImage_IW612_SD/sd_w61x_v1.bin.se \
		$(1)/lib/firmware/nxp
	$(CP) \
		$(PKG_BUILD_DIR)/nxp/SCR-nxp.txt \
		$(1)/lib/firmware/nxp
endef

define Build/Compile

endef

$(eval $(call BuildPackage,imx-wifi-firmware))
