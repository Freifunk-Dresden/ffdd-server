{# FFDD Batmand Network #}
{% from 'config.jinja' import freifunk_dl_url, nodeid, ddmesh_registerkey %}

{% set bmxd_version = '1.4-06cc61a82822f4dc98410fef1e00b81f' %}

{% if salt['cmd.shell']("dpkg-query -W -f='${Version}' bmxd || true") != bmxd_version %}
bmxd_pkg_removed:
  pkg.removed:
    - name: bmxd
    - require_in:
      - pkg: bmxd
{% endif %}

bmxd:
  pkg.installed:
    - sources:
{% if grains['os'] == 'Debian' and grains['oscodename'] == 'bullseye' %}
      - bmxd: {{ freifunk_dl_url }}/debian11/bmxd-{{ bmxd_version }}-debian-bullseye-amd64.deb

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'bookworm' %}
      - bmxd: {{ freifunk_dl_url }}/debian12/bmxd-{{ bmxd_version }}-debian-bookworm-amd64.deb


{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
      - bmxd: {{ freifunk_dl_url }}/ubuntu20/bmxd-{{ bmxd_version }}-ubuntu-focal-amd64.deb

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'jammy' %}
      - bmxd: {{ freifunk_dl_url }}/ubuntu22/bmxd-{{ bmxd_version }}-ubuntu-jammy-amd64.deb

{% endif %}


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

{# only then fastd2 is configured and the service is enabled #}
{% if nodeid != '' and nodeid != '-' or ddmesh_registerkey != '' and ddmesh_registerkey != '-' %}
S52batmand:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pkg: bmxd
      - service: S40network
      - service: S53backbone-fastd2
      - file: /etc/init.d/S52batmand
      - file: /etc/init.d/S40network
    - require:
      - pkg: bmxd
      - service: S40network
      - service: S53backbone-fastd2
      - cmd: rc.d_S52batmand
      - file: /etc/init.d/S52batmand
      - file: /etc/init.d/S40network
      - file: /usr/local/bin/ddmesh-ipcalc.sh
      - sls: ddmesh
      - sls: ddmesh.autoconfig
      - sls: uci
      - file: /etc/config/ffdd
{% endif %}
