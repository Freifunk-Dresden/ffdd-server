{# Freifunk Dresden Configurations #}
{% from 'config.jinja' import freifunk_version, freifunk_repo, branch, install_dir, autoupdate, ctime %}

/etc/freifunk-server-version:
  file.managed:
    - contents: |
        {{ freifunk_version }}
    - user: root
    - group: root
    - mode: 644


{# autoupdate #}
{% if autoupdate == '1' %}
ffdd-server_repo:
  git.latest:
    - name: {{ freifunk_repo }}
    - rev: {{ branch }}
    - target: {{ install_dir }}
    - update_head: True
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git

apply_ffdd-server_update:
  cmd.run:
    - name: echo 'salt-call state.highstate --local -l error' | sudo at now + 1 min
    - onchanges:
        - ffdd-server_repo
{% endif %}


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


{# enable FFDD server page #}
/etc/apache2/sites-available/001-freifunk.conf:
  file.managed:
    - source: salt://ddmesh/etc/apache2/sites-available/001-freifunk.conf.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2

apache2_site_enable_freifunk:
  apache_site.enabled:
    - name: 001-freifunk
    - require:
      - pkg: apache2
      - file: /etc/apache2/sites-available/001-freifunk.conf


{# Directories #}
/var/www_freifunk:
  file.recurse:
    - source: salt://ddmesh/var/www_freifunk
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - keep_symlinks: True
    - force_symlinks: True
    - clean: True
    - recurse:
      - user
      - group

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


{# Scripts #}
/usr/local/bin/ddmesh-ipcalc.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/ddmesh-ipcalc.sh
    - user: root
    - group: root
    - mode: 755

/usr/local/bin/freifunk-register-local-node.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-register-local-node.sh
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
