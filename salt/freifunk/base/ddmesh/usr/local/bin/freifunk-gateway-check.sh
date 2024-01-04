#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###
#usage: freifunk-gateway-check.sh

DEBUG='true'
LOGGER_TAG='GW_CHECK'

BIND_FORWARDER_FILE='/etc/bind/vpn.forwarder'


ping_check() {
	local ifname="$1"
	local ping_ip="$2"

	[ -z "$ping_ip" ] && local ping_ip='8.8.8.8'
	ping -c1 -W5 -I "$ifname" "$ping_ip" >/dev/null
}

setup_gateway_table() {
	local dev="$1"
	local via="$2"
	local gateway_table="$3"

	#check if changed
	unset d
	unset v
	eval $(ip ro lis ta $gateway_table | awk '/default via/ {print "d="$5";v="$3} /default dev/ {print "d="$3";v=none"}')
	printf 'old: dev=%s, via=%s\n' "$d" "$v"
	[ "$dev" = "$d" ] && [ "$via" = "$v" ] && return

	#clear table
	ip route flush table "$gateway_table" 2>/dev/null

	#redirect gateway ip directly to gateway interface
	[ "$via" = 'none' ] || ip route add "$via"/32 dev "$dev" table "$gateway_table" 2>/dev/null

	#jump over private ranges
	ip route add throw 10.0.0.0/8 table "$gateway_table" 2>/dev/null
	ip route add throw 172.16.0.0/12 table "$gateway_table" 2>/dev/null
	ip route add throw 192.168.0.0/16 table "$gateway_table" 2>/dev/null

	#add default route (which has wider range than throw, so it is processed after throw)
	if [ "$via" = "none" ]; then
		ip route add default dev "$dev" table "$gateway_table"
	else
		ip route add default via "$via" dev "$dev" table "$gateway_table"
	fi
}


logger -s -t "$LOGGER_TAG" "gateway check start."

#kill running instance
mypid="$$"
pname="${0##*/}"
IFS=' '
printf '%s,%s\n' "$pname" "$mypid"
for i in $(pidof "$pname")
do
	[ "$i" != "$mypid" ] && printf 'kill %s\n' "$i" && kill -9 "$i"
done


$DEBUG && printf '\ngateway check start.\n\n'

#dont use vpn server (or any openvpn server), it could interrupt connection
# cloudflare, google, quad9, freifunk-dresden.de
ping_hosts='1.1.1.1 8.8.8.8 9.9.9.9 89.163.140.199'
$DEBUG && printf 'hosts:[%s]\n' "$ping_hosts"
logger -s -t "$LOGGER_TAG" "hosts: [$ping_hosts]"


#determine all possible gateways

