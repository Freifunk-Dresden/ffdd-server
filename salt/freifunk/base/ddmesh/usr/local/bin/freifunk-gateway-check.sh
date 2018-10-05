#!/usr/bin/env bash
# (Salt managed)
#usage: gateway-check.sh 

ip_rule_priority=98
ip_rule_priority_unreachable=99
DEBUG=true
LOGGER_TAG="GW_CHECK"

logger -s -t "$LOGGER_TAG" "gateway check start."

setup_gateway_table ()
{
	dev=$1
	via=$2
	gateway_table=$3

	#check if changed
	unset d
	unset v
	eval $(ip ro lis ta $gateway_table | awk ' /default/ {print "d="$5";v="$3} ')
	echo "old: dev=$d, via=$v"
	if [ "$dev" = "$d" -a "$via" = "$v" ]; then
		return
	fi

	#clear table	
	ip route flush table $gateway_table 2>/dev/null

	#redirect gateway ip directly to gateway interface
	ip route add $via/32 dev $dev table $gateway_table 2>/dev/null
	
	#jump over freifunk ranges
	ip route add throw 10.0.0.0/8 table $gateway_table 2>/dev/null
	ip route add throw 172.16.0.0/12 table $gateway_table 2>/dev/null

	#jump over private ranges
	ip route add throw 192.168.0.0/16 table $gateway_table 2>/dev/null

	#add default route (which has wider range than throw, so it is processed after throw)
	ip route add default via $via dev $dev table $gateway_table  
}

