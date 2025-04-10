#!/bin/sh

# Check for cellular modem
if [ ! -e "/dev/cdc-wdm0" ]; then
    echo "Error: Cellular modem is not detected."
    exit 1
fi

# Present carrier options
echo "Please choose which network your SIM card belongs to:"
echo "1) AT&T"
echo "2) T-Mobile"
echo "3) Verizon"
echo "9) Enter APN manually"
read -p "Enter your choice (1-3,9): " choice

case $choice in
    1) apn="broadband";;
    2) apn="fast.t-mobile.com";;
    3) apn="vzwinternet";;
    9)
        read -p "Please enter your APN: " apn
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo "Applying settings..."

# Configure network settings
uci set network.wan.apn="$apn"
uci set network.wan.disabled='0'
uci commit network

echo "Settings applied. Restarting network services..."

# Restart necessary services
/etc/init.d/network restart
sleep 2
/etc/init.d/netifd restart

echo "Configuration complete. The cellular connection should now be active."