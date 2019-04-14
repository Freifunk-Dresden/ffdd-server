#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###

ip="$(curl --interface vpn0 -s whois.envs.net)"
[ -z "$ip" ] && ip="$(curl --interface vpn1 -sL whois.envs.net)"

if [ -n "$ip" ]; then
	country=$(whois "$ip" | sed -n '/^country:/s#.*[: 	]##p')
	printf 'OPENVPN country: %s\n' "$country"
fi

exit 0