#kill running instance
mypid=$$
pname=${0##*/}
IFS=' '
echo	$pname,$mypid
for i in $(pidof $pname)
do
  test "$i" != "$mypid" && echo kill $i && kill -9 $i
done

$DEBUG && echo "start"

#dont use vpn server (or any openvpn server), it could interrupt connection
# freifunk-dresden.de, freifunk.net, www.dresden.de
ping_hosts="8.8.8.8 9.9.9.9 85.114.135.114 91.250.99.221 194.49.19.111"
#process max 3 user ping
#cfg_ping="$(uci -q get ddmesh.network.gateway_check_ping)"
#gw_ping="$(echo "$cfg_ping" | sed 's#[ ,;/	]\+# #g' | cut -d' ' -f1-3 ) $ping_hosts"
gw_ping="$ping_hosts"
$DEBUG && echo "hosts:[$gw_ping]"
logger -s -t "$LOGGER_TAG" "hosts: [$gw_ping]"

#determine all possible gateways

#icvpn gateways; prefere 
default_icvpn_ifname=icvpn
prefer_icvpn_hosts="10.207.0.130:$default_icvpn_ifname 10.207.0.131:$default_icvpn_ifname"
icvpn_default_route="$prefer_icvpn_hosts $(for i in $(ip ro lis ta zebra | cut -d' ' -f3|sort -u);do echo -n $i:$default_icvpn_ifname' '; done)"
echo "WAN:$default_wan_ifname via preferred hosts: $prefer_icvpn_hosts"


default_lan_ifname=$(nvram get ifname)
default_lan_gateway=$(ip route list table main | sed -n "/default via [0-9.]\+ dev $default_lan_ifname/{s#.*via \([0-9.]\+\).*#\1#p}")
if [ -n "$default_lan_gateway" -a -n "$default_lan_ifname" ]; then
	lan_default_route="$default_lan_gateway:$default_lan_ifname"
fi

echo "LAN:$default_lan_ifname via $default_lan_gateway"


#_ifname=vpn
#default_vpn_ifname=$(ip route list table gateway_pool| sed -n "/default via [0-9.]\+ dev $_ifname/{s#.*dev \([^ 	]\+\).*#\1#p}")
#default_vpn_gateway=$(ip route list table gateway_pool| sed -n "/default via [0-9.]\+ dev $_ifname/{s#.*via \([0-9.]\+\).*#\1#p}")
#if [ -n "$default_vpn_gateway" -a -n "$default_vpn_ifname" ]; then
#	vpn_default_route="$default_vpn_gateway:$default_vpn_ifname"
#fi
#echo "VPN:$default_vpn_ifname via $default_vpn_gateway"

for ifname in vpn0 vpn1
do
        eval default_"$ifname"_ifname=$ifname
        eval default_"$ifname"_gateway=$(ip route list table gateway_pool| sed -n "/default via [0-9.]\+ dev $ifname/{s#.*via \([0-9.]\+\).*#\1#p}")
        eval valid_ifname=\$default_"$ifname"_ifname
        eval valid_gateway=\$default_"$ifname"_gateway
        if [ -n "$valid_ifname"  -a -n "$valid_gateway" ]; then
                default_vpn_route_list="$default_vpn_route_list $valid_gateway:$valid_ifname"
        fi
done
echo "default_vpn_route_list=$default_vpn_route_list"

#try each gateway
ok=false
IFS=' '
#start with vpn, because this is prefered gateway, then WAN and lates LAN
#(there is no forwarding to lan allowed by firewall)
#for g in $vpn_default_route $icvpn_default_route $lan_default_route
for g in $default_vpn_route_list $lan_default_route 
do
logger -s -t "$LOGGER_TAG" "try: $g"
	echo "==========="
	echo "try: $g"
	dev=${g#*:}
	via=${g%:*}
 
	$DEBUG && echo "via=$via, dev=$dev"


	#add ping rule before all others;only pings from this host (no forwards) 
	ip rule del iif lo fwmark 0x11 priority $ip_rule_priority table ping 2>/dev/null
	ip rule add iif lo fwmark 0x11 priority $ip_rule_priority table ping
	ip rule del iif lo fwmark 0x11 priority $ip_rule_priority_unreachable table ping_unreachable 2>/dev/null
	ip rule add iif lo fwmark 0x11 priority $ip_rule_priority_unreachable table ping_unreachable

	#no check of gateway, it might not return icmp reply, also
	#it might not be reachable because of routing rules 
		
	#add ping hosts to special ping table
	ip route flush table ping
	ip route flush table ping_unreachable

	#add route to gateway, to avoid routing via freifunk
	ip route add $via/32 dev $dev table ping

	# ping must be working for at least the half of IPs
	IFS=' '
	numIPs=0
	for ip in $gw_ping
	do
		$DEBUG && echo "add ping route ip:$ip"
		ip route add $ip via $via dev $dev table ping
		ip route add unreachable $ip table ping_unreachable
		$DEBUG && echo "route:$(ip route get $ip)"
		$DEBUG && echo "route via:$(ip route get $via)"
		numIPs=$((numIPs+1))
	done
	echo "number IPs: $numIPs"

	$DEBUG && ip ro li ta ping
	
	#activate routes
	ip route flush cache

	#run check
	ok=false
	countSuccessful=0
	minSuccessful=$(( (numIPs+1)/2 ))
	if [ $minSuccessful -lt 4 ]; then minSuccessful=4; fi
	echo "minSuccessful: $minSuccessful"

	IFS=' '
	for ip in $gw_ping
	do
		$DEBUG && echo "ping to: $ip"
		ping -c 2 -w 10 $ip  2>&1 && countSuccessful=$((countSuccessful+1))
		
		if [ $countSuccessful -ge $minSuccessful ]; then
			ok=true
			break
		fi

	done

	logger -s -t "$LOGGER_TAG" "ok: $ok"

	if $ok; then
		$DEBUG && echo "gateway found: via $via dev $dev (landev:$default_lan_ifname, wandev=$default_wan_ifname)"

		#VSERVER: we have found a gateway (either via eth0 or openvpn) -> offer gateway service
		#VSERVER: keep local_gateway untouched. it is setup by S40network (not detected)
		#VSERVER: but it needs to be re-checkt. because if network is down, default route is removed from routing table and 
		#VSERVER: must be readded
		#VSERVER:  - it ensures that host has always a working gateway. 

		dev_is_vpn=1	#default
		#always add wan or lan to local gateway
		if [ "$dev" = "$default_lan_ifname" -o "$dev" = "$default_wan_ifname" ]; then	
			logger -s -t "$LOGGER_TAG" "Set local gateway: dev:$dev, ip:$via"
			setup_gateway_table $dev $via local_gateway
			dev_is_vpn=0	# reset	
		fi

		$DEBUG && echo "dev_is_vpn=$dev_is_vpn"
		logger -s -t "$LOGGER_TAG" "dev_is_vpn: $dev_is_vpn"

		# Add any gateway to public table if internet was enabled.
		# If internet is disabled, add only vpn if detected.
		# When lan/wan gateway gets lost, also vpn get lost
		# If only vpn get lost, remove public gateway
		if [ "$(nvram get ddmesh_disable_gateway)" = "0" -a "$dev_is_vpn" = "1" ]; then
			logger -s -t "$LOGGER_TAG" "Set public gateway: dev:$dev, ip:$via"
			setup_gateway_table $dev $via public_gateway

			/etc/init.d/S52batmand gateway

			# select correct dns 
			BIND_FORWARDER_FILE="/etc/bind/openvpn.forwarder"
			rm -f $BIND_FORWARDER_FILE
			ln -s $BIND_FORWARDER_FILE.$dev $BIND_FORWARDER_FILE
			service bind9 reload
			echo "DNS:"
			cat $BIND_FORWARDER_FILE
		else
			logger -s -t "$LOGGER_TAG" "Clear public gateway."
			ok=false
		fi
		
		break;
	fi

done
unset IFS

ip route flush table ping
ip route flush table ping_unreachable
ip rule del iif lo fwmark 0x11 priority $ip_rule_priority table ping >/dev/null
ip rule del iif lo fwmark 0x11 priority $ip_rule_priority_unreachable table ping_unreachable >/dev/null

if ! $ok; then
	$DEBUG && echo "no gateway"
	logger -s -t "$LOGGER_TAG" "no gateway"

	#remove all in default route from public_gateway table
	ip route flush table public_gateway 2>/dev/null
	/etc/init.d/S52batmand no_gateway

	# when we have a openvpn network interface and ok=false
	# then openvpn is dead
	if [ -n "$default_vpn_route_list" ]; then
		logger -s -t "$LOGGER_TAG" "openvpn connection is dead -> restarting"
		service openvpn restart
	fi
fi

$DEBUG && echo "end."
logger -s -t "$LOGGER_TAG" "gateway check end."
exit 0
