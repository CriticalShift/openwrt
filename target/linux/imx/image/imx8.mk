# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright 2022 NXP

define Device/Default
  PROFILES := Default
  FILESYSTEMS := squashfs
  KERNEL_INITRAMFS = kernel-bin
  KERNEL_LOADADDR := 0x80080000
  KERNEL_ENTRY_POINT := 0x80080000
  IMAGE_SIZE := 64m
  KERNEL = kernel-bin
  IMAGES := sdcard.img sysupgrade.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef

define Device/imx8mplus
  DEVICE_VENDOR := NXP
  DEVICE_MODEL := IMX8MPLUS
  DEVICE_VARIANT := SD Card Boot
  PLAT := iMX8MP
  SOC_TYPE := iMX8M
  DEVICE_TYPE := flash_evk
  ENV_NAME:=imx8mp-sdboot
  DEVICE_PACKAGES += \
	firmware-imx \
	imx-mkimage \
	u-boot-imx8mp
  DEVICE_DTS := freescale/imx8mp-evk
  IMAGE/sdcard.img := \
	imx-compile-dtb $$(DEVICE_DTS) | \
	imx-create-flash $$(PLAT) $$(DEVICE_TYPE) | \
	imx-clean | \
	imx-append-sdhead $(1) | pad-to 32K | \
	imx-append-boot $$(SOC_TYPE) | pad-to 4M | \
	imx-append $$(ENV_NAME)-uboot-env.bin | pad-to $(IMX_SD_KERNELPART_OFFSET)M | \
	imx-append-kernel $$(DEVICE_DTS) | pad-to $(IMX_SD_ROOTFSPART_OFFSET)M | \
	append-rootfs | pad-to $(IMX_SD_IMAGE_SIZE)M
endef
TARGET_DEVICES += imx8mplus
