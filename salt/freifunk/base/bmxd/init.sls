/var/lib/freifunk/compiled-tools/bmx:
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
    - name: "cd /var/lib/freifunk/compiled-tools/bmx/bmxd/ && make && make strip && cp bmxd /usr/bin/"
    - require:
      - file: /var/lib/freifunk/compiled-tools/bmx
    - onchanges:
      - file: /var/lib/freifunk/compiled-tools/bmx

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
