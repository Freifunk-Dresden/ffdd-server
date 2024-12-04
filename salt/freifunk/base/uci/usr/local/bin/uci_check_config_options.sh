#!/bin/sh
#
# script to set new uci config options
#

## ffdd.sys

	test -z "$(uci -qX get ffdd.sys.devmode)" && uci -q set ffdd.sys.devmode=0
	test -z "$(uci -qX get ffdd.sys.network_id)" && uci -q set ffdd.sys.network_id=0
	test -z "$(uci -qX get ffdd.sys.community_server)" && uci -q set ffdd.sys.community_server=0

	test -n "$(uci -qX get ffdd.sys.ddmesh_disable_gateway)" && uci -q delete ffdd.sys.ddmesh_disable_gateway
	test -z "$(uci -qX get ffdd.sys.announce_gateway)" && uci -q set ffdd.sys.announce_gateway=0
	test -z "$(uci -qX get ffdd.sys.group_id)" && uci -q set ffdd.sys.group_id=0
	test -z "$(uci -qX get ffdd.sys.firewall_log)" && uci -q set ffdd.sys.firewall_log=0

	test -z "$(uci -qX get ffdd.sys.apache_ddos_prevent)" && uci -q set ffdd.sys.apache_ddos_prevent=1
	test -z "$(uci -qX get ffdd.sys.apache_speedtest)" && uci -q set ffdd.sys.apache_speedtest=1

## ffdd.wireguard

	if [ -z "$(uci -qX get ffdd.wireguard)" ]; then
		uci -q add ffdd wireguard
		uci -q rename ffdd.@wireguard[-1]='wireguard'
	fi

	test -z "$(uci -qX get ffdd.wireguard.unused_days)" && uci -q set ffdd.wireguard.unused_days=30
	test -z "$(uci -qX get ffdd.wireguard.ext_port)" && uci -q set ffdd.wireguard.ext_port=5003
	test -z "$(uci -qX get ffdd.wireguard.restrict)" && uci -q set ffdd.wireguard.restrict=0


## ffdd.fastd

	test -z "$(uci -qX get ffdd.fastd.disable)" && uci -q set ffdd.fastd.disable=0


## finish / save uci config
uci commit

exit 0
