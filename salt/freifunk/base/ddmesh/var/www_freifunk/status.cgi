#!/usr/bin/env bash

export DATE="27.11.2019"
export TITLE="Allgemein &gt; Status"

ddmesh_node="$(uci -qX get ffdd.sys.ddmesh_node)"
eval "$(ddmesh-ipcalc.sh -n "$ddmesh_node")"

fastd_restrict="$(uci -qX get ffdd.sys.fastd_restrict)"

. ./cgi-bin-pre.cgi

cat<<EOF
<h2>$TITLE</h2>
<br>
<fieldset class="bubble">
<legend>Kontakt</legend>
<table>
<tr><th width="250">Name:</th><td>$(uci -qX get ffdd.sys.contact_name)</td></tr>
<tr><th width="250">E-Mail:</th><td>$(uci -qX get ffdd.sys.contact_email)</td></tr>
<tr><th width="250">Location:</th><td>$(uci -qX get ffdd.sys.contact_location)</td></tr>
<tr><th width="250">Note:</th><td>$(uci -qX get ffdd.sys.contact_note)</td></tr>
</table>
</fieldset>
<br>
<fieldset class="bubble">
<legend>Allgemeines</legend>
<table>
<tr><th width="250">Internet-Gateway:</th><td colspan="7">$(
	if [ "$(uci -qX get ffdd.sys.ddmesh_disable_gateway)" -eq '0' ]; then
		vpnservice='openvpn@openvpn-vpn0 openvpn@openvpn-vpn1 wg-quick@vpn0 wg-quick@vpn1'
		vs='0'
		for s in $vpnservice
		do
			[ "$(systemctl show -p ActiveState "$s" | cut -d'=' -f2 | grep -c inactive)" -lt 1 ] && vs='1'
		done
		if [ "$vs" -eq '1' ]; then printf '<img src="/images/yes.png" alt="yes">'; else printf '<img src="/images/no.gif" alt="no">'; fi
	else
		vs='0'
		printf '<img src="/images/no.gif" alt="no">'
	fi
	printf '</td></tr>\n'

	# Print Selected-Gateway then VPN inactive
	if [ "$vs" -eq '0' ]; then
		SELGW="$(sed -n 's#^[	 ]*=>[	 ]\+\([0-9.]\+\).*$#\1#p' /var/lib/freifunk/bmxd/gateways)"
		SELID="$(ddmesh-ipcalc.sh "$SELGW")"
		re='^[0-9]+$'
		printf '<tr><th>Selected-Gateway:</th><td colspan="7">%s %s</td></tr>\n' "$SELGW" "$(if [[ $SELID =~ $re ]]; then printf '(%s)\n' "$SELID"; fi)"
	fi
)
<tr><th width="250">Auto-Update:</th><td colspan="7">$(if [ "$(uci -qX get ffdd.sys.autoupdate)" -eq '1' ]; then printf '<img src="/images/yes.png" alt="yes">'; else printf '<img src="/images/no.gif" alt="no">'; fi)</td></tr>
<tr><th>Knoten-IP-Adresse:</th><td colspan="7">$_ddmesh_ip ($_ddmesh_node)</td></tr>
<tr><th>Network ID:</th><td colspan="7">$(uci -qX get ffdd.sys.network_id)</td></tr>
<tr><th >Community Server:</th><td colspan="7">$(if [ "$(uci -qX get ffdd.sys.community_server)" -eq '1' ]; then printf '<img src="/images/yes.png" alt="yes">'; else printf '<img src="/images/no.gif" alt="no">'; fi)</td></tr>
<tr><th>Nameserver:</th><td colspan="7">$(grep nameserver /etc/resolv.conf | sed 's#nameserver##g')</td></tr>
<tr><th>Ger&auml;telaufzeit:</th><td colspan="7">$(uptime)</td></tr>
<tr><th>Prozesse:</th><td colspan="7">$(ps --no-headers xa | wc -l)</td></tr>
<tr><th>System:</th><td colspan="7">$(uname -a)</td></tr>
<tr><th>Firmware-Version:</th><td colspan="7">Freifunk Dresden Server Edition: $(cat /etc/freifunk-server-version)</td></tr>
<tr><th>Freier Speicher:</th><td colspan="7"></td></tr>
<tr><th width="250"></th><th>Total</th> <th>Used</th> <th>Free</th> <th>Shared</th> <th>Buffered/Cached</th> <th>Available</th><th width="30%">&nbsp;</th></tr>
$(free | sed -n '2,${s#[ 	]*\(.*\):[ 	]*\([0-9]\+\)[ 	]*\([0-9]\+\)[ 	]*\([0-9]*\)[ 	]*\([0-9]*\)[ 	]*\([0-9]*\)[ 	]*\([0-9]*\)#<tr><th>\1</th><td>\2</td><td>\3</td><td>\4</td><td>\5</td><td>\6</td><td>\7</td><td></td></tr>#g;p}')
</table>
</fieldset>
<br>
<fieldset class="bubble">
<legend>Service Status</legend>
<table>
$(
	services='S40network S41firewall S42firewall6 S52batmand S53backbone-fastd2 S90iperf3 fail2ban bind9 apache2 vnstat monitorix openvpn@openvpn-vpn0 openvpn@openvpn-vpn1 wg-quick@vpn0 wg-quick@vpn1'
	for s in $services
	do
		# add service infos
		SERVICE_INFO=""
		case "$s" in
			S53backbone-fastd2)
				[ "$fastd_restrict" = "1" ] && SERVICE_INFO="No more new connections allowed"
				;;
		esac

		printf '<tr><th width="250">%s:</th><td>' "$s"
		if [ "$(systemctl show -p ActiveState "$s" | cut -d'=' -f2 | grep -c 'inactive\|failed')" -lt 1 ]; then
			printf '<img src="/images/yes.png" alt="yes">'
		else
			printf '<img src="/images/no.gif" alt="no">'
		fi
		printf '</td>'
		printf '<td>%s</td>' "$SERVICE_INFO"
		printf '</tr>\n'
	done
)
</table>
</fieldset>
EOF

. ./cgi-bin-post.cgi
