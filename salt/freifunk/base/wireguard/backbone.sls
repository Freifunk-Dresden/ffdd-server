{# Wireguard Backbone #}
{% from 'config.jinja' import kernel_pkg_check %}

{# install only if Kernel Package available #}
{% if kernel_pkg_check >= '1' %}

/etc/wireguard-backbone/wg-backbone.sh:
  file.managed:
    - source: salt://wireguard/usr/local/bin/wireguard-backbone/wg-backbone.sh
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
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        # NOTE: * To disable email notifications use:
        #         - for single cronjobs: `>/dev/null 2>&1` after the cmd
        #         - ' MAILTO="" ' disables all email alerts in the crontab
        #       * any tools used in those scripts must be also in search path
        #
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        # reload peers and re-add interfaces to bmxd
        * * * * * root  /usr/local/bin/wg-backbone.sh reload
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - pkg: wireguard

{% endif %}
