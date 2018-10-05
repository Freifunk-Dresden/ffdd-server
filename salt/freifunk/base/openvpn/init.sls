openvpn:
  pkg:
    - installed
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
    - require:
      - file: /etc/default/openvpn
      - file: /etc/openvpn/openvpn.conf
      - file: /lib/systemd/system/openvpn@.service
      - file: /etc/openvpn/up.sh
      - file: /etc/openvpn/down.sh

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


/etc/openvpn/openvpn.conf:
  file.exists

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
