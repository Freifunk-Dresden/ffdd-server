{# Backbone - fastd2 #}
{% from 'config.jinja' import nodeid, ddmesh_registerkey %}

/usr/local/src/fastd:
  file.recurse:
    - source: salt://fastd/compiled-tools/fastd
    - user: freifunk
    - group: freifunk
    - file_mode: 775
    - dir_mode: 775
    - require:
      - pkg: devel
      - user: freifunk

{# Compiling #}
{# needs devel.sls (compiling tools) #}
compile_fastd:
  cmd.run:
    - name: ./build.sh
    - cwd: /usr/local/src/fastd
    - require:
      - pkg: devel
      - file: /usr/local/src/fastd
{% if salt['file.file_exists' ]('/usr/local/bin/fastd') %}
    - onchanges:
      - file: /usr/local/src/fastd
{% else %}
    - creates:
       - /usr/local/bin/fastd
{% endif %}

{# Configuration #}
/etc/fastd:
  file.directory:
    - user: root
    - group: root
    - file_mode: 755
    - dir_mode: 755

/etc/fastd/cmd.sh:
  file.managed:
    - source: salt://fastd/etc/fastd/cmd.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/fastd

{# additional files #}
/etc/fastd/blacklist:
  file.managed:
    - source: salt://fastd/etc/fastd/blacklist
    - replace: false
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/fastd

/etc/fastd/whitelist:
  file.managed:
    - source: salt://fastd/etc/fastd/whitelist
    - replace: false
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/fastd

{# Service #}
/etc/init.d/S53backbone-fastd2:
  file.managed:
    - source: salt://fastd/etc/init.d/S53backbone-fastd2
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/fastd/cmd.sh

rc.d_S53backbone-fastd2:
  cmd.run:
    - name: /usr/sbin/update-rc.d S53backbone-fastd2 defaults ; systemctl daemon-reload
    - require:
      - file: /etc/init.d/S53backbone-fastd2
    - onchanges:
      - file: /etc/init.d/S53backbone-fastd2


{% if nodeid != '' and nodeid != '-' or ddmesh_registerkey != '' and ddmesh_registerkey != '-' %}
S53backbone-fastd2:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - service: S40network
      - file: /etc/init.d/S40network
      - file: /etc/init.d/S53backbone-fastd2
      - file: /etc/fastd/cmd.sh
      - file: /usr/local/src/fastd
    - require:
      - service: S40network
      - cmd: compile_fastd
      - cmd: rc.d_S53backbone-fastd2
      - file: /etc/init.d/S40network
      - file: /etc/init.d/S53backbone-fastd2
      - file: /etc/fastd/cmd.sh
      - file: /usr/local/src/fastd
      - file: /usr/local/bin/ddmesh-ipcalc.sh
      - sls: ddmesh
      - sls: ddmesh.autoconfig
      - sls: uci
      - file: /etc/config/ffdd
{% endif %}
