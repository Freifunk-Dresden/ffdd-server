#!/bin/sh
#
# script to set new uci config options
#

## ffdd.sys

	test -z "$(uci -qX get ffdd.sys.devmode)" && uci -q set ffdd.sys.devmode=0
	test -z "$(uci -qX get ffdd.sys.apache_ddos_prevent)" && uci -q set ffdd.sys.apache_ddos_prevent=1
	test -z "$(uci -qX get ffdd.sys.wireguard_restrict)" && uci -q set ffdd.sys.wireguard_restrict=0

	test -z "$(uci -qX get ffdd.sys.network_id)" && uci -q set ffdd.sys.network_id=0
	test -z "$(uci -qX get ffdd.sys.community_server)" && uci -q set ffdd.sys.community_server=0


## ffdd.wireguard

	if [ -z "$(uci -qX get ffdd.wireguard)" ]; then
		uci -q add ffdd wireguard
		uci -q rename ffdd.@wireguard[-1]='wireguard'
	fi

	test -z "$(uci -qX get ffdd.wireguard.unused_days)" && uci -q set ffdd.wireguard.unused_days=30


## finish / save uci config
uci commit

exit 0
