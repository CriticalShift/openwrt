#!/bin/sh

echo "Ethernet:"
dmesg | grep -i "eth0"
dmesg | grep -i "eth1"

echo ""
echo "SDIO/Wi-Fi:"
dmesg | grep -i "30b50000.mmc"
lsmod | grep -E "mlan|moal"

echo ""
echo "Cell/USB:"
lsusb
ls /dev/ttyU*

echo ""
echo "Dumping NIC status:"
ip address
