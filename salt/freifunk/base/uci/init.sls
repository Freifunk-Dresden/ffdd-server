{# uci - config management helper #}
{% from 'config.jinja' import freifunk_dl_url %}

# the pkg version must also be changed in init_server.sh
{% set libubox_version = '20200227' %}
{% set libuci_version = '20200427' %}
{% set uci_version = '20200427' %}

{% if salt['cmd.shell']("dpkg-query -W -f='${Version}' libubox || true") != libubox_version %}
libubox_pkg_removed:
  pkg.removed:
    - name: libubox
    - require_in:
      - pkg: uci
{% endif %}

{% if salt['cmd.shell']("dpkg-query -W -f='${Version}' libuci || true") != libuci_version %}
libuci_pkg_removed:
  pkg.removed:
    - name: libuci
    - require_in:
      - pkg: uci
{% endif %}

{% if salt['cmd.shell']("dpkg-query -W -f='${Version}' uci || true") != uci_version %}
uci_pkg_removed:
  pkg.removed:
    - name: uci
    - require_in:
      - pkg: uci
{% endif %}

uci:
  pkg.installed:
    - sources:
{% if grains['os'] == 'Debian' and grains['oscodename'] == 'stretch' %}
      - libubox: {{ freifunk_dl_url }}/debian9/libubox_{{ libubox_version }}_amd64.deb
      - libuci: {{ freifunk_dl_url }}/debian9/libuci_{{ libuci_version }}_amd64.deb
      - uci: {{ freifunk_dl_url }}/debian9/uci_{{ uci_version }}_amd64.deb

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'buster' %}
      - libubox: {{ freifunk_dl_url }}/debian10/libubox_{{ libubox_version }}_amd64.deb
      - libuci: {{ freifunk_dl_url }}/debian10/libuci_{{ libuci_version }}_amd64.deb
      - uci: {{ freifunk_dl_url }}/debian10/uci_{{ uci_version }}_amd64.deb

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'xenial' %}
      - libubox: {{ freifunk_dl_url }}/ubuntu16/libubox_{{ libubox_version }}_amd64.deb
      - libuci: {{ freifunk_dl_url }}/ubuntu16/libuci_{{ libuci_version }}_amd64.deb
      - uci: {{ freifunk_dl_url }}/ubuntu16/uci_{{ uci_version }}_amd64.deb

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'bionic' %}
      - libubox: {{ freifunk_dl_url }}/ubuntu18/libubox_{{ libubox_version }}_amd64.deb
      - libuci: {{ freifunk_dl_url }}/ubuntu18/libuci_{{ libuci_version }}_amd64.deb
      - uci: {{ freifunk_dl_url }}/ubuntu18/uci_{{ uci_version }}_amd64.deb

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
      - libubox: {{ freifunk_dl_url }}/ubuntu20/libubox_{{ libubox_version }}_amd64.deb
      - libuci: {{ freifunk_dl_url }}/ubuntu20/libuci_{{ libuci_version }}_amd64.deb
      - uci: {{ freifunk_dl_url }}/ubuntu20/uci_{{ uci_version }}_amd64.deb

{% endif %}

uci_ldconfig:
  cmd.wait:
    - name: /sbin/ldconfig
    - watch:
      - pkg: uci


{# config #}
/etc/config/ffdd:
  file.managed:
    - source: salt://uci/etc/config/ffdd
    - makedirs: true
    - user: root
    - group: root
    - mode: 644
    - replace: false

{# sample config (default) #}
/etc/config/ffdd_sample:
  file.managed:
    - source: salt://uci/etc/config/ffdd
    - makedirs: true
    - user: root
    - group: root
    - mode: 644


{# migrate old /etc/nvram.conf #}
migrate_nvram:
  cmd.run:
    - name: |
        /srv/ffdd-server/salt/freifunk/base/uci/usr/local/bin/nvram-migration.sh
        mv /etc/nvram.conf /etc/nvram.backup
        rm -f /etc/nvram.conf* /etc/nvram_sample.conf /usr/local/bin/nvram
    - onlyif: test -f /etc/nvram.conf -a ! -L /etc/nvram.conf
    - require:
      - pkg: uci
      - file: /etc/config/ffdd

{# set new uci config options #}
check_uci_config:
  cmd.run: /srv/ffdd-server/salt/freifunk/base/uci/usr/local/bin/uci_check_config_options.sh
  - require:
    - pkg: uci
    - file: /etc/config/ffdd
    - migrate_nvram


{# symlink for old nvram #}
/usr/local/bin/nvram:
  file.symlink:
    - target: /usr/local/sbin/uci
    - force: True
    - require:
      - pkg: uci

/etc/nvram.conf:
  file.symlink:
    - target: /etc/config/ffdd
    - force: True
    - require:
      - pkg: uci
      - file: /etc/config/ffdd
