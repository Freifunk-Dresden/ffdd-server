#!/bin/sh

export DATE="28.10.2018";SCRIPT=${0#/rom}
export TITLE="Allgemein: Status"
. ./cgi-bin-pre.cgi

cat<<EOF
<h2>$TITLE</h2>
<br>
<fieldset class="bubble">
<legend>Allgemeines</legend>
<table>
<TR><th>Ger&auml;telaufzeit:</th><TD>$(uptime)</TD></TR>
<TR><th>Prozesse:</th><TD>$(ps --no-headers xa | wc -l)</TD></TR>
<TR><th>System:</th><TD>$(uname -a)</TD></TR>
</table>
</fieldset>
EOF

. ./cgi-bin-post.cgi
