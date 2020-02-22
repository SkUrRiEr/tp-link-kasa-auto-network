#!/bin/bash

if [ $# -lt 2 ]; then
	echo $0 SSID PASSWORD
	exit
fi

CONNECTION_NAME="smartplug-capture"

until nmcli -t -f SSID device wifi list | grep -q "^TP-LINK_Smart Plug_....$"; do
	echo "No networks found, sleeping..."
	sleep 10
done

LINE="$(nmcli -t -e no -f "SSID,BSSID" device wifi list | grep "^TP-LINK_Smart Plug_....:" | head -1)"
NETWORK="$(echo $LINE | cut -d: -f 1)"
MAC="$(echo $LINE | sed 's/^[^:]*://')"

echo "Found smart plug WiFi network: $NETWORK... ($MAC)"

#TODO: Set up WiFi firewall rules

nmcli connection add type wifi ifname "*" con-name $CONNECTION_NAME ssid "$NETWORK"

nmcli connection up $CONNECTION_NAME

echo "Connected. Discovering smart plug..."

IP="$(pyhs100 discover | grep "^Host" | sed 's/^.*: //')"

echo "Found smart plug with IP ${IP}. Setting network data..."

pyhs100 --ip $IP raw-command netif set_stainfo "{'ssid': '${1}', 'password': '${2}', 'key_type': 3}"

echo "Network data set, killing connection..."

nmcli connection down $CONNECTION_NAME

nmcli connection delete $CONNECTION_NAME
