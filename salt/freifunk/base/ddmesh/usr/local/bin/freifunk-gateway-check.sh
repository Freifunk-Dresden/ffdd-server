#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###
#usage: freifunk-gateway-check.sh

ip_rule_priority='98'
ip_rule_priority_unreachable='99'
DEBUG='true'
LOGGER_TAG='GW_CHECK'

BIND_FORWARDER_FILE='/etc/bind/vpn.forwarder'


setup_gateway_table() {
	dev="$1"
	via="$2"
	gateway_table="$3"

	#check if changed
	unset d
	unset v
	eval $(ip ro lis ta $gateway_table | awk '/default via/ {print "d="$5";v="$3} /default dev/ {print "d="$3";v=none"}')
	printf 'old: dev=%s, via=%s\n' "$d" "$v"
	[ "$dev" = "$d" ] && [ "$via" = "$v" ] && return

	#clear table
	ip route flush table "$gateway_table" 2>/dev/null

	#redirect gateway ip directly to gateway interface
	test "$via" = "none" || ip route add "$via"/32 dev "$dev" table "$gateway_table" 2>/dev/null

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
	test "$i" != "$mypid" && printf 'kill %s\n' "$i" && kill -9 "$i"
done

$DEBUG && printf '%s\n' "start"

#dont use vpn server (or any openvpn server), it could interrupt connection
# cloudflare, google 2x, freifunk-dresden.de, vpn1.freifunk-dresden.de, vpn2.freifunk-dresden.de vpn5.freifunk-dresden.de
ping_hosts="1.1.1.1 8.8.8.8 9.9.9.9 89.163.140.199 178.63.61.147 148.251.48.91 5.45.106.241"
#process max 3 user ping
#cfg_ping="$(uci -q get ddmesh.network.gateway_check_ping)"
#gw_ping="$(echo "$cfg_ping" | sed 's#[ ,;/	]\+# #g' | cut -d' ' -f1-3 ) $ping_hosts"
gw_ping="$ping_hosts"
$DEBUG && printf 'hosts:[%s]\n' "$gw_ping"
logger -s -t "$LOGGER_TAG" "hosts: [$gw_ping]"


#determine all possible gateways

default_lan_ifname="$(nvram get ifname)"
default_lan_gateway="$(ip route list table main | sed -n "/default via [0-9.]\+ dev $default_lan_ifname/{s#.*via \([0-9.]\+\).*#\1#p}")"
if [ -n "$default_lan_gateway" ] && [ -n "$default_lan_ifname" ]; then
	lan_default_route="$default_lan_gateway:$default_lan_ifname"
fi
printf 'LAN:%s via %s\n' "$default_lan_ifname" "$default_lan_gateway"


for ifname in vpn0 vpn1
do
	eval default_"$ifname"_ifname="$ifname"
	eval default_"$ifname"_gateway="$(ip route list table gateway_pool| sed -n "/default via [0-9.]\+ dev $ifname/{s#.*via \([0-9.]\+\).*#\1#p}")"
	eval valid_ifname=\$default_"$ifname"_ifname
	eval valid_gateway=\$default_"$ifname"_gateway

	#in case we do not have a "via", replace it with "none". this is checked later
	if [ -z "$valid_gateway" ]; then
		valid_gateway="$(ip route list table gateway_pool | sed -n "/default dev $ifname/{s#.*#none#p}")"
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
logger -s -t "$LOGGER_TAG" "try: $g"
	printf '===========\n'
	printf 'try: %s\n' "$g"
	dev="${g#*:}"
	via="${g%:*}"

	$DEBUG && printf 'via=%s, dev=%s\n' "$via" "$dev"

	#add ping rule before all others;only pings from this host (no forwards)
	ip rule del iif lo fwmark 0x11 priority "$ip_rule_priority" table ping 2>/dev/null
	ip rule add iif lo fwmark 0x11 priority "$ip_rule_priority" table ping
	ip rule del iif lo fwmark 0x11 priority "$ip_rule_priority_unreachable" table ping_unreachable 2>/dev/null
	ip rule add iif lo fwmark 0x11 priority "$ip_rule_priority_unreachable" table ping_unreachable

	#no check of gateway, it might not return icmp reply, also
	#it might not be reachable because of routing rules

	#add ping hosts to special ping table
	ip route flush table ping
	ip route flush table ping_unreachable

	#add route to gateway, to avoid routing via freifunk
	test "$via" = "none" || ip route add "$via"/32 dev "$dev" table ping

	# ping must be working for at least the half of IPs
	IFS=' '
	numIPs='0'
	for ip in $gw_ping
	do
		$DEBUG && printf 'add ping route ip:%s\n' "$ip"
		if [ "$via" = "none" ]; then
			ip route add "$ip" dev "$dev" table ping
		else
			ip route add "$ip" via "$via" dev "$dev" table ping
		fi
		ip route add unreachable "$ip" table ping_unreachable
		$DEBUG && printf 'route: %s\n' "$(ip route get "$ip")"
	#	$DEBUG && printf 'route via:%s\n' "$(ip route get "$via")"
		numIPs="$((numIPs+1))"
	done
	printf 'number IPs: %s\n' "$numIPs"

	$DEBUG && ip ro li ta ping
	ip ro li ta ping

	#activate routes
	ip route flush cache

	#run check
	ok='false'
	countSuccessful='0'
	minSuccessful="$(( (numIPs+1)/2 ))"
	if [ "$minSuccessful" -lt 4 ]; then minSuccessful='4'; fi
	printf 'minSuccessful: %s\n' "$minSuccessful"

	IFS=' '
	for ip in $gw_ping
	do
		$DEBUG && printf 'ping to: %s\n' "$ip"
		ping -c 2 -w 10 "$ip" 2>&1 && countSuccessful="$((countSuccessful+1))"

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
		if [ "$(nvram get ddmesh_disable_gateway)" = "0" ] && [ "$dev_is_vpn" = "1" ]; then
			logger -s -t "$LOGGER_TAG" "Set public gateway: dev:$dev, ip:$via"
			setup_gateway_table "$dev" "$via" public_gateway

			/etc/init.d/S52batmand gateway

			# select correct dns
			rm -f "$BIND_FORWARDER_FILE"
			ln -s "$BIND_FORWARDER_FILE"."$dev" "$BIND_FORWARDER_FILE"
			systemctl reload bind9
			printf 'DNS:\n%s\n' "$(cat $BIND_FORWARDER_FILE)"

			# add routes to DNS through tunnel (mullvad DNS is only accessible through tunnel)
			# - extract all dns from BIND_FORWARDER_FILE and create dns rules
			# openvpn:up.sh and wireguard:configs create the forwarder file but with different layout.
			tunnel_dns_servers="$(cat "$BIND_FORWARDER_FILE" | sed -n 's#\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)[ 	]*;#\1\n#gp' | sed 's#forwarders##;s#[ 	{};]##g;/^$/d')"
			for dns_ip in $tunnel_dns_servers
			do
				ip route add $dns_ip dev $dev table public_dns
			done

		else
			logger -s -t "$LOGGER_TAG" "Clear public gateway."
			ok='false'
		fi

		break;
	fi

done
unset IFS


ip route flush table ping
ip route flush table ping_unreachable
ip rule del iif lo fwmark 0x11 priority "$ip_rule_priority" table ping >/dev/null
ip rule del iif lo fwmark 0x11 priority "$ip_rule_priority_unreachable" table ping_unreachable >/dev/null

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
	vpn_ping_check() { ping -c1 -W5 -I "$1" 8.8.8.8 >/dev/null ; }
	vpn_fail_log() { logger -s -t "$LOGGER_TAG" "vpn $1 connection is dead -> restarting" ; }

	if [ -n "$default_vpn_route_list" ]; then
		# check we use openvpn or wireguard
		# OVPN
		if [ -f /etc/openvpn/vpn0.conf ] && ! vpn_ping_check vpn0 ; then
			vpn_fail_log vpn0
			systemctl restart openvpn@openvpn-vpn0.service
		elif [ -f /etc/openvpn/vpn1.conf ] && ! vpn_ping_check vpn1 ; then
			vpn_fail_log vpn1
			systemctl restart openvpn@openvpn-vpn1.service
		fi
		# WG
		if [ -f /etc/wireguard/vpn0.conf ] && ! vpn_ping_check vpn0 ; then
			vpn_fail_log vpn0
			systemctl restart wg-quick@vpn0.service
		elif [ -f /etc/wireguard/vpn1.conf ] && ! vpn_ping_check vpn1 ; then
			vpn_fail_log vpn1
			systemctl restart wg-quick@vpn1.service
		fi
	fi
fi

$DEBUG && printf 'end.\n'
logger -s -t "$LOGGER_TAG" "gateway check end."

exit 0
