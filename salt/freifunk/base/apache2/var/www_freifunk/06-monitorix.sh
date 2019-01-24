#!/usr/bin/env bash
# Show Monitorix Link only for internal FFDD-Network clients

# FFDD-Network
ALLOWED_IP="10.200.0.0/15"
# get REMOTE_ADDR from CGI ENV
IP="$REMOTE_ADDR"

check_cidr="/usr/bin/grepcidr $ALLOWED_IP <(echo $IP) >/dev/null"
eval "$check_cidr"

# exclude network != FFDD-Network and NAT'ed Rules from ipX/nodeX.freifunk-dresden.de
if [ "$?" -eq 0 ] && [ "$IP" != '10.200.0.1' ]; then
	cat <<-EOM
		<TR><TD><DIV CLASS="plugin"><A CLASS="plugin" TARGET="_blank" HREF="/monitorix">Monitorix</A></DIV></TD></TR>
	EOM
fi
