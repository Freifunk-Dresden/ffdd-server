{# Freifunk Dresden Configurations #}
{% from 'config.jinja' import freifunk_version, ctime %}

/etc/freifunk-server-version:
  file.managed:
    - contents: |
        {{ freifunk_version }}
    - user: root
    - group: root
    - mode: 644
    - sls: uci
    - file: /etc/config/ffdd

/etc/freifunk-server-initdate:
  file.managed:
    - contents: |
        # Please do not delete this file!
        #
        FFDD-Server - INIT BEFORE v1.0.1
    - user: root
    - group: root
    - mode: 600
    - replace: false

{# cron #}
/etc/cron.d/freifunk:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        # NOTE: * To disable email notifications use:
        #         - for single cronjobs: `>/dev/null 2>&1` after the cmd
        #         - ' MAILTO="" ' disables all email alerts in the crontab
        #       * any tools used in those scripts must be also in search path
        #
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        # ip rules check (needed on linux container based vservers like the ones offered by myloc)
        */1 * * * *  root  /etc/init.d/S40network check
        #
        # batmand check every 1 minutes
        */1 * * * *  root  /etc/init.d/S52batmand check
        #
        # Gateway check every 5 minutes
        */5 * * * *  root  /usr/local/bin/freifunk-gateway-check.sh
        #
        # register local node every 2h
        {{ ctime }} */2 * * *  root  /usr/local/bin/freifunk-register-local-node.sh
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - pkg: salt-minion


{# Scripts #}
/usr/local/bin/ddmesh-ipcalc.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/ddmesh-ipcalc.sh
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/freifunk-manuell_update.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-manuell_update.sh
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/freifunk-gateway-check.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-gateway-check.sh
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/freifunk-gateway-status.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-gateway-status.sh
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/freifunk-register-local-node.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-register-local-node.sh
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/freifunk-version:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-version
    - user: root
    - group: root
    - mode: 755


{# Directories #}
/var/lib/freifunk:
  file.directory:
    - user: freifunk
    - group: freifunk
    - file_mode: 775
    - dir_mode: 755
    - require:
      - user: freifunk


{# Logs #}
{# - used by rsyslog clients #}
/var/log/freifunk:
  file.directory:
    - user: root
    - group: syslog
    - file_mode: 755
    - dir_mode: 755
    - require:
      - pkg: rsyslog

/var/log/freifunk/registrator:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - require:
      - pkg: rsyslog
      - pkg: apache2

/var/log/freifunk/register:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - require:
      - pkg: rsyslog
      - pkg: apache2

/var/log/freifunk/router:
  file.directory:
    - user: syslog
    - group: syslog
    - file_mode: 755
    - dir_mode: 755
    - require:
      - pkg: rsyslog
