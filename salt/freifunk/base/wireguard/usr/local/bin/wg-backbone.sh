#!/usr/bin/env bash

VERSION='V3.0'

wg_ifname='tbb_wg'
port='5003'
peers_dir='/etc/wireguard-backbone/peers'

if [ -z "$(which uci)" ]; then
	printf "Error: command 'uci' not found\n"
	exit 1
fi


local_node="$(uci get ffdd.sys.ddmesh_node)"
eval $(ddmesh-ipcalc.sh -n $local_node)

local_wireguard_ip="${_ddmesh_ip/10\.200\./10.203.}"
local_wgX_ip="$_ddmesh_nonprimary_ip/$_ddmesh_netpre"


start_wg()
{
	# create config section
	if [ -z "$(uci -q get ffdd.wireguard)" ]; then
		uci -q add ffdd wireguard
		uci -q rename ffdd.@wireguard[-1]='wireguard'
	fi

	# upgrade: move config option 'restrict'
	if [ -n "$(uci -q get ffdd.sys.wireguard_restrict)" ]; then
		uci set ffdd.wireguard.restrict="$(uci -q get ffdd.sys.wireguard_restrict)"
		uci -q delete ffdd.sys.wireguard_restrict
		uci commit
	fi

	# create key
	secret="$(uci -q get ffdd.wireguard.secret)"
	if [ -z "$secret" ]; then
		printf 'create wireguard key\n'
		secret="$(wg genkey)"
		uci -q set ffdd.wireguard.secret="$secret"
	fi

	# store public
	public=$(echo "$secret" | wg pubkey)
	uci -q set ffdd.wireguard.public="$public"

	# set unused days delete timeout
	if [ -z "$(uci -q get ffdd.wireguard.unused_days)" ]; then
		uci -q set ffdd.wireguard.unused_days=30
	fi

	# save config
	uci commit

	secret_file="$(tempfile)"
	echo "$secret" > "$secret_file"

	# create interface
	printf 'create wireguard interface [%s]\n' "$wg_ifname"

	ip link add "$wg_ifname" type wireguard
	ip link set "$wg_ifname" mtu 1320
	ip addr add "$local_wireguard_ip/32" dev "$wg_ifname"
	wg set "$wg_ifname" private-key "$secret_file"
	wg set "$wg_ifname" listen-port "$port"
	ip link set "$wg_ifname" up
	rm "$secret_file"

	ip rule add to 10.203.0.0/16 table main prio 304
	ip route add 10.203.0.0/16 dev "$wg_ifname" src "$local_wireguard_ip"
	WAN_DEV="$(uci get ffdd.sys.ifname)"
	iptables -w -D INPUT -i "$WAN_DEV" -p udp --dport "$port" -j ACCEPT
	iptables -w -I INPUT -i "$WAN_DEV" -p udp --dport "$port" -j ACCEPT
	iptables -w -D INPUT -i "$wg_ifname+" -j ACCEPT
	iptables -w -I INPUT -i "$wg_ifname+" -j ACCEPT
}


stop_wg()
{
	LS="$(which ls)"
	IFS='
'
	for i in $($LS -1d  /sys/class/net/$wg_ifname* 2>/dev/null | sed 's#.*/##')
	do
		[ "$i" != "$wg_ifname" ] && bmxd -c dev=-"$i"
		ip link del "$i" 2>/dev/null
	done
	unset IFS

	ip rule del to 10.203.0.0/16 table main prio 304
}

accept_peer()
{
	node="$1"
	key="$2"
	store="$3"	# if 1 it will write config


	eval $(ddmesh-ipcalc.sh -n $node)
	echo "DEVEL: manuall calculation of _ddmesh_wireguard_ip"
	remote_wireguard_ip="${_ddmesh_ip/10\.200\./10.203.}"

	wg set "$wg_ifname" peer "$key" persistent-keepalive 25 allowed-ips "$remote_wireguard_ip"/32

	# add ipip tunnel
	sub_ifname="$wg_ifname$node"
	ip link add "$sub_ifname" type ipip remote "$remote_wireguard_ip" local "$local_wireguard_ip"
	ip addr add "$local_wgX_ip" broadcast "$_ddmesh_broadcast" dev "$sub_ifname"
	ip link set "$sub_ifname" up

	bmxd -c dev="$sub_ifname" /linklayer 1

	if [ "$store" = "1" ]; then
		echo "node $node" > "$peers_dir/accept_$node"
		echo "key $key" >> "$peers_dir/accept_$node"
	fi
}

remove_peer()
{
	peertype="$1"
	node="$2"
	key="$3"
	wg set "$wg_ifname" peer "$key" remove
	rm "$peers_dir/${peertype}_${node}"
}

load_accept_peers()
{
	for peer in $(ls $peers_dir/accept_* 2>/dev/null)
	do
		eval "$(awk '/^node/{printf("node=%s\n",$2)} /^key/{printf("key=%s\n",$2)}' $peer)"
		accept_peer "$node" "$key" 0
	done
}

