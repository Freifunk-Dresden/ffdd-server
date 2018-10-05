/etc/hostname:
  file.managed:
    - source: salt://hostname/etc/hostname
    - user: root
    - group: root
    - mode: 644
