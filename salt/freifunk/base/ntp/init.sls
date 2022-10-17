{# Network Time Protocol #}
{% from 'config.jinja' import nodeid, ddmesh_registerkey %}

ntp:
  pkg.installed:
    - refresh: true
    - name: ntp
  service:
    - running
    - enable: true
    - restart: true
    - watch:
      - file: /etc/ntp.conf
{% if nodeid != '' and nodeid != '-' or ddmesh_registerkey != '' and ddmesh_registerkey != '-' %}
      - service: S52batmand
      - service: S53backbone-fastd2
{% endif %}
    - require:
      - pkg: ntp
      - file: /etc/ntp.conf
      - file: /lib/systemd/system/ntp.service
      - service: S40network
      - service: S41firewall


{# Configuration #}
/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/etc/ntp/ntp.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ntp


{# Service #}
/lib/systemd/system/ntp.service:
  file.managed:
    - source: salt://ntp/lib/systemd/system/ntp.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: systemd
      - pkg: ntp
    - require_in:
      - service: ntp
