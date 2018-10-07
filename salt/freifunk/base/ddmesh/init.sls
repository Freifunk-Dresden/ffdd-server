# firmware version
{% set freifunk_version = salt['cmd.shell']('/usr/local/bin/nvram version') %}

/etc/freifunk-server-version:
  file.managed:
    - contents:
      - {{ freifunk_version }}
    - user: root
    - group: root
    - mode: 644


#
# Freifunk Crontab
#
/etc/cron.d/freifunk:
  file.managed:
    - source: salt://ddmesh/etc/cron.d/freifunk
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron

# autoupdate
/etc/cron.d/freifunk-autoupdate:
  file.managed:
    - source: salt://ddmesh/etc/cron.d/freifunk-autoupdate
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron

# salt-minion self-managed config
/etc/cron.d/freifunk-masterless:
  file.managed:
    - source: salt://ddmesh/etc/cron.d/freifunk-masterless
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - pkg: salt-minion


#
# Freifunk Directories
#
/var/lib/freifunk:
  file.directory:
    - user: freifunk
    - group: freifunk
    - file_mode: 775
    - dir_mode: 755
    - require:
      - user: freifunk

#
# Logs
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

#
# Freifunk Scripts
#
/usr/local/bin/freifunk-autoupdate:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-autoupdate
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: apt
      - pkg: cron

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
