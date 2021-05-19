{# Wireguard Backbone #}
{% from 'config.jinja' import kernel_pkg_check, ctime, wg_accept_cgi_version %}

{# install only if Kernel Package available #}
{% if kernel_pkg_check >= '1' %}

/etc/wireguard-backbone/wg-backbone.sh:
  file.managed:
    - source: salt://wireguard/usr/local/bin/wg-backbone.sh
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

/etc/wireguard-backbone/wg-check-peers.sh:
  file.managed:
    - source: salt://wireguard/usr/local/bin/wg-check-peers.sh
    - makedirs: true
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: wireguard

/usr/local/bin/wg-check-peers.sh:
  file.symlink:
    - target: /etc/wireguard-backbone/wg-check-peers.sh
    - force: true
    - require:
      - file: /etc/wireguard-backbone/wg-check-peers.sh

/var/www_freifunk/wg.cgi:
  file.managed:
    - source: https://github.com/Freifunk-Dresden/wg_accept_cgi/releases/download/{{ wg_accept_cgi_version }}/wg_accept_cgi
    - makedirs: true
    - user: www-data
    - group: www-data
    - mode: 755
    - require:
      - pkg: apache2

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

{# cron #}
/etc/cron.d/wg-backbone-check-peers:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        # Execute a local salt-call every hour
        {{ ctime }} */12 * * *  root  /usr/local/bin/wg-check-peers.sh
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron


{% endif %}
