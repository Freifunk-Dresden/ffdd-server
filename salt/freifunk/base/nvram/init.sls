/etc/nvram.conf:
  file.managed:
    - source:
      - salt://nvram/etc/nvram.conf
    - user: root
    - group: root
    - mode: 644
    - replace: false

/usr/local/bin/nvram:
  file.managed:
    - source: salt://nvram/usr/local/bin/nvram
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/nvram.conf

/usr/local/bin/freifunk-nvram_autosetup.sh:
  file.managed:
    - source: salt://nvram/usr/local/bin/freifunk-nvram_autosetup.sh
    - user: root
    - group: root
    - mode: 755


#
# autoconfigure a new server
#
{% set ddmesh_registerkey = salt['cmd.shell']('/usr/local/bin/nvram get ddmesh_registerkey') %}

{% if ddmesh_registerkey == '' %}

ddmesh_autosetup:
  cmd.run:
    - name: /usr/local/bin/freifunk-nvram_autosetup.sh
    - require:
      - file: /etc/nvram.conf
      - file: /usr/local/bin/nvram
      - file: /usr/local/bin/freifunk-nvram_autosetup.sh
{% endif %}
