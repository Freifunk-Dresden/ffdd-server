#install some helpers to exclude brute force attacks
#http://www.atwillys.de/content/linux/blocking-countries-using-geoip-and-iptables-on-ubuntu/

iptables:
  pkg.installed:
    - names:
      - iptables
      #linux sources are needed for xtables-addons-dkms
      - linux-source
      #perl
      - libtext-csv-xs-perl
      #geoip database
      - geoip-database
      #iptables modules for geoip
      - xtables-addons-dkms

# GeoIP for xtables-addons
/usr/share/xt_geoip:
  file.directory:
    - user: root
    - group: root
    - file_mode: 755
    - dir_mode: 755
    - require:
      - pkg: iptables

/usr/share/xt_geoip/update.sh:
  file.managed:
    - source: salt://iptables/usr/share/xt_geoip/update.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables
      - file: /usr/share/xt_geoip

xt_geoip_dl:
  cmd.run:
    - name: cd /usr/share/xt_geoip ; /usr/lib/xtables-addons/xt_geoip_dl
    - require:
      - file: /usr/share/xt_geoip
    - unless: "[ -f /usr/share/xt_geoip/GeoIPCountryWhois.csv ]"

xt_geoip_build:
  cmd.run:
    - name: /usr/lib/xtables-addons/xt_geoip_build -D /usr/share/xt_geoip /usr/share/xt_geoip/GeoIPCountryWhois.csv
    - require:
      - cmd: xt_geoip_dl
    - unless: "[ -d /usr/share/xt_geoip/BE ]"


# IPv4 Firewall
/etc/init.d/S41firewall:
  file.managed:
    - source: salt://iptables/etc/init.d/S41firewall
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables

/etc/firewall.user:
  file.managed:
    - source: salt://iptables/etc/firewall.user
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - file: /etc/init.d/S41firewall
      - pkg: iptables

rc.d_S41firewall:
  cmd.run:
    - name: /usr/sbin/update-rc.d S41firewall defaults
    - require:
      - file: /etc/init.d/S41firewall
    - onchanges:
      - file: /etc/init.d/S41firewall

S41firewall:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/init.d/S41firewall
      - file: /etc/firewall.user
      - service: S40network
    - require:
      - pkg: iptables
      - service: S40network
      - file: /etc/firewall.user


# IPv6 Firewall
/etc/init.d/S42firewall6:
  file.managed:
    - source: salt://iptables/etc/init.d/S42firewall6
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables

rc.d_S42firewall6:
  cmd.run:
    - name: /usr/sbin/update-rc.d S42firewall6 defaults
    - require:
      - file: /etc/init.d/S42firewall6
    - onchanges:
      - file: /etc/init.d/S42firewall6

S42firewall6:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/init.d/S42firewall6
      - service: S40network
    - require:
      - pkg: iptables
      - service: S40network
