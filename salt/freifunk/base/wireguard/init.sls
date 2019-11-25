{# Wireguard VPN Gateway Tunnel #}
{% from 'config.jinja' import kernel_pkg_check, ddmesh_disable_gateway %}

{# install only than Kernel Package available #}
{% if kernel_pkg_check >= '1' %}
{% set wgvpn0 = salt['cmd.shell']('/usr/bin/test -f /etc/wireguard/vpn0.conf && echo "1" || true') %}
{% set wgvpn1 = salt['cmd.shell']('/usr/bin/test -f /etc/wireguard/vpn1.conf && echo "1" || true') %}

{# Package #}
wireguard:
  {% if grains['os'] == 'Debian' %}
  pkgrepo.managed:
    - humanname: Wireguard
    - name: deb http://deb.debian.org/debian/ unstable main
    - dist: unstable
    - file: /etc/apt/sources.list.d/wireguard.list

  {% elif grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - ppa: wireguard/wireguard

  {% endif %}

  pkg.installed:
    - refresh: True
    - names:
      - wireguard
      - wireguard-dkms
      - wireguard-tools

{# Debian Pin-Prio for unstable Repo #}
{% if grains['os'] == 'Debian' %}
unstable_pkg_prio:
  cmd.run:
    - name: "printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable"
    - unless: "[ -f /etc/apt/preferences.d/limit-unstable ]"
{% endif %}


{# Service Start then Gateway Option Enabled #}
{% if ddmesh_disable_gateway == '0' %}

{# VPN 0 #}
{% if wgvpn0 == '1' %}
wgvpn0_service:
  service.running:
    - name: wg-quick@vpn0.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/wireguard/vpn0.conf
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/wireguard/vpn0.conf
    - onlyif: test -f /etc/wireguard/vpn0.conf

/etc/wireguard/vpn0.conf:
  file.exists
{% endif %}

{# VPN 1 #}
{% if wgvpn1 == '1' %}
wgvpn1_service:
  service.running:
    - name: wg-quick@vpn1.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/wireguard/vpn1.conf
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/wireguard/vpn1.conf
    - onlyif: test -f /etc/wireguard/vpn1.conf

/etc/wireguard/vpn1.conf:
  file.exists
{% endif %}


{# Service Start then Gateway Option Disabled #}
{% elif ddmesh_disable_gateway == '1' %}
{# VPN 0 #}
{% if wgvpn0 == '1' %}
wgvpn0_service_dead:
  service.dead:
    - name: wg-quick@vpn0.service
    - enable: false
{% endif %}

{# VPN 1 #}
{% if wgvpn1 == '1' %}
wgvpn1_service_dead:
  service.dead:
    - name: wg-quick@vpn1.service
    - enable: false
{% endif %}
{% endif %}


{# Helper Scripts for FFDD #}
/etc/wireguard/gen-config.sh:
  file.managed:
    - source:
      - salt://wireguard/etc/wireguard/gen-config.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: wireguard

{# if kernel_pkg_check >= '1' #}
{% endif %}
