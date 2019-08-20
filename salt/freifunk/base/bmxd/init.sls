{# FFDD Batmand Network #}
{% from 'config.jinja' import install_dir, ct_bmxd %}

/usr/local/src/bmxd:
  file.recurse:
    - source:
      - salt://bmxd/compiled-tools/bmxd
    - user: freifunk
    - group: freifunk
    - file_mode: 775
    - dir_mode: 775
    - require:
      - pkg: devel
      - user: freifunk

{# revision: md5sum over sources (exclude: 'Makefile') #}
/usr/local/bin/freifunk-get_bmxd_revision.sh:
  file.managed:
    - contents: |
        #!/usr/bin/env bash
        cd {{ install_dir }}{{ ct_bmxd }}
        { export LC_ALL=C;
          find -type f ! -iname "Makefile" -exec wc -c {} \; | sort; echo;
          find -type f ! -iname "Makefile" -exec md5sum {} + | sort; echo;
          find . -type d | sort; find . -type d | sort | md5sum;
        } | md5sum | sed -e 's/^\(.\{10\}\).*/\1/' > /usr/local/src/bmxd_revision
    - user: root
    - group: root
    - mode: 755


{# Compling #}
{# needs devel.sls (compiling tools) #}
get_bmxd_revision:
  cmd.run:
    - name: "/usr/local/bin/freifunk-get_bmxd_revision.sh"
    - onchanges:
      - file: /usr/local/src/bmxd

compile_bmxd:
  cmd.run:
    - name: "cd /usr/local/src/bmxd/ && make && make strip && cp -f bmxd /usr/local/bin/"
    - require:
      - pkg: devel
      - file: /usr/local/src/bmxd
    - onchanges:
      - file: /usr/local/src/bmxd


{# Service #}
/etc/init.d/S52batmand:
  file.managed:
    - source: salt://bmxd/etc/init.d/S52batmand
    - user: root
    - group: root
    - mode: 755

rc.d_S52batmand:
  cmd.run:
    - name: /usr/sbin/update-rc.d S52batmand defaults ; systemctl daemon-reload
    - require:
      - file: /etc/init.d/S52batmand
    - onchanges:
      - file: /etc/init.d/S52batmand


S52batmand:
  service:
    - order: last
    - running
    - enable: True
    - restart: True
    - watch:
      - service: S40network
      - service: S41firewall
      - service: S53backbone-fastd2
      - file: /etc/init.d/S52batmand
      - file: /usr/local/src/bmxd
      - file: /etc/init.d/S40network
      - file: /etc/init.d/S41firewall
    - require:
      - sls: nvram
      - service: S40network
      - service: S41firewall
      - service: S53backbone-fastd2
      - cmd: rc.d_S52batmand
      - file: /etc/init.d/S52batmand
      - file: /usr/local/src/bmxd
      - file: /etc/init.d/S40network
      - file: /etc/init.d/S41firewall
      - file: /etc/nvram.conf
