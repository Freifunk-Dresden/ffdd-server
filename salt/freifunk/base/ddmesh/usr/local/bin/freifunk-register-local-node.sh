#!/usr/bin/env bash
# (Salt managed)

echo "usage: register_node.sh [new_node]"
echo ""

node="$(nvram get ddmesh_node)"
key="$(nvram get ddmesh_registerkey)"

#vserver
#if node was changed to valid range 0->100 than a change back is not possible
#node=1
#key="_dummy_reserved:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"

echo "local node: [$node]"
echo "local key: [$key]"

echo "Try to register node [$node], key [$key]"
n="$(wget -O - "http://register.freifunk-dresden.de/bot.php?node=$node&registerkey=$key" 2>/dev/null)"

cmd=$(echo "$n" | sed -n '/^OK/p;/^ERROR/p;/^INFO/p' )
case "$cmd" in
	OK*) 
			node=$(echo $n | sed 's#.*:\([0-9]\+\).*#\1#')
			echo "node=$node"
			echo "updated."
			
		;;
	ERROR*) 	echo $n
		;;
	INFO*)		echo $n
		;;
	*)		echo $n
		;;
esac
