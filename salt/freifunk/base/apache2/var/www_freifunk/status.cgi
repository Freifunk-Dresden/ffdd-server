#!/bin/sh

export DATE="28.10.2018";SCRIPT=${0#/rom}
export TITLE="Allgemein: Status"
. ./cgi-bin-pre.cgi

cat<<EOF
<h2>$TITLE</h2>
<br>
<fieldset class="bubble">
<legend>Kontakt</legend>
<pre>
<b>Name:</b>	$(/usr/local/bin/nvram get contact_name)
<b>Mail:</b>	$(/usr/local/bin/nvram get contact_email)
</pre>
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
EOF

. ./cgi-bin-post.cgi
