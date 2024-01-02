{# Wireguard VPN Gateway Tunnel #}
{% from 'config.jinja' import announce_gateway %}


{# Package #}
{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
/etc/apt/sources.list.d/wireguard-ubuntu-wireguard-focal.list:
  file.absent
{% endif %}

{% if grains['os'] == 'Debian' and grains['oscodename'] == 'bookworm' %}
/etc/apt/sources.list.d/debian_unstable.list:
  file.absent

/etc/apt/preferences.d/limit-unstable:
  file.absent

wireguard_dkms:
  pkg.removed:
    - names:
      - wireguard-dkms
      - dkms
{% endif %}


{# Debian <12 Pin-Prio for unstable Repo #}
{% if grains['os'] == 'Debian' and not grains['oscodename'] == 'bookworm' %}
unstable_pkg_prio:
  cmd.run:
    - name: "printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable"
    - unless: "[ -f /etc/apt/preferences.d/limit-unstable ]"
{% endif %}

wireguard:
  {% if grains['os'] == 'Debian' and not grains['oscodename'] == 'bookworm' %}
  pkgrepo.managed:
    - humanname: debian-unstable
    - name: deb http://deb.debian.org/debian/ unstable main
    - dist: unstable
    - file: /etc/apt/sources.list.d/debian_unstable.list
    - unless: "[ -f /etc/apt/sources.list.d/debian_unstable.list ]"
  {% endif %}

  pkg.installed:
    - refresh: True
    - names:
      - wireguard
      - wireguard-tools


{# Service Start then Gateway Option Enabled #}
{% if announce_gateway == '0' %}

{# VPN 0 #}
{% if salt['file.file_exists' ]('/etc/wireguard/vpn0.conf') %}
wgvpn0_service:
  service.running:
    - name: wg-quick@vpn0.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/wireguard/vpn0.conf
      - service: S40network
      - service: S41firewall
    - require:
      - pkg: wireguard
      - service: S40network
      - service: S41firewall
      - file: /etc/wireguard/vpn0.conf
    - onlyif: test -f /etc/wireguard/vpn0.conf

/etc/wireguard/vpn0.conf:
  file.exists

{% else %}
{# no config file was found #}
wgvpn0_service_dead:
  service.dead:
    - name: wg-quick@vpn0.service
    - enable: false
{% endif %}


{# VPN 1 #}
{% if salt['file.file_exists' ]('/etc/wireguard/vpn1.conf') %}
wgvpn1_service:
  service.running:
    - name: wg-quick@vpn1.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/wireguard/vpn1.conf
      - service: S40network
      - service: S41firewall
    - require:
      - pkg: wireguard
      - service: S40network
      - service: S41firewall
      - file: /etc/wireguard/vpn1.conf
    - onlyif: test -f /etc/wireguard/vpn1.conf

/etc/wireguard/vpn1.conf:
  file.exists

{% else %}
{# no config file was found #}
wgvpn1_service_dead:
  service.dead:
    - name: wg-quick@vpn1.service
    - enable: false
{% endif %}


{# Service Dead then Gateway Option Disabled #}
{% elif announce_gateway == '1' %}
{# VPN 0 #}
{% if salt['file.file_exists' ]('/etc/wireguard/vpn0.conf') %}
wgvpn0_service_dead:
  service.dead:
    - name: wg-quick@vpn0.service
    - enable: false
{% endif %}

{# VPN 1 #}
{% if salt['file.file_exists' ]('/etc/wireguard/vpn1.conf') %}
wgvpn1_service_dead:
  service.dead:
    - name: wg-quick@vpn1.service
    - enable: false
{% endif %}
{% endif %}


{# Helper Scripts for FFDD #}
/etc/wireguard/gen-config.sh:
  file.managed:
    - source: salt://wireguard/etc/wireguard/gen-config.sh
    - makedirs: true
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: wireguard
      - file: /etc/config/ffdd
