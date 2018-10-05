php:
  pkg.installed:
    - names:
      - php-common

php_mod_freifunk.ini:
  file.managed:
    - name: /etc/php/7.0/mods-available/freifunk.ini
    - source:
      - salt://php/etc/php/mods-available/freifunk.ini
    - user: root
    - group: root
    - mode: 644
    - watch:
      - pkg: php-common
