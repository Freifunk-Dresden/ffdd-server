{# Web Traffic Dashboard #}
php_composer:
  pkg.installed:
    - refresh: True
    - name: composer
    - require:
      - pkg: php

vnstat_dashboard_repo:
  git.latest:
    - name: https://github.com/alexandermarston/vnstat-dashboard.git
    - rev: e104594
    - target: /opt/vnstat-dashboard
    - update_head: True
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git

compose_vnstat_dashboard:
  cmd.run:
    - name: |
        rm -rf /var/www_vnstat ; mkdir -p /var/www_vnstat/
        cp -rp /opt/vnstat-dashboard/app/* /var/www_vnstat/
        cd /var/www_vnstat/ ; composer install
        chown -R www-data:www-data /var/www_vnstat/
    - require:
      - pkg: composer
      - vnstat_dashboard_repo
    - onchanges:
      - vnstat_dashboard_repo

{# Configuration #}
/var/www_vnstat/includes/config.php:
  file.managed:
    - source: salt://vnstat/var/config.tmpl
    - template: jinja
    - user: www-data
    - group: www-data
    - mode: 644
    - require:
      - compose_vnstat_dashboard
      - vnstat_dashboard_repo


{# enable vnstat Apache2 config #}
/etc/apache2/conf-available/vnstat.conf:
  file.managed:
    - source: salt://vnstat/etc/apache2/conf-available/vnstat.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2

apache2_conf_enable_vnstat:
  apache_conf.enabled:
    - name: vnstat
    - require:
      - pkg: apache2
      - file: /etc/apache2/conf-available/vnstat.conf
      - apache2_mod_php
