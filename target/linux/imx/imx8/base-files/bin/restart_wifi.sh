#!/bin/sh

# Detach SDIO bus
rmmod moal
rmmod mlan
echo "30b50000.mmc" >> /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind

# Reattach SDIO bus
echo "30b50000.mmc" >> /sys/bus/platform/drivers/sdhci-esdhc-imx/bind
insmod mlan
insmod moal mod_para=nxp/wifi_mod_para.conf
