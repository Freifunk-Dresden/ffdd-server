{# Network Time Protocol #}
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
    - require:
      - pkg: ntp
      - file: /etc/ntp.conf
      - file: /lib/systemd/system/ntp.service

{# Configuration #}
/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/etc/ntp/ntp.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ntp

/lib/systemd/system/ntp.service:
  file.managed:
    - source: salt://ntp/lib/systemd/system/ntp.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: systemd
      - pkg: ntp
