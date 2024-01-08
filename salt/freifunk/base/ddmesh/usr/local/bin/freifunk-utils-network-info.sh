#!/usr/bin/env bash
# Copyright (C) 2006 - present, Stephan Enderlein<stephan@freifunk-dresden.de>
# GNU General Public License Version 3

### This file managed by Salt, do not edit by hand! ###
# this file is derived from the firmware file ddmesh-utils-network-info.sh and only
# implements the "list". Other functionalities are not used on server

net_wan_ifname=$(uci -qX get ffdd.sys.ifname)
net_backbone_wg_ifname=tbb_wg
net_backbone_fastd_ifname=tbb_fastd2
net_ffgw_ifname=ffgw
net_vpn1_ifname=vpn0
net_vpn2_ifname=vpn1

cat <<EOM
net_wan=${net_wan_ifname}
net_backbone_wg=${net_backbone_wg_ifname}
net_backbone_fastd=${net_backbone_fastd_ifname}
net_ffgw=${net_ffgw_ifname}
net_vpn1=${net_vpn1_ifname}
net_vpn2=${net_vpn2_ifname}
EOM
