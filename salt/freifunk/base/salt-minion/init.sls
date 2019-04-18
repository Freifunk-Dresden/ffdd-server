{# FFDD Salt-Minion (masterless) #}
{% from 'config.jinja' import ctime %}

salt-minion:
  pkg.installed:
    - refresh: True
    - name: salt-minion
  service:
    - dead
    - enable: False

{# Configuration #}
/etc/salt/minion.d/freifunk-masterless.conf:
  file.managed:
    - source:
      - salt://salt-minion/etc/salt/minion.d/freifunk-masterless.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644

{# cron #}
/etc/cron.d/freifunk-masterless:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        # Execute a local salt-call every 10 minutes
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        #
        */10 * * * *  root  sleep {{ ctime }}; /usr/bin/salt-call state.highstate --local >/dev/null 2>&1
        # Execute after boot
        @reboot       root  /usr/bin/salt-call state.highstate --local >/dev/null 2>&1
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
