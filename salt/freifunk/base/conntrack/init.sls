# conntrack
/usr/local/bin/conntrack.sh:
  file.managed:
    - source: salt://conntrack/usr/local/bin/conntrack.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: cron

/etc/cron.d/conntrack:
  file.managed:
    - source: salt://conntrack/etc/cron.d/conntrack
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - file: /usr/local/bin/conntrack.sh

/etc/logrotate.d/conntrack:
  file.managed:
    - source:
      - salt://conntrack/etc/logrotate.d/conntrack
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: logrotate
