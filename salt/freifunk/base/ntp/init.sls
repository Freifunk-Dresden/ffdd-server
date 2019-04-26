{# Network Time Protocol #}
ntp:
  pkg.installed:
    - refresh: True
    - name: ntp
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/ntp.conf
    - require:
      - pkg: ntp
      - file: /etc/ntp.conf

{# Configuration #}
/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/etc/ntp/ntp.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ntp
