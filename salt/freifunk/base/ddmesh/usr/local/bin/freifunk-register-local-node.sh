#!/usr/bin/env bash
# (Salt managed)

printf 'usage: register_node.sh [new_node]\n\n'

node="$(nvram get ddmesh_node)"
key="$(nvram get ddmesh_registerkey)"

#vserver
#if node was changed to valid range 0->100 than a change back is not possible
#node=1
#key="_dummy_reserved:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"

printf 'local node: [%s]\n' "$node"
printf 'local key: [%s]\n\n' "$key"

printf 'Try to register node [%s], key [%s]\n\n' "$node" "$key"
n="$(wget -O - "http://register.freifunk-dresden.de/bot.php?node=$node&registerkey=$key" 2>/dev/null)"


cmd="$(echo "$n" | sed -n '/^OK/p;/^ERROR/p;/^INFO/p')"
case "$cmd" in

  OK*)
	node="$(echo $n | sed 's#.*:\([0-9]\+\).*#\1#')"
	printf 'node=%s\nupdated.\n' "$node"
	;;

  ERROR*)
	printf '%s\n' "$n"
	;;

  INFO*)
	printf '%s\n' "$n"
	;;

  *)
	printf '%s\n' "$n"
	;;

esac

exit 0
