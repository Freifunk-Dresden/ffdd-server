{# time-based job scheduler #}
cron:
  pkg.installed:
    - refresh: True
    - name: cron
  service:
    - running
    - name: cron
    - enable: True
    - restart: True

{# Configuration #}
/etc/default/cron:
  file.managed:
    - source: salt://cron/etc/default/cron
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: cron
