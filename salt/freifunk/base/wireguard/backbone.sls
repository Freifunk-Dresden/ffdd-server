{# Wireguard Backbone #}
{% from 'config.jinja' import ctime, wg_accept_cgi_version, wg_accept_cgi_sha1_hash %}

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


/var/www_freifunk_additional/wg.cgi:
  file.managed:
    - source: https://github.com/Freifunk-Dresden/wg_accept_cgi/releases/download/{{ wg_accept_cgi_version }}/wg_accept_cgi
    - source_hash: sha1={{ wg_accept_cgi_sha1_hash }}
    - makedirs: true
    - user: www-data
    - group: www-data
    - mode: 755
    - require:
      - pkg: apache2

/etc/config/wg_cgi:
  file.managed:
    - source: salt://wireguard/etc/config/wg_cgi
    - makedirs: true
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: wireguard

{# cron #}
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
        #
        # start wg-backbone after boot
        @reboot   root  /usr/local/bin/wg-backbone.sh start
        # reload peers and re-add interfaces to bmxd
        * * * * * root  /usr/local/bin/wg-backbone.sh reload
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - pkg: wireguard
      - file: /usr/local/bin/wg-backbone.sh

/etc/cron.d/wg-backbone-check-peers:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/bash
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        # Check lastseen of peers to delete not used peers every hour
        {{ ctime }} */12 * * *  root  /usr/local/bin/wg-check-peers.sh
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - file: /usr/local/bin/wg-check-peers.sh
