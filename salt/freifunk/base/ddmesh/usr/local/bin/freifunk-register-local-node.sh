#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###

printf 'usage: register_node.sh [new_node]\n\n'

node="$(uci -qX get ffdd.sys.ddmesh_node)"
key="$(uci -qX get ffdd.sys.ddmesh_registerkey)"

#vserver
#if node was changed to valid range 0->100 than a change back is not possible
#node=1
#key="_dummy_reserved:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"

printf 'local node: [%s]\n' "$node"
printf 'local key: [%s]\n\n' "$key"

printf 'Try to register node [%s], key [%s]\n\n' "$node" "$key"
node_info="$(wget -O - "http://register.freifunk-dresden.de/bot.php?node=$node&registerkey=$key" 2>/dev/null)"


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
