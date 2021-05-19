#!/bin/bash
#

wg_ifname='tbb_wg'
peers_dir='/etc/wireguard-backbone/peers'

current_date=$(date +%s)
days30=60*60*24*30

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
            echo "lastseen $lastseen" >> $peerfile
        else
            sed -i "s#lastseen .*#lastseen $lastseen#" $peerfile
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
            current_days30=$(($(($current_date))-$(($days30))))
            if [ $(($lastseen)) -lt $(($current_days30)) ];
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
    if [ ! ${entry[1]} -eq 0 ];
    then
        update_peer ${entry[0]} ${entry[1]}
    fi
done

clean_peers
