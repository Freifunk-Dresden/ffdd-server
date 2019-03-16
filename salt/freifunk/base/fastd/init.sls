# Backbone - fastd2
/usr/local/src/fastd:
  file.recurse:
    - source:
      - salt://fastd/compiled-tools/fastd
    - user: freifunk
    - group: freifunk
    - file_mode: 775
    - dir_mode: 775
    - require:
      - pkg: devel
      - user: freifunk

# Compiling
# needs devel.sls (compiling tools)
compile_fastd:
  cmd.run:
    - name: "cd /usr/local/src/fastd/ && bash build.sh"
    - require:
      - pkg: devel
      - file: /usr/local/src/fastd
    - onchanges:
      - file: /usr/local/src/fastd


# Configuration
/etc/fastd:
  file.directory:
    - user: root
    - group: root
    - file_mode: 755
    - dir_mode: 755

/etc/fastd/cmd2.sh:
  file.managed:
    - source:
      - salt://fastd/etc/fastd/cmd2.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/fastd


# Service
/etc/init.d/S53backbone-fastd2:
  file.managed:
    - source: salt://fastd/etc/init.d/S53backbone-fastd2
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/fastd/cmd2.sh

rc.d_S53backbone-fastd2:
  cmd.run:
    - name: /usr/sbin/update-rc.d S53backbone-fastd2 defaults
    - require:
      - file: /etc/init.d/S53backbone-fastd2
    - onchanges:
      - file: /etc/init.d/S53backbone-fastd2

S53backbone-fastd2:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/init.d/S53backbone-fastd2
      - service: S41firewall
    - require:
      - file: /etc/init.d/S53backbone-fastd2
      - service: S40network
      - service: S41firewall
    - onchanges:
      - file: /etc/init.d/S40network
      - file: /etc/init.d/S41firewall
