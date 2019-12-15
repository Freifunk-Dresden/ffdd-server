{# FFDD - Server Page #}
/etc/apache2/sites-available/001-freifunk.conf:
  file.managed:
    - source: salt://ddmesh/etc/apache2/sites-available/001-freifunk.conf.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2

apache2_site_enable_freifunk:
  apache_site.enabled:
    - name: 001-freifunk
    - require:
      - pkg: apache2
      - file: /etc/apache2/sites-available/001-freifunk.conf
      - file: /var/www_freifunk

/var/www_freifunk:
  file.recurse:
    - source: salt://ddmesh/var/www_freifunk
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - keep_symlinks: True
    - force_symlinks: True
    - clean: True
    - recurse:
      - user
      - group
