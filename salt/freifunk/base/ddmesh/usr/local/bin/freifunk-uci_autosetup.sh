#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###
#
# Freifunk - Autosetup for /etc/config/ffdd
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#
# Get variables from /etc/config/ffdd
ddmesh_node="$(uci -qX get ffdd.sys.ddmesh_node)"
ddmesh_key="$(uci -qX get dffdd.sys.ddmesh_registerkey)"

if [ -z "$ddmesh_key" ] || [ "$ddmesh_key" = '-' ] || \
	[ -z "$fastd_secret" ] || [ "$fastd_secret" = '-' ]; then

		# set ddmesh_registerkey
		ddmesh_key="$(ip link | sha256sum | sed 's#\(..\)#\1:#g;s#[ :-]*$##')"
		uci set ffdd.sys.ddmesh_registerkey="$ddmesh_key"
		uci commit

		# set ddmesh_node
		ddmesh_nodeid="$(freifunk-register-local-node.sh | sed -n '/^node=/{s#^.*=##;p}')"
		[ -n "$ddmesh_nodeid" ] && uci set ffdd.sys.ddmesh_node="$ddmesh_nodeid" || exit 1

		uci commit
fi

#
exit 0
