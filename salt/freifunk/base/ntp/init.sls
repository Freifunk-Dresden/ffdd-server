ntp:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/ntp.conf
    - require:
      - pkg: ntp

/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/etc/ntp/ntp.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ntp
