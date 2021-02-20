{# Wireguard Backbone #}
{% from 'config.jinja' import kernel_pkg_check %}

{# install only if Kernel Package available #}
{% if kernel_pkg_check >= '1' %}

/etc/wireguard-backbone/wg-backbone.sh:
  file.managed:
    - source: salt://wireguard/etc/wireguard-backbone/wg-backbone.sh
    - makedirs: true
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: wireguard

/usr/local/bin/wg-backbone.sh:
  file.symlink:
    - target: /etc/wireguard-backbone/wg-backbone.sh
    - force: true
    - require:
      - file: /etc/wireguard-backbone/wg-backbone.sh

/etc/cron.d/wireguard-backbone:
  file.managed:
    - source: salt://wireguard/etc/wireguard-backbone/wireguard-backbone.cron
    - makedirs: true
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: wireguard

{% endif %}
