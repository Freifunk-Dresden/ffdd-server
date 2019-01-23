#!/bin/sh
echo Content-type: text/html
echo

eval $(ddmesh-ipcalc.sh -n $(nvram get ddmesh_node))
nodeid="$(nvram get ddmesh_node)"

#apache does not proxy to local website -> need to extract ".freifunk.dyndns.org" if present
#BASE=$HTTP_HOST
#EXT_BASE=$(echo $HTTP_HOST | sed -n 's#[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\.\(ddmesh.de\)#.\1#p')
#<BASE href="http://$BASE/">

cat<<EOF
<HTML>
<HEAD>
<TITLE>FFDD VPN - Node $nodeid - $TITLE</TITLE>
<META CONTENT="text/html; charset=utf-8" HTTP-EQUIV="Content-Type">
<META CONTENT="no-cache" HTTP-EQUIV="cache-control">
<meta http-equiv="expires" content="0">
<LINK HREF="/css/ff.css" REL="StyleSheet" TYPE="text/css">
<link rel="shortcut icon" href="/images/favicon.ico">
<meta name="author" content="Stephan Enderlein">
<meta name="robots" content="noindex">
</HEAD>

<BODY>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" CLASS="body">
<TR><TD class="navihead" COLSPAN="5" HEIGHT="22">
EOF

if [ -z "$NOMENU" ] 
then
 cat<<EOM
 <SPAN CLASS="color"><A CLASS="color" HREF="/">Home</A></SPAN>
 <IMG ALT="" HEIGHT="10" HSPACE="2" SRC="/images/vertbar.gif" WIDTH="1">
EOM
fi

cat<<EOM
 <SPAN CLASS="color"><A CLASS="color" HREF="http://www.freifunk-dresden.de/">Dresden-Freifunk</A></SPAN>
EOM


cat<<EOF
</TD></TR>
<TR><TD HEIGHT="5" COLSPAN="5"></TD></TR>
<TR>
<TD COLSPAN="5"><TABLE WIDTH="100%" BORDER="0" CELLPADDING="0" CELLSPACING="0">
 <TR><TD HEIGHT="33"><font size="4"><b>$(/usr/local/bin/nvram get servername)</b></font></TD>
 <TD ALIGN="right" HEIGHT="33"></TD>
<TD HEIGHT="33" WIDTH="150" valign="bottom"><IMG ALT="" BORDER="0" HEIGHT="33" SRC="/images/ff-logo-1r.gif" WIDTH="150"></TD></tr>
 </TABLE></TD> 
</TR><tr><td COLSPAN="5"><table class="navibar" width="100%" CELLPADDING="0" CELLSPACING="0">
<TR>
<TD COLSPAN="4" HEIGHT="19">&nbsp;v$(uname -a)</TD>
<TD HEIGHT="19" WIDTH="150"><IMG ALT="" BORDER="0" HEIGHT="19" SRC="/images/ff-logo-2.gif" WIDTH="150"></TD>
</TR></table></td></tr>
<TR>
<TD class="ie_color" VALIGN="top" HEIGHT="100%" WIDTH="150">
<table HEIGHT="100%" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="150" style="table-layout: inherit">
 <tr><TD class="ie_white" HEIGHT="5"  VALIGN="top" WIDTH="150"></td></tr>
 <tr><TD class="navi" HEIGHT="100%" VALIGN="top" WIDTH="150">
 <table VALIGN="top" border="0" width="150">
EOF

if [ -z "$NOMENU" ]
then
	for inc in [0-9][0-9]-*; do
		# menu may be a script that generates html
		if [ "${inc#*.}" = "sh" ]; then
			/bin/sh $inc
		else
			cat $inc;
		fi
	done
fi

cat<<EOF
</table></TD></tr>
</table>
</TD>
<TD WIDTH="5"></TD>
<TD VALIGN="top">
<table HEIGHT="100%" BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
<tr><TD HEIGHT="5"  VALIGN="top"  WIDTH="100%"></td></tr>
<tr><td VALIGN="top" HEIGHT="100%" WIDTH="100%">
EOF
