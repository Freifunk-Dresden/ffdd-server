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
      - file: /etc/bind/named.conf.local
      - file: /etc/bind/zones
    - require:
      - pkg: bind
      - service: S40network
      - service: S41firewall
      - file: /lib/systemd/system/bind9.service
      - file: /etc/bind/named.conf
      - file: /etc/bind/named.conf.options
      - file: /etc/bind/named.conf.default-zones

{# Service #}
/lib/systemd/system/bind9.service:
  file.managed:
    - source: salt://bind/master/lib/systemd/system/bind9.service
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
      - salt://bind/master/etc/bind/named.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

/etc/bind/named.conf.options:
  file.managed:
    - source:
      - salt://bind/master/etc/bind/named.conf.options
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

{# define Zones #}
/etc/bind/named.conf.default-zones:
  file.managed:
    - source:
      - salt://bind/master/etc/bind/named.conf.default-zones
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

/etc/bind/named.conf.local:
  file.managed:
    - source:
      - salt://bind/master/etc/bind/named.conf.local
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

{# Zone files #}
/etc/bind/zones:
  file.recurse:
    - source:
      - salt://bind/master/etc/bind/zones
    - user: root
    - group: root
    - file_mode: 755
    - dir_mode: 755
    - recurse:
      - user
      - group

{# check root.hints are up-to-date #}
/etc/bind/db.root:
  cmd.run:
    - name: /bin/cp /usr/share/dns/root.hints /etc/bind/db.root && systemctl restart bind9
    - onlyif: "test ! -f /etc/bind/db.root || test $(md5sum /etc/bind/db.root | awk '{ print $1 }') != $(md5sum /usr/share/dns/root.hints | awk '{ print $1 }')"


{# Logs #}
/var/log/named:
  file.directory:
    - user: bind
    - group: bind
    - require:
      - pkg: bind
