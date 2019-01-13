# FFDD Network Rules
# Configuration
/etc/init.d/S40network:
  file.managed:
    - source: salt://network/etc/init.d/S40network
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iproute2
      - file: /etc/iproute2/rt_tables

# Service
rc.d_S40network:
  cmd.run:
    - name: /usr/sbin/update-rc.d S40network defaults
    - require:
      - file: /etc/init.d/S40network
    - onchanges:
      - file: /etc/init.d/S40network

S40network:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/init.d/S40network
      - file: /etc/iproute2/rt_tables
    - require:
      - pkg: iproute2
