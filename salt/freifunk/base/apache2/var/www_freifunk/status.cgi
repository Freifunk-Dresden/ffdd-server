#!/bin/sh

export DATE="28.10.2018";SCRIPT=${0#/rom}
export TITLE="Allgemein: Status"

ddmesh_node="$(nvram get ddmesh_node)"
eval "$(ddmesh-ipcalc.sh -n "$ddmesh_node")"

. ./cgi-bin-pre.cgi

cat<<EOF
<h2>$TITLE</h2>
<br>
<fieldset class="bubble">
<legend>Kontakt</legend>
<table>
<TR><th width="250">Name:</th><TD>$(nvram get contact_name)</TD></TR>
<TR><th width="250">E-Mail:</th><TD>$(nvram get contact_email)</TD></TR>
<TR><th width="250">Location:</th><TD>$(nvram get contact_location)</TD></TR>
<TR><th width="250">Note:</th><TD>$(nvram get contact_note)</TD></TR>
</table>
</fieldset>
<br>
<fieldset class="bubble">
<legend>Allgemeines</legend>
<table>
<TR><th width="250">Internet-Gateway:</th><TD colspan="7">$(
	if [ "$(nvram get ddmesh_disable_gateway)" -eq '0' ]; then
		vpnservice='openvpn@openvpn openvpn@openvpn1'
		vs='0'
		for s in $vpnservice
		do
			[ "$(systemctl show -p ActiveState $s | cut -d'=' -f2 | grep -c inactive)" -lt 1 ] && vs='1'
		done
		if [ "$vs" -eq '1' ]; then printf '<img src="/images/yes.png">'; else printf '<img src="/images/no.gif">'; fi
	else
		vs='0'
		printf '<img src="/images/no.gif">'
	fi
	printf '</TD></TR>\n'

	# Print Selected-Gateway then VPN inactive
	if [ "$vs" -eq '0' ]; then
		SELGW="$(cat /var/lib/freifunk/bmxd/gateways | sed -n 's#^[	 ]*=>[	 ]\+\([0-9.]\+\).*$#\1#p')"
		SELID="$(ddmesh-ipcalc.sh $SELGW)"
		re='^[0-9]+$'
		printf '<TR><th>Selected-Gateway:</th><TD colspan="7">%s %s</TD></TR>\n' "$SELGW" "$(if [[ $SELID =~ $re ]]; then printf '(%s)\n' $SELID; fi)"
	fi
)
<TR><th width="250">Auto-Update:</th><TD colspan="7">$(if [ $(nvram get autoupdate) -eq '1' ]; then printf '<img src="/images/yes.png">'; else printf '<img src="/images/no.gif">'; fi)</TD></TR>
<TR><th>Knoten-IP-Adresse:</th><TD colspan="7">$_ddmesh_ip ($_ddmesh_node)</TD></TR>
<TR><th>Nameserver:</th><TD colspan="7">$(grep nameserver /etc/resolv.conf | sed 's#nameserver##g')</TD></TR>
<TR><th>Ger&auml;telaufzeit:</th><TD colspan="7">$(uptime)</TD></TR>
<TR><th>Prozesse:</th><TD colspan="7">$(ps --no-headers xa | wc -l)</TD></TR>
<TR><th>System:</th><TD colspan="7">$(uname -a)</TD></TR>
<TR><th>Firmware-Version:</th><TD colspan="7">Freifunk Dresden Server Edition - $(cat /etc/freifunk-server-version) (Branch: $(nvram get branch))</TD></TR>
<TR><th>Freier Speicher:</th><TD colspan="7"></TD></TR>
<TR><th width="250"></th><th>Total</th> <th>Used</th> <th>Free</th> <th>Shared</th> <th>Buffered/Cached</th> <th>Available</th><th width="30%">&nbsp;</th></TR>
$(free | sed -n '2,${s#[ 	]*\(.*\):[ 	]*\([0-9]\+\)[ 	]*\([0-9]\+\)[ 	]*\([0-9]*\)[ 	]*\([0-9]*\)[ 	]*\([0-9]*\)[ 	]*\([0-9]*\)#<TR><th>\1</th><td>\2</td><td>\3</td><td>\4</td><td>\5</td><td>\6</td><td>\7</td><td></td></TR>#g;p}')
</table>
</fieldset>
<br>
<fieldset class="bubble">
<legend>Service Status</legend>
<table>
$(
	services='S40network S41firewall S42firewall6 S52batmand S53backbone-fastd2 S90iperf3 fail2ban bind9 apache2 vnstat monitorix openvpn@openvpn openvpn@openvpn1'
	for s in $services
	do
		printf '<TR><th width="250">%s:</th><TD>' "$s"
		if [ "$(systemctl show -p ActiveState $s | cut -d'=' -f2 | grep -c inactive)" -lt 1 ]; then
			printf '<img src="/images/yes.png">'
		else
			printf '<img src="/images/no.gif">'
		fi
		printf '</TD></TR>\n'
	done
)
</table>
</fieldset>
EOF

. ./cgi-bin-post.cgi
