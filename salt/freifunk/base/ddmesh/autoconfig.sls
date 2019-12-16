{# autoconfigure a new server #}
{% from 'config.jinja' import ddmesh_registerkey, fastd_secret, nodeid %}

/usr/local/bin/freifunk-nvram_autosetup.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-nvram_autosetup.sh
    - user: root
    - group: root
    - mode: 755

{% if ddmesh_registerkey == '' or fastd_secret == '' %}
ddmesh_autosetup:
  cmd.run:
    - name: /usr/local/bin/freifunk-nvram_autosetup.sh
    - require:
      - file: /etc/nvram.conf
      - file: /usr/local/bin/nvram
      - file: /usr/local/bin/freifunk-nvram_autosetup.sh

{% endif %}

{# check nodeid is set #}
{% if nodeid == '' %}
ddmesh_autosetup_fix:
  cmd.run:
    - name: nodeid="$(freifunk-register-local-node.sh | sed -n '/^node=/{s#^.*=##;p}')" && nvram set ddmesh_node "$nodeid"
    - require:
      - file: /etc/nvram.conf
      - file: /usr/local/bin/nvram

{% endif %}
