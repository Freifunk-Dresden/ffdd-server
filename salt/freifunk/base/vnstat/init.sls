vnstat:
  pkg.installed:
    - name: vnstat
  service.running:
    - enable: True
    - restart: True


vnstat_bat0:
  cmd.run:
    - name: /usr/bin/vnstat -u -i bat0
    - unless: "[ -f /var/lib/vnstat/bat0 ]"

vnstat_tbb_fastd2:
  cmd.run:
    - name: /usr/bin/vnstat -u -i tbb_fastd2
    - unless: "[ -f /var/lib/vnstat/tbb_fastd2 ]"

vnstat_vpn0:
  cmd.run:
    - name: /usr/bin/vnstat -u -i vpn0
    - unless: "[ -f /var/lib/vnstat/vpn0 ]"
    - unless: "[ ! -f /etc/openvpn/openvpn.conf ]"

vnstat_vpn1:
  cmd.run:
    - name: /usr/bin/vnstat -u -i vpn1
    - unless: "[ -f /var/lib/vnstat/vpn1 ]"
    - unless: "[ ! -f /etc/openvpn/openvpn1.conf ]"


/var/www_vnstat:
  file.recurse:
    - source:
      - salt://vnstat/var/www_vnstat
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - recurse:
      - user
      - group

/var/www_vnstat/config.php:
  file.managed:
    - source:
      - salt://vnstat/var/www_vnstat/config.tmpl
    - template: jinja
    - user: www-data
    - group: www-data
    - mode: 644
    - require:
      - file: /var/www_vnstat


/etc/apache2/conf-enabled/vnstat_access.incl:
  file.managed:
    - source:
      - salt://vnstat/etc/apache2/conf-enabled/vnstat_access.incl
    - user: root
    - group: root
    - mode: 644
    - replace: false

/etc/apache2/conf-enabled/vnstat.conf:
  file.managed:
    - source:
      - salt://vnstat/etc/apache2/conf-enabled/vnstat.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2
      - file: /etc/apache2/conf-enabled/vnstat_access.incl


apache2_mod_php:
  cmd.run:
    - name: /usr/sbin/a2enmod php7.0
    - unless: "[ ! -f /etc/apache2/mods-enabled/php7.0.load ]"
