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

define Device/iot-gate-imx8plus
	DEVICE_VENDOR := NXP
	DEVICE_MODEL := IMX8MPLUS CompuLab IOT-GATE i.MX8P
	DEVICE_VARIANT := SD Card Boot
	PLAT := iMX8MP
	SOC_TYPE := iMX8M
	DEVICE_TYPE := flash_evk
	ENV_NAME:=iot-gate-imx8plus
	DEVICE_PACKAGES += \
		firmware-imx \
		u-boot-compulab
	DEVICE_DTS := compulab/iot-gate-imx8plus
	IMAGE/sdcard.img := \
		imx-compile-dtb $$(DEVICE_DTS) | \
		imx-clean | \
		imx-append-sdhead $(1) | pad-to 32K | \
		imx-append-boot $$(SOC_TYPE) | pad-to 4M | \
		imx-append $$(ENV_NAME)-uboot-env.bin | pad-to $(IMX_SD_KERNELPART_OFFSET)M | \
		imx-append-kernel $$(DEVICE_DTS) | pad-to $(IMX_SD_ROOTFSPART_OFFSET)M | \
		append-rootfs | pad-to $(IMX_SD_IMAGE_SIZE)M
endef
TARGET_DEVICES += iot-gate-imx8plus

define Device/ucm-imx8m-plus
	DEVICE_VENDOR := NXP
	DEVICE_MODEL := CompuLab ucm-imx8m-plus
	DEVICE_VARIANT := Boot Agnostic
	PLAT := iMX8MP
	SOC_TYPE := iMX8M
	DEVICE_TYPE := flash_evk
	ENV_NAME:=ucm-imx8m-plus
	DEVICE_PACKAGES += \
		firmware-imx \
		u-boot-compulab_ucm-imx8m-plus \
		kmod-mwifiex-iw612-sdio \
		kmod-usb-net-sierrawireless \
		kmod-usb-net-qmi-wwan \
		kmod-usb-serial-qualcomm \
		kmod-usb-net-cdc-mbim
	DEVICE_DTS := compulab/ucm-imx8m-plus-shield-evk
	IMAGE/sdcard.img := \
		imx-compile-dtb $$(DEVICE_DTS) | \
		imx-clean | \
		imx-append-sdhead $(1) | pad-to 32K | \
		imx-append-boot $$(SOC_TYPE) | pad-to 4M | \
		imx-append $$(ENV_NAME)-uboot-env.bin | pad-to $(IMX_SD_KERNELPART_OFFSET)M | \
		imx-append-kernel $$(DEVICE_DTS) | pad-to $(IMX_SD_ROOTFSPART_OFFSET)M | \
	append-rootfs | pad-to $(IMX_SD_IMAGE_SIZE)M
endef
TARGET_DEVICES += ucm-imx8m-plus