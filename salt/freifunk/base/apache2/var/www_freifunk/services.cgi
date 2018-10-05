#!/bin/sh

export DATE="19.05.2007";SCRIPT=${0#/rom}
export TITLE="Allgemein: Dienste"
. ./cgi-bin-pre.cgi

cat<<EOF
<H2>$TITLE</H2>
<br>
<fieldset class="bubble">
<legend>Angebotene Service</legend>
<table border="0">
<TR><TH class="bubble">Node</TH><TH class="bubble">Service Ip/Port/SeqNo</TH></tr>
EOF

sudo bmxd -c -d7 -b | sed -n '/^Originator.*/,/^$/{/^Originator/d;p}' | sed '
s# \+$##
s#\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\) *\(.*\)#\1;(\2)#
s# \+#)(#g ' | sed -n '
s#\(.*\);\(.*\)$#<tr class="colortoggle1"><td>\1</td><td>\2</td><tr>#g
s#(\([^)(:]\+\):\([^)(:]\+\):\([^)(:]\+\))#<a href="http://\1:\2/">\1:\2</a> - \3<br>#g
p
n
s#\(.*\);\(.*\)$#<tr class="colortoggle2"><td>\1</td><td>\2</td><tr>#g
s#(\([^)(:]\+\):\([^)(:]\+\):\([^)(:]\+\))#<a href="http://\1:\2/">\1:\2</a> - \3<br>#g
p
'

cat<<EOF
</table>
</fieldset>
EOF

. ./cgi-bin-post.cgi
