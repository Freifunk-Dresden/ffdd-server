#!/usr/bin/env bash
# Show additional links only for internal FFDD-Network clients

# FFDD-Network
ALLOWED_IP="10.200.0.0/15"
# get REMOTE_ADDR from CGI ENV
IP="$REMOTE_ADDR"

hostname_short="$(cat /etc/hostname | awk -F'.' '{print $1}')"

check_cidr="/usr/bin/grepcidr $ALLOWED_IP <(echo $IP) >/dev/null"
eval "$check_cidr"

# exclude network != FFDD-Network and NAT'ed Rules from ipX/nodeX.freifunk-dresden.de
if [ "$?" -eq 0 ] && [ "$IP" != '10.200.0.1' ]; then
	# stats
	cat <<-EOM
		<TR><TD><BIG CLASS="plugin">Statistik</BIG></TD></TR>
		<TR><TD><DIV CLASS="plugin"><A CLASS="plugin" TARGET="_blank" HREF="/bind_stats">DNS Stats</A></DIV></TD></TR>
		<TR><TD><DIV CLASS="plugin"><A CLASS="plugin" TARGET="_blank" HREF="/monitorix">Monitorix</A></DIV></TD></TR>
	EOM

	# tools
	if [ "$(uci -qX get ffdd.sys.apache_ddos_prevent)" -eq '0' ]; then
		cat <<-EOM
			<TR><TD><BIG CLASS="plugin">Tools</BIG></TD></TR>
			<TR><TD><DIV CLASS="plugin"><A CLASS="plugin" TARGET="_blank" HREF="http://speedtest.$hostname_short.ffdd/">Speedtest</A></DIV></TD></TR>
		EOM
	fi
fi
