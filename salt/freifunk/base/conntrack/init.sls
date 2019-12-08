{# conntrack (increase active connection limit) #}
/usr/local/bin/conntrack.sh:
  file.managed:
    - source: salt://conntrack/usr/local/bin/conntrack.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: cron

{# cron #}
/etc/cron.d/conntrack:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        0-59/5 * * * *  root  /usr/local/bin/conntrack.sh
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - file: /usr/local/bin/conntrack.sh

{# archive conntrack logs #}
/etc/logrotate.d/conntrack:
  file.managed:
    - source: salt://conntrack/etc/logrotate.d/conntrack
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: logrotate
