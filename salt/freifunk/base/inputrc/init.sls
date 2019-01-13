# keyboard mapping
/etc/inputrc:
  file.managed:
    - source: salt://inputrc/etc/inputrc
    - user: root
    - group: root
    - mode: 644
    - replace: false
