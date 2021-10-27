#!/bin/bash
#

wg_ifname='tbb_wg'
peers_dir='/etc/wireguard-backbone/peers'

current_date=$(date +%s)
unused_days=$(uci -qX get ffdd.wireguard.unused_days || echo 30)
unused_days_sec=60*60*24*$unused_days

get_peer_file()
{
    key="$1"

    echo $(grep $key $peers_dir/accept_* | sed 's#:.*##')
}

update_peer()
{
    key="$1"
    lastseen="$2"

    peerfile=$(get_peer_file $key)

    if [ ! -z $peerfile ];
    then
        lastseenFile=$(grep lastseen $peerfile)
        if [ -z "$lastseenFile" ];
        then
            if [ $lastseen -eq 0 ];
            then
                lastseen=$current_date
            fi
            echo "lastseen $lastseen" >> $peerfile
        else
            if [ ! $lastseen -eq 0 ];
            then
                sed -i "s#lastseen .*#lastseen $lastseen#" $peerfile
            fi
        fi
    fi
}

clean_peers()
{
    for file in $peers_dir/accept_*
    do
        node=$(grep node $file | sed 's#node\s*##')
        key=$(grep key $file | sed 's#key\s*##')
        lastseen=$(grep lastseen $file | sed 's#lastseen\s*##')
        if [ ! -z $lastseen ];
        then
            current_unused_date=$(($(($current_date))-$(($unused_days_sec))))
            if [ $(($lastseen)) -lt $(($current_unused_date)) ];
            then
                wg set "$wg_ifname" peer "$key" remove
                rm "$file"
                echo "removed node $node"
            fi
        fi
    done
}


for i in $(wg show $wg_ifname latest-handshakes 2>/dev/null | sed 's#\t#_#')
do
    entry=($(echo $i | sed 's#_#\t#'))
    update_peer ${entry[0]} ${entry[1]}
done

clean_peers
