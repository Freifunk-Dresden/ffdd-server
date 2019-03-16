# OpenVPN Gateway Tunnel
{% set ddmesh_disable_gateway = salt['cmd.shell']('/usr/local/bin/nvram get ddmesh_disable_gateway') %}
{% set wgvpn0 = salt['cmd.shell']('/usr/bin/test -f /etc/wireguard/vpn0.conf && echo "1" || true') %}
{% set wgvpn1 = salt['cmd.shell']('/usr/bin/test -f /etc/wireguard/vpn1.conf && echo "1" || true') %}

wireguard:
  {% if grains['os'] == 'Debian' %}
  pkgrepo.managed:
    - humanname: Wireguard
    - name: deb http://deb.debian.org/debian/ unstable main
    - dist: unstable
    - file: /etc/apt/sources.list.d/wireguard.list
  {% endif %}
  {% if grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - ppa: wireguard/wireguard
  {% endif %}
  pkg.installed:
    - name: wireguard
    - refresh: True
  {% if grains['os'] == 'Debian' %}
  unstable_pkg_prio:
    cmd.run:
      - name: "printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable"
      - unless: "[ -f /etc/apt/preferences.d/limit-unstable ]"
  {% endif %}


# Service Start then Gateway Option Enabled
{% if ddmesh_disable_gateway == '0' %}
# VPN 0
{% if wgvpn0 == '1' %}
vpn0_service:
  service.running:
    - name: wireguard@vpn0.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/wireguard/vpn0.conf
      - file: /lib/systemd/system/wg-quick@.service
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/wireguard/vpn0.conf
      - file: /lib/systemd/system/wg-quick@.service
    - onlyif: test -f /etc/wireguard/vpn0.conf

/etc/wireguard/vpn0.conf:
  file.exists
{% endif %}

# VPN 1
{% if wgvpn1 == '1' %}
vpn1_service:
  service.running:
    - name: wireguard@vpn1.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/wireguard/vpn1.conf
      - file: /lib/systemd/system/wg-quick@.service
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/wireguard/vpn1.conf
      - file: /lib/systemd/system/wg-quick@.service
    - onlyif: test -f /etc/wireguard/vpn1.conf

/etc/wireguard/vpn1.conf:
  file.exists
{% endif %}

# Service Start then Gateway Option Disabled
{% elif ddmesh_disable_gateway == '1' %}
{% if wgvpn0 == '1' %}
vpn0_service_dead:
  service.dead:
    - name: wireguard@vpn0.service
    - enable: false
{% endif %}

{% if wgvpn1 == '1' %}
vpn1_service_dead:
  service.dead:
    - name: wireguard@vpn1.service
    - enable: false
{% endif %}
{% endif %}


/lib/systemd/system/wg-quick@.service:
  file.managed:
    - source: salt://wireguard/lib/systemd/system/wg-quick@.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: systemd
      - pkg: wireguard


# Helper Scripts for FFDD
/etc/wireguard/gen-config.sh:
  file.managed:
    - source:
      - salt://wireguard/etc/wireguard/gen-config.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: wireguard

