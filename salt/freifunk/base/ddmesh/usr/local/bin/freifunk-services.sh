#!/usr/bin/env bash
# (Salt managed)

#habe das adden disabled, da zu mindestens in der aktuellen version von bmxd
#ein bug drin ist. beim hinzufügen ohne sleep crashed bmxd und manchmal auch bei
#einem sleep von 1. ebenso sind für bmxd die aktuellen verbindugnen und routing einträge
#entfernt und werden erst wieder aktiv wenn das hinzufügen beendet ist.
echo "habe das script abgeschaltet, wegen bug in bmxd -> crashed"
exit 

#-----------------------------------------------------------------
#-------    Services    ------------------------------------------
#-----------------------------------------------------------------
#del current services of this node; batmand -c shows the arguments which contains also later added services
logger -s -t "freifunk.services.sh" "deleting current services..."
for i in $(bmxd -ci | grep service | sed 's#service##') 
do
	bmxd -c --service "-$i" 
done

#add leipzig
if true ;then
logger -s -t "freifunk.services.sh" "adding services from leipzig..."
#get services from Leipzig
count=0
for i in $(wget --timeout 20 --tries 1 -O - http://104.61.71.201/cgi-bin-services.html 2>/dev/null | sed '
/Hops/,/<\/TABLE>/ {
s#<tr>#\n+#g
s#</tr>#\n-#g
}' | sed -n '
/^+/{
s#	##g
s#^+<td><a href="\([^"]*\)..\([^<]*\).*\(udp\|tcp\).*#\1\t\3\t\2#
p
}' | sed 's#^\(.*\)//\([^:]*\):\([^/	]*\)[/	].*$#\2:\3:1#')
do
	count=$((count+1))
	logger -s -t "freifunk.services.sh" " add service from Leipzig ($count): $i"
	bmxd -c --service $i 2>/dev/null >/dev/null
	#sleep is needed to avoid bmxd crash
	sleep 1
done
fi

sleep 5

#add Berlin 
if false;then
logger -s -t "freifunk.services.sh" "adding services from Berlin ..."
#get services from Berlin 
count=0
for i in $(wget --timeout 20 --tries 1 -O - http://104.66.23.1/cgi-bin-services.html 2>/dev/null | sed '
/Hops/,/<\/TABLE>/ {
s#<tr>#\n+#g
s#</tr>#\n-#g
}' | sed -n '
/^+/{
s#	##g
s#^+<td><a href="\([^"]*\)..\([^<]*\).*\(udp\|tcp\).*#\1\t\3\t\2#
p
}' | sed 's#^\(.*\)//\([^:]*\):\([^/	]*\)[/	].*$#\2:\3:1#')
do
	count=$((count+1))
	logger -s -t "freifunk.services.sh" " add service from Berlin ($count): $i"
	bmxd -c --service $i 2>/dev/null >/dev/null
	#sleep is needed to avoid bmxd crash
	sleep 1
done
fi

#add own services
logger -s -t "freifunk.services.sh"  "adding local services..."
#bmxd -c --service

 
#-----------------------------------------------------------------
#-------    HNA    -----------------------------------------------
#-----------------------------------------------------------------
#del old hna
logger -s -t "freifunk.services.sh" "deleting HNA for ic-vpn..."
for i in $(bmxd -ci | grep unicast[_-]hna | sed 's#unicast[_-]hna[ 	]*##')
do
	bmxd -c --unicast-hna "-$i" 
	#sleep is needed to avoid bmxd crash
	sleep 1
done

logger -s -t "freifunk.services.sh" "adding HNA for ic-vpn..."
#--- add freifunk ip ranges
for i in $( ip route list table zebra | cut -d' ' -f1)
do
	logger -s -t "freifunk.services.sh" " add city hna: $i"
	bmxd -c --unicast-hna $i 2>/dev/null >/dev/null
	#sleep is needed to avoid bmxd crash
	sleep 1
done

#--- add icvpn hosts
for i in $( ip route list table zebra | cut -d' ' -f3 | sort -u)
do
	logger -s -t "freifunk.services.sh" " add ic-vpn hna: $i/32"
	bmxd -c --unicast-hna $i/32 2>/dev/null >/dev/null
	#sleep is needed to avoid bmxd crash
	sleep 1
done

#add leipzig hna manually because it has a connection vi vpn
logger -s -t "freifunk.services.sh" "adding HNA for leipzig (openvpn)..."
bmxd -c --unicast-hna 104.61.0.0/16 2>/dev/null >/dev/null
