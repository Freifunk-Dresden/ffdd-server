# OpenVPN Gateway Tunnel
{% set ddmesh_disable_gateway = salt['cmd.shell']('/usr/local/bin/nvram get ddmesh_disable_gateway') %}
{% set ovpn0 = salt['cmd.shell']('/usr/bin/test -f /etc/openvpn/openvpn-vpn0.conf && echo "1" || true') %}
{% set ovpn1 = salt['cmd.shell']('/usr/bin/test -f /etc/openvpn/openvpn-vpn1.conf && echo "1" || true') %}


# Temp. rename old config
tmp_rename_ovpn_conf:
  cmd.run:
    - name: "mv /etc/openvpn/openvpn.conf /etc/openvpn/openvpn-vpn0.conf"
    - unless: "[ ! -f /etc/openvpn/openvpn.conf ]"

tmp_rename_ovpn1_conf:
  cmd.run:
    - name: mv /etc/openvpn/openvpn1.conf /etc/openvpn/openvpn-vpn1.conf
    - unless: "[ ! -f /etc/openvpn/openvpn1.conf ]"


openvpn:
  pkg.installed:
    - name: openvpn

# Service Start then Gateway Option Enabled
{% if ddmesh_disable_gateway == '0' %}
# VPN 0
{% if ovpn0 == '1' %}
ovpn0_service:
  service.running:
    - name: openvpn@openvpn-vpn0.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn-vpn0.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn-vpn0.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh
    - onlyif: test -f /etc/openvpn/openvpn-vpn0.conf

/etc/openvpn/openvpn-vpn0.conf:
  file.exists

{% endif %}

# VPN 1
{% if ovpn1 == '1' %}
ovpn1_service:
  service.running:
    - name: openvpn@openvpn-vpn1.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn-vpn1.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn-vpn1.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh
    - onlyif: test -f /etc/openvpn/openvpn-vpn1.conf

/etc/openvpn/openvpn-vpn1.conf:
  file.exists

{% endif %}

# Service Start then Gateway Option Disabled
{% elif ddmesh_disable_gateway == '1' %}
{% if ovpn0 == '1' %}
ovpn0_service_dead:
  service.dead:
    - name: openvpn@openvpn-vpn0.service
    - enable: false
{% endif %}

{% if ovpn1 == '1' %}
ovpn1_service_dead:
  service.dead:
    - name: openvpn@openvpn-vpn1.service
    - enable: false
{% endif %}
{% endif %}


# Default Service Configuration
/etc/default/openvpn:
  file.managed:
    - source:
      - salt://openvpn/etc/default/openvpn
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: openvpn

/lib/systemd/system/openvpn@.service:
  file.managed:
    - source: salt://openvpn/lib/systemd/system/openvpn@.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: systemd
      - pkg: openvpn


# Helper Scripts for FFDD
/etc/openvpn/gen-config.sh:
  file.managed:
    - source:
      - salt://openvpn/etc/openvpn/gen-config.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: openvpn

/etc/openvpn/update-resolv-conf:
  file.managed:
    - source:
      - salt://openvpn/etc/openvpn/update-resolv-conf
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: openvpn

/etc/openvpn/up.sh:
  file.managed:
    - source:
      - salt://openvpn/etc/openvpn/up.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: openvpn

/etc/openvpn/down.sh:
  file.managed:
    - source:
      - salt://openvpn/etc/openvpn/down.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: openvpn
