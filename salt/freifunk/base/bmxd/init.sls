/usr/local/src/bmx:
  file.recurse:
    - source:
      - salt://bmxd/compiled-tools/bmx
    - user: freifunk
    - group: freifunk
    - file_mode: 775
    - dir_mode: 775
    - require:
      - pkg: devel
      - user: freifunk

compile_bmxd:
  cmd.run:
    - name: "cd /usr/local/src/bmx/bmxd/ && make && make strip && cp bmxd /usr/local/bin/"
    - require:
      - file: /usr/local/src/bmx
    - onchanges:
      - file: /usr/local/src/bmx

/etc/init.d/S52batmand:
  file.managed:
    - source: salt://bmxd/etc/init.d/S52batmand
    - user: root
    - group: root
    - mode: 755

rc.d_S52batmand:
  cmd.run:
    - name: /usr/sbin/update-rc.d S52batmand defaults
    - require:
      - file: /etc/init.d/S52batmand
    - onchanges:
      - file: /etc/init.d/S52batmand

S52batmand:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/init.d/S52batmand
      - service: S41firewall
      - service: S53backbone-fastd2
    - require:
      - file: /etc/init.d/S52batmand
      - service: S40network
      - service: S41firewall
      - service: S53backbone-fastd2
