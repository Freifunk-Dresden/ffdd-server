#!/bin/sh

nvram_get() { sed -n "/^$1=/{s#^[^=]*=##;p}" /etc/nvram.conf | head -1 ; }

if [ -f /etc/nvram.conf ]; then

	uci set ffdd.sys.install_dir='/srv/ffdd-server'

	uci set ffdd.sys.freifunk_repo="$(nvram_get freifunk_repo)"

	uci set ffdd.sys.branch="$(nvram_get branch)"

	uci set ffdd.sys.autoupdate="$(nvram_get autoupdate)"

	uci set ffdd.sys.ddmesh_node="$(nvram_get ddmesh_node)"
	uci set ffdd.sys.ddmesh_registerkey="$(nvram_get ddmesh_registerkey)"

	uci set ffdd.sys.ddmesh_disable_gateway="$(nvram_get ddmesh_disable_gateway)"

	uci set ffdd.sys.servername="$(nvram_get servername)"

	uci set ffdd.sys.ifname="$(nvram_get ifname)"

	uci set ffdd.sys.fastd_secret="$(nvram_get fastd_secret)"
	uci set ffdd.sys.fastd_public="$(nvram_get fastd_public)"
	uci set ffdd.sys.fastd_restrict="$(nvram_get fastd_restrict)"

	uci set ffdd.sys.wireguard_secret="$(nvram_get wireguard_secret)"

	uci set ffdd.sys.ssh_pwauth="$(nvram_get ssh_pwauth)"

	uci set ffdd.sys.ifname="$(nvram_get ifname)"

	# ignore default_dns list entry

	uci set ffdd.sys.bmxd_prefered_gateway="$(nvram_get bmxd_prefered_gateway)"

	uci set ffdd.sys.gps_latitude="$(nvram_get gps_latitude)"
	uci set ffdd.sys.gps_longitude="$(nvram_get gps_longitude)"
	uci set ffdd.sys.gps_altitude="$(nvram_get gps_altitude)"
	uci set ffdd.sys.city="$(nvram_get city)"

	uci set ffdd.sys.contact_name="$(nvram_get contact_name)"
	uci set ffdd.sys.contact_location="$(nvram_get contact_location)"
	uci set ffdd.sys.contact_email="$(nvram_get contact_email)"
	uci set ffdd.sys.contact_note="$(nvram_get contact_note)"

	#
	uci commit
fi

exit 0
