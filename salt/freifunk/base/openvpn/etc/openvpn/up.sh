#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###

#cmd tun_dev tun_mtu link_mtu ifconfig_local ifconfig_remote
logger -t "ovpn up.sh" "cmd:$cmd dev:$dev tun_mtu:$tun_mtu link_mtu:$link_mtu ifconfig_local:$ifconfig_local ifconfig_remote:$ifconfig_remote"

#make a point-to-point connection with "route_vpn_gateway" because this was working for
#ovpn.to; Freie Netze e.V.;CyberGhost
ifconfig "$dev" "$ifconfig_local" dstaddr "$route_vpn_gateway" mtu "$tun_mtu"

m="${dev#vpn}"
ip route add default dev "$dev" via "$route_vpn_gateway" table gateway_pool metric "$m"

iptables -w -t nat -A POSTROUTING -o "$dev" -j SNAT --to-source "$ifconfig_local"

#update gateway infos and routing tables, fast after openvpn open connection
#Run in background, else openvpn blocks. but avoid restarting ovpn by check-script
#if no connection could be made. this would produces a permanent fast restart loop of
#openvpn
/usr/local/bin/freifunk-gateway-check.sh &

BIND_FORWARDER_FILE="/etc/bind/vpn.forwarder.$dev"
DEFAULT_DNS="194.150.168.168; 46.182.19.48;"		# semicolon is IMPORTANT

# flush public_dns routing table
ip route flush table public_dns

# parse any other foreign options to setup DNS for bind9.
# all local resolv goes via /etc/resolv.conf.
# any other resolving come from freifunk network and are processed by bind9
# here I create a configuration fragment which is included in /etc/bind/named.conf.options
dns_list=''
for opt in ${!foreign_option_*};
do
	#print all remote option that should be set
	logger -t "ovpn up.sh" "$opt=${!opt}"

	x="${!opt}"
	if [ -n "$(echo "$x" | sed -n '/^dhcp-option DNS/p')" ]; then
		dns="${x#*dhcp-option DNS}"
		dns_list+="$dns;"

		# add public dns to routing table
		ip route add "$dns" dev "$dev" table public_dns
	fi

done

#if openvpn did not deliver DNS, use default DNS
test -z "$dns_list" && dns_list="$DEFAULT_DNS"

#write data
cat<<EOM >"$BIND_FORWARDER_FILE"
//updated at $(date) by $0
forwarders {
	$dns_list
};
EOM

# correct forwarder file is selected by /usr/local/bin/freifunk-gateway-check.sh

#tell always "ok" to openvpn;else in case of errors of "ip route..." openvpn exits
exit 0
