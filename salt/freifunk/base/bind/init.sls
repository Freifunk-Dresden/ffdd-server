{# DNS Server #}
bind:
  pkg.installed:
    - refresh: True
    - names:
      - bind9
      - bind9-host
      - bind9utils
  service.running:
    - name: bind9
    - enable: True
    - reload: True
    - watch:
      - file: /lib/systemd/system/bind9.service
      - file: /etc/bind/named.conf
      - file: /etc/bind/named.conf.options
    - require:
      - pkg: bind
      - service: S40network
      - service: S41firewall

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

# define Zones
/etc/bind/named.conf.default-zones:
  file.managed:
    - source:
      - salt://bind/etc/bind/named.conf.default-zones
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bind

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
