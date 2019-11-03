{# DNS Server #}
bind:
  pkg.installed:
    - refresh: True
    - names:
      - bind9
      - bind9-host
      - bind9utils
      - dns-root-data
  service.running:
    - name: bind9
    - enable: True
    - reload: True
    - watch:
      - pkg: bind
      - file: /lib/systemd/system/bind9.service
      - file: /etc/bind/named.conf
      - file: /etc/bind/named.conf.options
      - file: /etc/bind/named.conf.default-zones
      - file: /etc/bind/vpn.forwarder
    - require:
      - pkg: bind
      - service: S40network
      - service: S41firewall
      - file: /lib/systemd/system/bind9.service
      - file: /etc/bind/named.conf
      - file: /etc/bind/named.conf.options
      - file: /etc/bind/named.conf.default-zones
      - file: /etc/bind/vpn.forwarder

{# Service #}
/lib/systemd/system/bind9.service:
  file.managed:
    - source: salt://bind/lib/systemd/system/bind9.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: systemd
      - pkg: bind9

{# Configuration #}
/etc/bind/named.conf:
  file.managed:
    - source:
      - salt://bind/etc/bind/named.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

/etc/bind/named.conf.options:
  file.managed:
    - source:
      - salt://bind/etc/bind/named.conf.options
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

{# define Zones #}
/etc/bind/named.conf.default-zones:
  file.managed:
    - source:
      - salt://bind/etc/bind/named.conf.default-zones
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

{# check root.hints are up-to-date #}
/etc/bind/db.root:
  cmd.run:
    - name: /bin/cp /usr/share/dns/root.hints /etc/bind/db.root && systemctl restart bind9
    - onlyif: "test ! -f /etc/bind/db.root || test $(md5sum /etc/bind/db.root | awk '{ print $1 }') != $(md5sum /usr/share/dns/root.hints | awk '{ print $1 }')"


{# vpn.forwarder #}
/etc/bind/vpn.forwarder:
  file.managed:
    - source:
      - salt://bind/etc/bind/vpn.forwarder
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - pkg: bind

{# Logs #}
/var/log/named:
  file.directory:
    - user: bind
    - group: bind
    - require:
      - pkg: bind
