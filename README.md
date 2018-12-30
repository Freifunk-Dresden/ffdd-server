# Freifunk Dresden: Basic Vserver (current version 1.0.1)
Configures an Debian (8/9) or Ubuntu-Server LTS (16.04) as Freifunk-Dresden Server, that could be used as internet gateway an as basis to add further services.

**[see UPDATE News](https://github.com/cremesk/ffdd-server/blob/master/UPDATES.md)**

**[see Documentation - German](https://wiki.freifunk-dresden.de/index.php/Server_Internes)**

Freifunk Ziel
----
Freifunk hat es sich zum Ziel gesetzt, Menschen möglichst flächendeckend mit freiem WLAN zu versorgen. Freier Zugang zu Informationen ist nicht nur eine Quelle für Wissen, sondern kann sich auch positiv auf die wirtschaftliche und kulturelle Entwicklung einer Stadt, Region und Land auswirken, da das Internet in der heutigen Zeit sicher ein fester Bestandteil des täglichen Lebens geworden ist. Freifunk bietet die Möglichkeit, Internet per WLAN frei zu nutzen - ohne Zugangssperren und sicher, da der Internettraffic via verschlüsselten Internettunnel (VPN) ins Ausland geroutet wird. 

Basic Vserver
----

Dieses Repository bildet die minimale Funktionalität eines Servers für Freifunk Dresden. Der Vserver arbeitet wie
ein Freifunk Knoten und ist soweit konfiguriert, dass dieser eine Knotenwebseite anbietet, Backboneverbindungen
(fastd2) akzeptiert und via Openvpn Internettunnel für den Internetverkehr aus dem Freifunknetz aufbauen kann.

**HINWEIS:**
Der Vserver ist auf Freifunk Dresden zugeschnitten. Soll dieses als Basis für andere Freifunk Communities
verwendet werden, müssen Anpassungen gemacht werden.

- Es empfielt sich dringend für andere Communities, dieses Repository zu clonen, da hier generelle Umstellungen zusammen mit der passenden Firmware für Dresdener Anforderungen erfolgen.<br/>
Communities sollten dann auf das geclonte Repository (gilt auch für das "firmware" Repository) aufbauen. Jede Community trägt die alleinige Verantwortung und Kontrolle über ihr Netz und sollte eigene Erfahrene Leute/Admins bereitstellen. Hilfe von Dresden ist aber jederzeit möglich, aber Administrative Aufgaben oder Garantien werden nicht übernommen, da das einfach den organisatorischen Aufwand sprengt.<br/>
Wir wissen selber nicht, wie sich das Netz in Zukunft noch verhält, wenn dieses weiter wächst.

- Routingprotokoll BMXD:
  Diese Protokoll wurde anstelle von bmx6 oder bmx-advanced aus verschiedenen Gründen gewählt<br/>
  (siehe http://wiki.freifunk-dresden.de/). Es wird vom eigentlich Author nicht mehr weiterentwickelt oder gepflegt. Für die Dresdener-Firmware wurden einige Fehler behoben.

- Anpassungen:
  Speziell gilt das für den IP Bereich und der Knotenberechnung. Aus Knotennummern werden mit ddmesh-ipcalc.sh alle notwendigen IP Adressen berechnet. (siehe [Technische Information](http://wiki.freifunk-dresden.de/index.php/Technische_Information#Berechnung_IP_Adressen))<br/>
  <br/>
  Freifunk Dresden verwendet zwei IP Bereiche, eines für die Knoten selber (10.200.0.0/16) und eines für das Backbone (10.201.0.0/16). Dieses ist technisch bedingt. Wird bei freifunk.net nur ein solcher Bereich reserviert (z.b. 10.13.0.0/16), so muss das Script ddmesh-ipcalc.sh in der Berechnung angepasst werden, so dass zwei separate Bereich entstehen. Die Bereiche für 10.13.0.0/16 würden dann 10.13.0.0/17 und 10.128.0.0/17 sein.<br/>
  <br/>
  Das Script ddmesh-ipcalc.sh wird ebenfalls in der Firmware verwendet, welches dort auch angepasst werden muss.<br/>
  In der Firmware gibt es zwei weitere Stellen, die dafür angepasst werden müssen. Das sind /www/nodes.cgi und /www/admin/nodes.cgi. Hier wurde auf den Aufruf von ddmesh-ipcalc.sh verzichtet und die Berechnung direkt gemacht, da die Ausgabe der Router-Webpage extrem lange dauern würde.<br/>
  <br/>
  In  /etc/nvram.conf werden die meisten Einstellungen für den Vserver hinterlegt.<br/>
  Evt. kann noch /etc/issuer.net angepasst werden, was beim Betreiben von mehreren Vservern hilfreich ist.

- Weiterhin verwendet das Freifunk Dresden Netz als Backbone-VPN Tool fastd2.
  
  fastd2 ist ein für Freifunk entwickeltes VPN, welches eine schnelle und zuverlässige Verbindung bereitstellt.<br/>
  Bei der aktuellen Installation werden alle Verbindungen von Freifunk-Router zum Server zugelassen, welche sich mit dem korrekten Public-Key des Servers verbinden. Dieser Public-Key kann über http://<ip-des-knotens>/sysinfo-json.cgi ausgelesen werden.<br/>
  Verbindet sich ein Router mit einem Server erfolgreich, so "lernt" der Server diese Verbindung und erzeugt ein entsprechendes Konfigurationsfile unterhalb von '/etc/fastd/peers2'<br/>
  Später kann der Server umgestellt werden, so dass nur noch dort abgelegte Konfigurationen (Verbindungen) akzeptiert werden. Gesteuert wird dieses durch das Konfigurationsfile von fastd (/etc/fastd/fastd2.conf).
 
- /etc/openvpn enthält ein Script, mit dem verschiede Openvpn Konfiguration von Tunnelanbietern so aufbereitet werden, das diese für Freifunk Dresden richtig arbeiten.
Wie in der Firmware läuft per cron.d ein Internet-check, der in der ersten Stufe das lokale Internet testet und wenn dieses funktioniert, wird das Openvpn Internet geprüft. Ist das Openvpn Internet verfügbar, wird dieser Vserver als Internet-Gateway im Freifunknetz bekannt gegeben.

- Auch der Vserver arbeitet als DNS Server für die Knoten, die ihn als Gateway ausgewählt haben. Der Vserver leitet allerdings die DNS Anfragen nicht über den Openvpn Tunnel, sondern geht direkt über den VServer Anbieter raus.

- Da VServer Anbieter verschieden sind, kann die Installation abbrechen. Hier sollten erfahrene Leute die Installation anpassen und mir einen Hinweis geben. Als Vserver kann **NICHT** jeder Anbieter genutzt werden.
<br/>

**Wichtig** ist, dass tun/tap devices und alle möglichen iptables module möglich sind. IPv6 ist nicht notwendig, da das Freifunk Netz in Dresden nur IPv4 unterstütz (Platzmangel auf Routern, bmxd unterstützt dieses nicht)

Vorausetzungen
----

* Notwendig ist eine Debian (8/9) oder Ubuntu-Server LTS (16.04) Installation.<br/>
  Wähle dafür aber die "Server-⁠Variante" **nicht** Desktop! (Empfehlung: Debian)
* Speicher: mind. 1GByte RAM, 2GByte Swap<br/>
* Netzwerk: min. 100Mbit/s<br/>
  Wenn weniger so sollte man nicht soviele Tunnel aufbauen und die bekanntgegebene Gateway-Geschwindigkeit in /etc/nvram.conf reduzieren. Das sollte man einfach über einen längeren Zeitraum beobachten und den niedrigstens Wert verwenden. Dazu aber den Traffic von verschiedenen Knoten aus testen!
  ```
  batman_gateway_class="4mbit/4mbit"
  ```
* Kernel Module: tun.ko muss vorhanden sein. Evt sollte man sich vorher beim VServer Anbieter informieren. Nicht alle Anbieter haben einen Support im Kernel. Genutzt wird es vom Routing Protokoll, Backbone, Openvpn
* Virtualisierung: Wird der Freifunk Server auf einem virtuellen Server aufgesetzt, so funktionieren als Virtualisierungen KVM, XEN und LXC sehr gut.

Installation
----

* Bringe Debian/Ubuntu auf die aktuelle Version. Das geht bei Ubuntu Schrittweise von Version zu Version.
(https://help.ubuntu.com/community/UpgradeNotes)<br/>

**Wichtig:**<br/>
* _**/etc/hostname**_ _(hostname.domainname.de)_ > Bitte versichert euch nun das euer Hostname korrekt gesetzt ist und der ensprechende DNS Eintrag mit der öffentlichen IP von euch hinterlegt wurde! Andernfalls wird **kein** SSL-Zertifikat von letsencrypt zur Verfügung gestellt.<br/><br/>
* Habt ihr bereits einen Registrierten Gateway-Knoten und die dazugehörige **/etc/nvram.conf** solltet ihr diese jetzt auf dem Server hinterlegen! Anderen falls werden diese automatisch generiert und eine neue Knotennummer vergeben und registriert.
<br/>

Folgends cloned und Installiert das Repository. (Bitte verwendet eurer eignes geclontes Repository.)<br/>
Es wird beim ersten Durchführen eine kurze Zeit in anspruch nehmen da einige Packages und ihre Abhängigkeiten
installiert, Files kopiert und am Ende noch einige Tools compiliert werden müssen.

git:
```bash
git clone https://github.com/cremesk/ffdd-server.git /srv/ffdd-server
cd /srv/ffdd-server
git checkout T_RELEASE_latest && ./init-server.sh
```
Alternative Installations Möglichkeiten:

curl:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cremesk/ffdd-server/T_RELEASE_latest/init_server.sh)"
```
wget:
```bash
sh -c "$(wget https://raw.githubusercontent.com/cremesk/ffdd-server/T_RELEASE_latest/init_server.sh -O -)"
```
<br/>

Nun ist es bei der ersten Initialisierung ganz normal wenn am Ende in der "Summary for local" noch Failed's angezeigt werden.
<br/>

* Manuelle Anpassung der Variablen.<br/>

Es müssen noch Host- & Community- Spezifische Dinge angepasst werden:
```
*/etc/hostname
*/etc/issue.net
*/etc/nvram.conf
  *servername
  *contact
*/etc/openvpn/
  # please creates openvpn.conf with:
    ./genconfig.sh yourvpnclient.conf/.ovpn
  # for vpn user and password use:
    /etc/openvpn/openvpn.login
*/etc/fastd/peers2/
  # To Create a Fastd2 Connection use:
    '/etc/init.d/S53backbone-fastd add_connect vpnX.freifunk-dresden.de 5002'
```

Im letzten Schritt müssen die Änderungen noch übernommen und überprüft werden. (Dies geschieht auch automatisch aller 10min per cronjob).<br/>
Wir wollen aber sehen ob alles läuft und auch alles erfolgreich initialisiert wird:

```bash
salt-call state.highstate --local

# Debug Mode
salt-call state.highstate --local -l debug
```

Gibt es hier keinerlei Fehler mehr sollte der Server einmal sauber neugestartet werden.<br/>

**Optional:**<br/>
* _/etc/firewall.user_<br/>
Kann verwendet werden um eigene Firewallregeln (iptables) zu definieren. Diese werden in '/etc/init.d/S41firewall' eingebunden und automatisch mitgeladen.
* _Änderung des Installations Path_<br/>
Dies sollte unbedingt **vermieden** werden da ansonsten **kein** Autoupdate mehr gewährleistet werden kann! Es sollte reichen sich einen Symlink zu erstellen.

**Hinweis:**<br/>
Sollte es dazu kommen dass es mit 'salt-call state.highstate --local' direkt am Beginn der Initialisierung zu fehlern kommt oder es generell Probleme mit Services auf dem Server gibt sollte unbedingt erneut die '/srv/ffdd-server/init_server.sh' ausgeführt werden. Um auf ganz sicher zu gehen auch die aktuelle Version zu nutzen:

```bash
rm -rf /srv/ffdd-server && sh -c "$(wget https://raw.githubusercontent.com/cremesk/ffdd-server/T_RELEASE_latest/init_server.sh -O -)"
```

Wichig
----
Im moment gibt es keinen Schutz, dass Routerfirmware einer Communitiy sich mit Servern oder Routern anderer Communities verbinden. Es ist **Fatal** wenn sich die Netze wegen gleicher WLAN BSSID oder via Backbone verbinden. Da überall das gleiche Routingprotokoll verwendet wird, würden Geräte von verschiedenen Communities miteinander reden können und das Netz würde gigantisch groß und die Router überlasten.

Bitte einhalten:
* Ändern der BSSID auf eine eigenen!
* Keine Verwendung von Registratoren anderen Communities (Webserverdienst zum Verteilen von Knotennummern)
* Kein Aufbau von Brücken zwischen Routern/Vservern verschiedener Communities über Backboneverbindungen. (das wird in zukunft noch unterbunden, dazu ist aber eine Änderung am Routingprotokoll notwendig). Verbindungen von Communities dürfen nur über das ICVPN erfolgen.
* /usr/local/bin/ddmesh-ipcalc.sh muss angepasst werden!

Development
----
Um eine andere Release-Version zu benutzen ist ein notwendig in der /etc/nvram.conf die Option "branch=" anzupassen.

Default (Stable):
```
branch=T_RELEASE_latest
```

Development:
```
branch=master
```

Links
----
[Freifunk Dresden](https://www.freifunk-dresden.de)<br>
[Wiki: Freifunk Dresden](https://wiki.freifunk-dresden.de)<br>
[Google+](http://google.com/+FreifunkDresden%EF%BB%BF/about)<br>
[Google+ Community](https://plus.google.com/communities/108088672678522515509)<br>
[Facebook](https://www.facebook.com/FreifunkDresden)
