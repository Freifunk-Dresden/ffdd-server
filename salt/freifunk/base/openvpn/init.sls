{% set ddmesh_disable_gateway = salt['cmd.shell']('/usr/local/bin/nvram get ddmesh_disable_gateway') %}
{% set ovpn1 = salt['cmd.shell']('/usr/bin/test -f /etc/openvpn/openvpn1.conf && echo "1" || true') %}

openvpn:
  pkg.installed:
    - name: openvpn
  {% if ddmesh_disable_gateway == '0' %}
  service.running:
    - name: openvpn@openvpn.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh

/etc/openvpn/openvpn.conf:
  file.exists

{% if ovpn1 == '1' %}
openvpn1:
  service.running:
    - name: openvpn@openvpn1.service
    - enable: True
    - restart: True
    - watch:
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn1.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn1.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh

/etc/openvpn/openvpn1.conf:
  file.exists
{% endif %}

  {% elif ddmesh_disable_gateway == '1' %}
  service.dead:
    - name: openvpn.service
    - enable: False
  {% endif %}


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
