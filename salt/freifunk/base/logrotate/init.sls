{# logfile rotation, compression and removal #}
logrotate:
  pkg.installed:
    - name: logrotate

{# Configuration #}
/etc/logrotate.d/freifunk:
  file.managed:
    - source:
      - salt://logrotate/etc/logrotate.d/freifunk
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: logrotate
