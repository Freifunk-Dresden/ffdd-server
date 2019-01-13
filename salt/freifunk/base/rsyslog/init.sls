# transferring log messages (server for logging from nodes)
rsyslog:
  pkg.installed:
    - name: rsyslog
  service.running:
    - enable: True
    - restart: True
    - watch:
      - file: /etc/rsyslog.conf
      - file: /etc/default/rsyslog
      - file: /etc/rsyslog.d/10-freifunk.conf
    - require:
      - file: /etc/rsyslog.conf
      - file: /etc/default/rsyslog
      - file: /etc/rsyslog.d/10-freifunk.conf


# Configuration
/etc/rsyslog.conf:
  file.managed:
    - source:
      - salt://rsyslog/etc/rsyslog.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: rsyslog
    - require:
      - pkg: rsyslog

/etc/default/rsyslog:
  file.managed:
    - source:
      - salt://rsyslog/etc/default/rsyslog
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: rsyslog
    - require:
      - pkg: rsyslog

/etc/rsyslog.d/10-freifunk.conf:
  file.managed:
    - source:
      - salt://rsyslog/etc/rsyslog.d/10-freifunk.conf
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: rsyslog
    - require:
      - pkg: rsyslog


# change directory & file permissions
/var/log:
  file.directory:
    - user: root
    - group: syslog
    - require:
      - pkg: rsyslog
      - group: syslog

/var/log/syslog:
  file.managed:
    - user: syslog
    - group: adm
    - replace: false
    - require:
      - pkg: rsyslog
      - user: syslog

/var/log/kern.log:
  file.managed:
    - user: syslog
    - group: adm
    - replace: false
    - require:
      - pkg: rsyslog
      - user: syslog

/var/log/auth.log:
  file.managed:
    - user: syslog
    - group: adm
    - replace: false
    - require:
      - pkg: rsyslog
      - user: syslog
