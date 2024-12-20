#!/usr/bin/env sh
### This file managed by Salt, do not edit by hand! ###

get_ip() { curl --interface "$1" -sL ip.envs.net ; }

ip="$(get_ip vpn0)"
[ -z "$ip" ] && ip="$(get_ip vpn1)"

if [ -n "$ip" ]; then
	country=$(whois "$ip" | sed -n '/^country:/s#.*[: 	]##p')
	printf 'GW-INFO: %s %s\n' "$ip" "$country"
else
	printf 'no gateway info available.\n'
fi

exit 0
