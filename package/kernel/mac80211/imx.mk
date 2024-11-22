PKG_DRIVERS += \
	imx-w612-sdio

config-$(call config_package,imx-w612-sdio) += NXP_IW612 IMX_MLAN IMX_MOAL

define KernelPackage/imx-w612-sdio
	$(call KernelPackage/mac80211/Default)
	TITLE:=IMX W612 (SDIO) wireless support driver
	DEPENDS+= +kmod-mmc +kmod-mac80211 +imx-wifi-firmware
	FILES:= \
		$(PKG_BUILD_DIR)/drivers/net/wireless/imx/mlan.ko \
		$(PKG_BUILD_DIR)/drivers/net/wireless/imx/moal.ko
	AUTOLOAD:=$(call AutoProbe, mlan moal)
	MODPARAMS.moal = \
		drv_mode=2 \
		fw_name=nxp/sd_w61x_v1.bin.se
endef

define KernelPackage/imx-w612-sdio/description
	Kernel modules for the NXP IW612 wireless chips running over SDIO
endef
