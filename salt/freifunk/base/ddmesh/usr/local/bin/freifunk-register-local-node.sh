#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###

printf 'usage: register_node.sh [new_node]\n\n'

ddmesh_node="$(uci -qX get ffdd.sys.ddmesh_node)"
ddmesh_key="$(uci -qX get ffdd.sys.ddmesh_registerkey)"

[ "$ddmesh_node" = '-' ] && ddmesh_node=''
if [ -z "$ddmesh_key" ] || [ "$ddmesh_key" = '-' ]; then
	ddmesh_key="$(ip link | sha256sum | sed 's#\(..\)#\1:#g;s#[ :-]*$##')"
	uci set ffdd.sys.ddmesh_registerkey="$ddmesh_key"
	uci commit
fi

#vserver
#if node was changed to valid range 0->100 than a change back is not possible
#node=1
#key="_dummy_reserved:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"

printf 'local node: [%s]\n' "$ddmesh_node"
printf 'local key: [%s]\n\n' "$ddmesh_key"

printf 'Try to register node [%s], key [%s]\n\n' "$ddmesh_node" "$ddmesh_key"
node_info="$(wget -O - --ca-certificate=/etc/ssl/certs/ca-root-ffdd.pem "https://selfsigned.register.freifunk-dresden.de/bot.php?node=$ddmesh_node&registerkey=$ddmesh_key" 2>/dev/null)"


cmd="$(echo "$node_info" | sed -n '/^OK/p;/^ERROR/p;/^INFO/p')"
case "$cmd" in

  OK*)
	node_id="$(echo "$node_info" | sed -n '/\"node\":/{s#^.*:##;p}')"
	node_id="${node_id//\"/}"
	printf 'node=%s\nupdated.\n' "$node_id"
	printf '\nInfo:\n%s\n' "$node_info"
	;;

  ERROR*)
	printf '%s\n' "$node_info"
	;;

  INFO*)
	printf '%s\n' "$node_info"
	;;

  *)
	printf '%s\n' "$node_info"
	;;

esac

exit 0
