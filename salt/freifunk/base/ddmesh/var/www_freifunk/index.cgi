#!/bin/sh

export DATE="27.11.2019"
export TITLE="Allgemein &gt; Nodes"
. ./cgi-bin-pre.cgi


cat<<EOM
<h2>$TITLE</h2>
<br>
<fieldset class="bubble">
<legend>Direkte Nachbarn</legend>
<table>
<tr><th colspan="2">&nbsp;</th><th colspan="2">Interface</th><th colspan="3">Linkqualit&auml;t</th></tr>
<tr><th>Node</th><th>Ip</th><th>Device</th><th>IP</th><th>RTQ</th><th>vom Nachbarn (RQ)</th><th>zum Nachbarn (TQ)</th></tr>
EOM

sudo /usr/local/bin/bmxd -c --links | awk '
 function getnode(ip) {
 	split($0,a,".");
 	f1=a[3]*255;f2=a[4]-1;
 	return f1+f2;
 }
 BEGIN {c=1;count=0;}
 {

	if(match($0,"^[0-9]+[.][0-9]+[.][0-9]+[.][0-9]"))
	{
 		printf("<tr class=\"colortoggle%d\"><td>%s</td><td><a href=\"http://%s/\">%s</a></td><td>%s</td><td>%s</td><td class=\"quality_%s\">%s</td><td>%s</td><td>%s</td></tr>\n",c,getnode($1),$3,$3,$2,$1,$4,$4,$5,$6);
		if(c==1)c=2;else c=1;
		count=count+1;
	}
 }
 END { printf("<tr><th>Anzahl: </th><td colspan=\"5\">%d</td></tr>", count);}
'

cat<<EOM
</table><br />
<TABLE BORDER="0" cellspacing="0" CELLPADDING="1" WIDTH="100%">
<TR>
<TD class="quality"><div class="quality1"></div>perfekt</TD>
<TD class="quality"><div class="quality2"></div>ausreichend</TD>
<TD class="quality"><div class="quality3"></div>schlecht</TD>
<TD class="quality"><div class="quality4"></div>unbenutzbar</TD></TR>
</TABLE>
</fieldset>
<br>

<fieldset class="bubble">
<legend>Gateways</legend>
<table>
<tr><th>Aktiv</th><th>Node</th><th>Ip</th><th>Best Next Hop</th><th>#</th><th></th></tr>
EOM

sudo /usr/local/bin/bmxd -c --gateways | awk '
 function getnode(ip) {
 	split($0,a,".");
 	f1=a[3]*255;f2=a[4]-1;
 	return f1+f2;
 }
 BEGIN {c=1;count=0;}
 {

	if(match($0,"^[=> 	]*[0-9]+[.][0-9]+[.][0-9]+[.][0-9]"))
 	{
		img=match($0,"=>") ? "<img src=\"/images/yes.png\">" : ""
		gsub("^=>","")
 		rest=substr($0,index($0,$3))
 		gsub("/ ","/",rest)
 		printf("<tr class=\"colortoggle%d\"><td>%s</td><td>%s</td><td><a href=\"http://%s/\">%s</a></td><td>%s</td><td>%s</td></tr>\n",c,img,getnode($1),$1,$1,$2,rest);
		if(c==1)c=2;else c=1;
		count=count+1;
	}
 }
 END { printf("<tr><th>Anzahl: </th><td colspan=\"4\">%d</td></tr>", count);}
'

cat<<EOM
</table>
</fieldset>

<br/>

<fieldset class="bubble">
<legend>Freifunk Knoten</legend>
<table>
<tr><th>Node</th><th>Ip</th><th>BRC</th><th>via Routing Interface</th><th>via Router</th></tr>
EOM

sudo /usr/local/bin/bmxd -c --originators | awk '
 function getnode(ip) {
 	split($0,a,".");
 	f1=a[3]*255;f2=a[4]-1;
 	return f1+f2;
 }
 BEGIN {c=1;count=0;}
 {

	if(match($0,"^[0-9]+[.][0-9]+[.][0-9]+[.][0-9]"))
	{
 		printf("<tr class=\"colortoggle%d\"><td>%s</td><td><a href=\"http://%s/\">%s</a></td><td class=\"quality_%s\">%s</td><td>%s</td><td>%s</td></tr>\n",c,getnode($1),$1,$1,$4,$4,$2,$3);
		if(c==1)c=2;else c=1;
		count=count+1;
	}
 }
 END { printf("<tr><th>Anzahl: </th><td colspan=\"4\">%d</td></tr>", count);}
'

cat<<EOM
</table><br />
</fieldset>
EOM

. ./cgi-bin-post.cgi
