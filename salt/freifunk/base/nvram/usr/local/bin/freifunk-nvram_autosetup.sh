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


# function: find local node id
get_ddmesh_nodeid() {
	nodeid="$(freifunk-register-local-node.sh | sed -n '/^node=/{s#^.*=##;p}')"
}

# function: generate ddmesh_registerkey
gen_ddmesh_key() {
	genkey="$(ip link | sha256sum | sed 's#\(..\)#\1:#g;s#[ :-]*$##')"
}

# function: generate fastd secret & public key
gen_fastd_key() {

	fastd --generate-key > /tmp/.ffdd_h.txt

		fastd_secret_key="$(sed -n '/^Secret:/{s#^.*: ##;p}' /tmp/.ffdd_h.txt)"
		fastd_public_key="$(sed -n '/^Public:/{s#^.*: ##;p}' /tmp/.ffdd_h.txt)"

	rm -f /tmp/.ffdd_h.txt
}


if [[ "$ddmesh_key" = '' ]] && [[ "$fastd_secret" = '' ]]; then

	# set ddmesh_registerkey in /etc/nvram.conf
	gen_ddmesh_key									&&
	nvram set ddmesh_registerkey "${genkey}"

	# set ddmesh_node in /etc/nvram.conf
	if [ "$ddmesh_node" == '' ]; then
		get_ddmesh_nodeid							&&
		nvram set ddmesh_node "${nodeid}"
	fi

	# set fastd-key in /etc/nvram.conf
	gen_fastd_key									&&
	nvram set fastd_secret "${fastd_secret_key}"	&&
	nvram set fastd_public "${fastd_public_key}"

fi

exit 0