connect_peer()
{
	host="$1"
	port="$2"
	node="$3"
	key="$4"
	store="$5" # if 1, then config is saved to "peers" directory

	eval $(ddmesh-ipcalc.sh -n $node)
	echo "DEVEL: manuall calculation of _ddmesh_wireguard_ip"
	remote_wireguard_ip="${_ddmesh_ip/10\.200\./10.203.}"

	wg set "$wg_ifname" peer "$key" persistent-keepalive 25 allowed-ips "$remote_wireguard_ip"/32 endpoint $host:$port

	# add ipip tunnel
	sub_ifname="$wg_ifname$node"
	ip link add "$sub_ifname" type ipip remote "$remote_wireguard_ip" local "$local_wireguard_ip"
	ip addr add "$local_wgX_ip" broadcast "$_ddmesh_broadcast" dev "$sub_ifname"
	ip link set "$sub_ifname" up

	bmxd -c dev="$sub_ifname" /linklayer 1

	if [ "$store" = "1" ]; then
		filename="$peers_dir/connect_$node"
		echo "host $host" > "$filename"
		echo "port $port" >> "$filename"
		echo "node $node" >> "$filename"
		echo "key $key" >> "$filename"
	fi

}

load_connect_peers()
{
	for peer in $(ls $peers_dir/connect_* 2>/dev/null)
	do
		eval "$(awk '/^host/{printf("host=%s\n",$2)} /^port/{printf("port=%s\n",$2)} /^node/{printf("node=%s\n",$2)} /^key/{printf("key=%s\n",$2)}' $peer)"
		connect_peer "$host" "$port" "$node" "$key" 0
	done
}

returnJsonError()
{
 reason="$1"
 echo "{\"status\" : \"error\", \"reason\":\"$reason\"}"
}

case $1 in
	start)
		test ! -d "$peers_dir" && mkdir -p "$peers_dir"
		start_wg
		load_accept_peers
		load_connect_peers
		;;

	stop)
		stop_wg
		;;

	reload)
		load_accept_peers
		load_connect_peers
		;;

	accept)
		node="$2"
		key="$3"
		if [ -z "$3" ]; then
			printf 'missing parameters\n'
			exit 1
		fi
		# check if we have already accepted for this node
		# It prevents accidential overwriting working configs
		if [ -f "$peers_dir/accept_$node" ]; then
			printf 'Error: node already accepted\n'
			exit 2
		fi
		accept_peer "$node" "$key" 1
		;;

	delete-accepted)
		node=$2
		if [ -z "$2" ]; then
			printf 'missing parameters\n'
			exit 1
		fi

		eval "$(awk '/^node/{printf("node=%s\n",$2)} /^key/{printf("key=%s\n",$2)}' $peers_dir/accept_$node )"

		read -s -p "delete $node [y/N]: " -n 1 -a input && echo ${input[0]}
		if [ "${input[0]}" = "y" ]; then
			remove_peer "accept" $node $key
			printf 'peer %s deleted\n' "$node"
		else
			printf 'keep peer %s\n' "$node"
		fi
		;;

	connect)
		host="$2"
		port="$3"
		node="$4"
		key="$5"
		if [ -z "$5" ]; then
			printf 'missing parameters\n'
			exit 1
		fi
		# check if we have already accepted for this node
		# It prevents accidential overwriting working configs
		if [ -f "$peers_dir/connect_$node" ]; then
			printf 'Error: config for node already stored\n'
			exit 1
		fi
		connect_peer "$host" "$port" "$node" "$key" 1
		;;

	register)
		mynode="$(uci -q get ffdd.sys.ddmesh_node)"
		host="$2"
		[ -z "$host" ] && return 1

		privKey="$(uci -q get ffdd.wireguard.secret)"
		[ -z "$privKey" ] && { returnJsonError "no private wg key";	exit 1; }

		pubKey="$(echo "$privKey" | wg pubkey)"
		[ -z "$privKey" ] && { returnJsonError "no public wg key";	exit 1; }

		json="$(wget -qO - "http://${host}/wg.cgi?node=${mynode}&key=${pubKey}" 2>/dev/null)"
		[ -z "$json" ] && { returnJsonError "connection failed";	exit 1; }

		echo ${json}
		eval $(echo "$json" | jq --raw-output -e '"node=\"\(.server.node)\"; key=\"\(.server.key)\"; port=\"\(.server.port)\""')
		connect_peer "$host" "$port" "$node" "$key" 1
		;;

	delete-connect)
		node=$2
		if [ -z "$2" ]; then
			printf 'missing parameters\n'
			exit 1
		fi

		eval "$(awk '/^node/{printf("node=%s\n",$2)} /^key/{printf("key=%s\n",$2)}' $peers_dir/connect_$node )"

		read -s -p "delete $node [y/N]: " -n 1 -a input && echo ${input[0]}
		if [ "${input[0]}" = "y" ]; then
			remove_peer "connect" $node $key
			printf 'peer %s deleted\n' "$node"
		else
			printf 'keep peer %s\n' "$node"
		fi
		;;
	status)
		wg show "$wg_ifname"
		;;

	show-pubkey)
		wg show "$wg_ifname" public-key
		;;

	*)
		printf '%s Version %s\n' "$(basename $0)" "$VERSION"
		printf '%s [start | stop | reload | status | show-pubkey | accept <node> <pubkey> | delete-accepted <node> | register <server> | connect <host> <port> <node> <key>] | delete-connect <node>\n\n' "$(basename $0)"
		;;
esac
