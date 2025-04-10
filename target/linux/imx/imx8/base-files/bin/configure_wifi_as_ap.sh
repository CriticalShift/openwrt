#!/bin/sh

# Get WiFi device name
WIFI_DEV=$(iw dev | awk '$1=="Interface"{print $2}' | head -n1)

# Prompt for SSID
echo -n "Enter SSID for the access point: "
read SSID

# Prompt for security type
echo "Select security type:"
echo "1) None"
echo "2) WPA2-PSK"
echo -n "Enter choice (1-2): "
read SECURITY

# Prompt for password if WPA2 selected
if [ "$SECURITY" = "2" ]; then
    while true; do
    echo -n "Enter password (min 8 characters): "
        stty -echo  # Disable terminal echo
    read PASSWORD
        stty echo   # Restore terminal echo
        echo        # New line after password input
        if [ ${#PASSWORD} -lt 8 ]; then
        echo "Password too short. Must be at least 8 characters."
            continue
fi

        echo -n "Confirm password: "
        stty -echo  # Disable terminal echo
        read PASSWORD_CONFIRM
        stty echo   # Restore terminal echo
        echo        # New line after password input

        if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
            echo "Passwords do not match. Please try again."
            continue
        fi

        break
    done
fi

# Show configuration summary
echo "\nConfiguration Summary:"
echo "WiFi Device: $WIFI_DEV"
echo "SSID: $SSID"
echo "Security: $([ "$SECURITY" = "2" ] && echo "WPA2-PSK" || echo "None")"
[ "$SECURITY" = "2" ] && echo "Password: $PASSWORD"

# Confirm changes
echo -n "\nApply these changes? (y/n): "
read CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    # Configure WiFi using UCI
    uci set wireless.@wifi-device[0].disabled=0
    uci set wireless.@wifi-iface[0].device=$WIFI_DEV
    uci set wireless.@wifi-iface[0].network=lan
    uci set wireless.@wifi-iface[0].mode=ap
    uci set wireless.@wifi-iface[0].ssid="$SSID"

    if [ "$SECURITY" = "2" ]; then
        uci set wireless.@wifi-iface[0].encryption=psk2
        uci set wireless.@wifi-iface[0].key="$PASSWORD"
    else
        uci set wireless.@wifi-iface[0].encryption=none
    fi

    # Add interface to LAN bridge if not already
    BRIDGE=$(uci get network.lan.ifname)
    if ! echo "$BRIDGE" | grep -q "$WIFI_DEV"; then
        uci set network.lan.ifname="$BRIDGE $WIFI_DEV"
    fi

    # Commit changes and restart WiFi
    uci commit wireless
    uci commit network
    wifi down
    wifi up

    echo "WiFi configuration completed successfully!"
else
    echo "Configuration aborted."
fi