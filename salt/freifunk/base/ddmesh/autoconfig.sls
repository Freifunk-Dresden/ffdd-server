{# autoconfigure a new server #}
{% from 'config.jinja' import ddmesh_registerkey, fastd_secret, nodeid %}

/usr/local/bin/freifunk-uci_autosetup.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-uci_autosetup.sh
    - user: root
    - group: root
    - mode: 755

{% if ddmesh_registerkey == '' or fastd_secret == '' %}
ddmesh_autosetup:
  cmd.run:
    - name: /usr/local/bin/freifunk-uci_autosetup.sh
    - require:
      - file: /etc/config/ffdd
      - uci
      - file: /usr/local/bin/freifunk-uci_autosetup.sh

{% endif %}

{# check nodeid is set #}
{% if nodeid == '' %}
ddmesh_autosetup_fix:
  cmd.run:
    - name: nodeid="$(freifunk-register-local-node.sh | sed -n '/^node=/{s#^.*=##;p}')" && uci set ffdd.sys.ddmesh_node="$nodeid"
    - require:
      - file: /etc/config/ffdd
      - uci

{% endif %}
