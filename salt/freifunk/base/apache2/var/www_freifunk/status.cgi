#!/bin/sh

export DATE="28.10.2018";SCRIPT=${0#/rom}
export TITLE="Allgemein: Status"
. ./cgi-bin-pre.cgi

cat<<EOF
<h2>$TITLE</h2>
<br>
<fieldset class="bubble">
<legend>Kontakt</legend>
<table>
<TR><th width=250px>Name:</th><TD>$(/usr/local/bin/nvram get contact_name)</TD></TR>
<TR><th width=250px>E-Mail:</th><TD>$(/usr/local/bin/nvram get contact_email)</TD></TR>
</table>
</fieldset>
<br>
<fieldset class="bubble">
<legend>Allgemeines</legend>
<table>
<TR><th>Knoten-IP-Adresse:</th><TD>$(ip addr show bmx_prime | awk '/inet/ {print $2}' | sed 's/\/.*//')</TD></TR>
<TR><th>Nameserver:</th><TD>$(grep nameserver /etc/resolv.conf | sed 's#nameserver##g')</TD></TR>
<TR><th>Ger&auml;telaufzeit:</th><TD>$(uptime)</TD></TR>
<TR><th>Prozesse:</th><TD>$(ps --no-headers xa | wc -l)</TD></TR>
<TR><th>System:</th><TD>$(uname -a)</TD></TR>
<TR><th>Firmware-Version:</th><TD>Freifunk Dresden Server Edition $(cat /etc/freifunk-server-version)</TD></TR>
<TR><th>Freier Speicher:</th><TD>$(cat /proc/meminfo | grep MemFree | cut -d':' -f2) von $(cat /proc/meminfo | grep MemTotal | cut -d':' -f2)</TD></TR>
</table>
</fieldset>
<br>
<fieldset class="bubble">
<legend>Service Status</legend>
<table>
<TR><th colspan="1">&nbsp;</th><th>Active-State</th></TR>
$(
	services='S40network S41firewall S42firewall6 S52batmand S53backbone-fastd2 S90iperf3 fail2ban bind9 apache2 monitorix openvpn@openvpn openvpn@openvpn1'
	for s in $services
	do
		printf '<TR><th width=250px>%s:</th>' "$s"
		if [ "$(systemctl show -p ActiveState $s | cut -d'=' -f2 | grep -c inactive)" -lt 1 ]; then
			printf '<TD><img src="/images/yes.png"></TD>'
		else
			printf '<TD><img src="/images/no.gif"></TD>'
		fi
		printf '</TR>\n'
	done
)
</table>
</fieldset>
EOF

. ./cgi-bin-post.cgi