default_lan_ifname="$(uci -qX get ffdd.sys.ifname)"
default_lan_gateway="$(ip route list table main | sed -n "/default via [0-9.]\+ dev $default_lan_ifname/{s#.*via \([0-9.]\+\).*#\1#p}")"
if [ -n "$default_lan_gateway" ] && [ -n "$default_lan_ifname" ]; then
	lan_default_route="$default_lan_gateway:$default_lan_ifname"
fi
printf 'LAN:%s via %s\n' "$default_lan_ifname" "$default_lan_gateway"


for ifname in vpn0 vpn1
do
	eval default_"$ifname"_ifname="$ifname"
	eval default_"$ifname"_gateway="$(ip route list table gateway_pool 2>/dev/null | sed -n "/default via [0-9.]\+ dev $ifname/{s#.*via \([0-9.]\+\).*#\1#p}")"
	eval valid_ifname=\$default_"$ifname"_ifname
	eval valid_gateway=\$default_"$ifname"_gateway

	#in case we do not have a "via", replace it with "none". this is checked later
	if [ -z "$valid_gateway" ]; then
		valid_gateway="$(ip route list table gateway_pool 2>/dev/null | sed -n "/default dev $ifname/{s#.*#none#p}")"
	fi
	if [ -n "$valid_ifname" ] && [ -n "$valid_gateway" ]; then
		default_vpn_route_list="$default_vpn_route_list $valid_gateway:$valid_ifname"
	fi
done
printf 'default_vpn_route_list=%s\n' "$default_vpn_route_list"


#try each gateway
ok='false'
IFS=' '
#start with vpn, because this is prefered gateway, then WAN and lates LAN
#(there is no forwarding to lan allowed by firewall)
for g in $default_vpn_route_list $lan_default_route
do
	printf '===========\n'
#	logger -s -t "$LOGGER_TAG" "try: $g"
	printf 'try: %s\n' "$g"
	dev="${g#*:}"
	via="${g%:*}"

	$DEBUG && printf 'via=%s, dev=%s\n' "$via" "$dev"

	#run check
	ok='false'
	countSuccessful='0'
	minSuccessful='1'
	printf 'minSuccessful: %s\n' "$minSuccessful"

	IFS=' '
	for ip in $ping_hosts
	do
		$DEBUG && printf 'ping to: %s via dev %s\n' "$ip" "$dev"
		ping_check "$dev" "$ip" 2>&1 && countSuccessful="$((countSuccessful+1))"

		if [ "$countSuccessful" -ge "$minSuccessful" ]; then
			ok='true'
			break
		fi
	done

	logger -s -t "$LOGGER_TAG" "ok: $ok"

	if "$ok"; then
		$DEBUG && printf 'gateway found: via %s dev %s (landev:%s)\n' "$via" "$dev" "$default_lan_ifname"

		#VSERVER: we have found a gateway (either via eth0 or openvpn) -> offer gateway service
		#VSERVER: keep local_gateway untouched. it is setup by S40network (not detected)
		#VSERVER: but it needs to be re-checkt. because if network is down, default route is removed from routing table and
		#VSERVER: must be readded
		#VSERVER:  - it ensures that host has always a working gateway.

		dev_is_vpn='1'	#default
		#always add wan or lan to local gateway
		if [ "$dev" = "$default_lan_ifname" ]; then
			logger -s -t "$LOGGER_TAG" "Set local gateway: dev:$dev, ip:$via"
			setup_gateway_table "$dev" "$via" local_gateway
			dev_is_vpn='0'	# reset
		fi

		$DEBUG && printf 'dev_is_vpn=%s\n' "$dev_is_vpn"
		logger -s -t "$LOGGER_TAG" "dev_is_vpn: $dev_is_vpn"

		# Add any gateway to public table if internet was enabled.
		# If internet is disabled, add only vpn if detected.
		# When lan/wan gateway gets lost, also vpn get lost
		# If only vpn get lost, remove public gateway
		if [ "$(uci -qX get ffdd.sys.announce_gateway)" = "1" -o "$dev_is_vpn" = "1" ]; then
			logger -s -t "$LOGGER_TAG" "Set public gateway: dev:$dev, ip:$via"
			setup_gateway_table "$dev" "$via" public_gateway

			/etc/init.d/S52batmand gateway

			# select correct dns if gateway is via vpn.
			# when server provides internet directly. dns will be the local host
			if [ "$dev_is_vpn" = "1" ]; then
				rm -f "$BIND_FORWARDER_FILE"
				ln -s "$BIND_FORWARDER_FILE"."$dev" "$BIND_FORWARDER_FILE"
				systemctl reload bind9
				printf 'DNS:\n%s\n' "$(cat $BIND_FORWARDER_FILE)"

				# add routes to DNS through tunnel (mullvad DNS is only accessible through tunnel)
				# - extract all dns from BIND_FORWARDER_FILE and create dns rules
				# openvpn:up.sh and wireguard:configs create the forwarder file but with different layout.
				tunnel_dns_servers="$(cat < "$BIND_FORWARDER_FILE" | sed -n 's#[  ]*[;{}][        ]*#\n#gp' | grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')"
			fi

			IFS='
'
			for dns_ip in $tunnel_dns_servers
			do
				ip route add $dns_ip dev $dev table public_dns
			done
			unset IFS

		else
			logger -s -t "$LOGGER_TAG" "Clear public gateway."
			ok='false'
		fi

		break
	fi

done
unset IFS


if ! "$ok"; then
	$DEBUG && printf 'no gateway\n'
	logger -s -t "$LOGGER_TAG" "no gateway"

	#remove all in default route from public_gateway table
	ip route flush table public_gateway 2>/dev/null
	ip route flush table public_dns 2>/dev/null
	/etc/init.d/S52batmand no_gateway

	# reload bind9
	rm -f "$BIND_FORWARDER_FILE"
	ln -s "$BIND_FORWARDER_FILE".def "$BIND_FORWARDER_FILE"
	systemctl reload bind9
	printf 'DNS:\n%s\n' "$(cat $BIND_FORWARDER_FILE)"

	# when we have a vpn network interface and ok='false'
	# then vpn is dead
	vpn_fail_log() { logger -s -t "$LOGGER_TAG" "$1 $2 connection is dead -> restarting" ; }

	if [ -n "$default_vpn_route_list" ]; then
		# check we use openvpn or wireguard
		# OVPN
		if [ -f /etc/openvpn/vpn0.conf ] && ! ping_check vpn0 ; then
			vpn_fail_log openvpn vpn0
			systemctl restart openvpn@openvpn-vpn0.service
		fi
		if [ -f /etc/openvpn/vpn1.conf ] && ! ping_check vpn1 ; then
			vpn_fail_log openvpn vpn1
			systemctl restart openvpn@openvpn-vpn1.service
		fi

		# WG
		if [ -f /etc/wireguard/vpn0.conf ] && ! ping_check vpn0 ; then
			vpn_fail_log wireguard vpn0
			systemctl restart wg-quick@vpn0.service
		fi
		if [ -f /etc/wireguard/vpn1.conf ] && ! ping_check vpn1 ; then
			vpn_fail_log wireguard vpn1
			systemctl restart wg-quick@vpn1.service
		fi
	fi
fi


$DEBUG && printf 'end.\n'
logger -s -t "$LOGGER_TAG" "gateway check end."

exit 0
