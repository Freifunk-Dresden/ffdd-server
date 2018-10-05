#!/usr/bin/env bash
# (Salt managed)

f="/var/log/conntrack.log"

d="$(date)"
n1="$(/sbin/sysctl -a|grep -i 'net.netfilter.nf_conntrack_max')"
n2="$(/sbin/sysctl -a|grep -i 'net.nf_conntrack_max')"
c="$(/sbin/sysctl net.netfilter.nf_conntrack_count)"

echo "conntrack: $d: $n1, $n2, $c" >> $f
echo "conntrack: $d: $n1, $n2, $c"
