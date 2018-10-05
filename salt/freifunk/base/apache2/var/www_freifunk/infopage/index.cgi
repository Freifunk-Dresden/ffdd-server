#!/bin/sh

echo 'Content-type: text/plain txt'
echo ''

cat <<EOM

#-------------------
#bgp-server dresden1
#-------------------

#ping ip to check if the network behind IC-VPN server is reachable. IP should be one from network and
#not from the transfer net (10.207.x.y), because this is already known to each IC-VPN Server
ping_ip=10.200.0.1

#topology url to retrieve the network dot-topology from (seen from same node). Allows to
#create a global freifunk graph.
topo_url=http://10.200.0.1/info/dresden.dot

#to build a global network graphic from each dot-file (defined by topo_url), a "port" must be specified.
#"port" is the server or node that represents the network gateway (router).
#The string that is specified here is the name of the node in the dot-file that is the router that routes the
#traffic in to the city network. 
# ... DD_Node ---- BGB_Router ----- IC_VPN ---- BGB_Router --- Augsburg_Node ....
topo_dot_port="10.200.0.1"

#internal web portal that may be different to the public city freifunk internet presence.
#it is only reachable from within the city networks.
portal_ip=10.200.0.1

#public web portal host. This is reachable from internet.
public_portal_url=http://www.ddmesh.de/

#--- optional information ---
#server status
EOM

echo "uptime=$(uptime)"
exit 0
