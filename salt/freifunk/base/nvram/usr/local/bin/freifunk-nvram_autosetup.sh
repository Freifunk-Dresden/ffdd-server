#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###
#
# Freifunk - Autosetup for /etc/nvram.conf
#
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#
# Get variables from /etc/nvram.conf
ddmesh_node="$(nvram get ddmesh_node)"
ddmesh_key="$(nvram get ddmesh_registerkey)"

fastd_secret="$(nvram get fastd_secret)"


if [[ -z "$ddmesh_key" ]] && [[ -z "$fastd_secret" ]]; then

	# set ddmesh_registerkey in /etc/nvram.conf
	nodeid="$(freifunk-register-local-node.sh | sed -n '/^node=/{s#^.*=##;p}')"
	genkey="$(ip link | sha256sum | sed 's#\(..\)#\1:#g;s#[ :-]*$##')"
	nvram set ddmesh_registerkey "$genkey"

	# set ddmesh_node in /etc/nvram.conf
	[[ -z "$ddmesh_node" ]] && nvram set ddmesh_node "$nodeid"

	# generate fastd secret & public key
	fastd --generate-key > /tmp/.ffdd_h.txt

		fastd_secret_key="$(sed -n '/^Secret:/{s#^.*: ##;p}' /tmp/.ffdd_h.txt)"
		fastd_public_key="$(sed -n '/^Public:/{s#^.*: ##;p}' /tmp/.ffdd_h.txt)"

	rm -f /tmp/.ffdd_h.txt

	# set fastd-key in /etc/nvram.conf
	nvram set fastd_secret "$fastd_secret_key"
	nvram set fastd_public "$fastd_public_key"

fi

#
exit 0
