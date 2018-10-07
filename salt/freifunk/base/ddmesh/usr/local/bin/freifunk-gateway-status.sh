#!/usr/bin/env bash
# (Salt managed)

iface="$(ip ro lis ta public_gateway | sed -n '/default/s#.*\(vpn.*\)$#\1#p')"
#echo "OPENVPN interface: $iface"

filename="$(grep -l "^[ 	]*dev[ 	]\+"$iface /etc/openvpn/*.conf | sed 's#:.*##')"
#echo "OPENVPN config file: $filename"

ip="$(grep "^[ 	]*remote[ 	]\+" $filename | awk '{print $2}')"
#echo "OPENVPN server ip: $ip"

country=$(whois "$ip" | sed -n '/^country:/s#.*[: 	]##p')
printf 'OPENVPN country: %s\n' "$country"

exit 0
