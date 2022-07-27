{# autoconfigure a new server #}
{% from 'config.jinja' import ddmesh_registerkey, nodeid %}

/usr/local/bin/freifunk-uci_autosetup.sh:
  file.managed:
    - source: salt://ddmesh/usr/local/bin/freifunk-uci_autosetup.sh
    - user: root
    - group: root
    - mode: 755

{% if ddmesh_registerkey == '' or ddmesh_registerkey == '-' %}
ddmesh_autosetup:
  cmd.run:
    - name: /usr/local/bin/freifunk-uci_autosetup.sh
    - require:
      - file: /usr/local/bin/freifunk-uci_autosetup.sh
      - file: /etc/config/ffdd
      - sls: uci
{% endif %}
