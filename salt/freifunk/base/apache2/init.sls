{# Apache2 Webserver #}
apache2:
  pkg.installed:
    - refresh: True
    - names:
      - apache2
      - apache2-utils
      - libapache2-mod-evasive
      - libapache2-mod-fcgid
      - libapache2-mod-auth-plain
      - libapache2-mod-authnz-pam
      - libapache2-mod-authnz-external
      - pwauth
  service:
    - running
    - name: apache2
    - enable: True
    - restart: True
    - watch:
      - pkg: apache2
      - pkg: monitorix
      - pkg: vnstat
      - file: /etc/apache2/sites-enabled/001-freifunk.conf
      - file: /etc/apache2/conf-enabled/letsencrypt.conf
      - file: /etc/apache2/conf-enabled/bind_stats.conf
      - file: /etc/apache2/conf-enabled/bind_stats_access.incl
      - file: /etc/apache2/conf-enabled/monitorix.conf
      - file: /etc/apache2/conf-enabled/monitorix_access.incl
      - file: /etc/apache2/conf-enabled/vnstat.conf
    - require:
      - pkg: apache2
      - service: S40network
      - service: S41firewall
      - file: /etc/apache2/sites-enabled/001-freifunk.conf
      - file: /etc/apache2/conf-enabled/letsencrypt.conf


{# disable default page #}
/etc/apache2/sites-enabled/000-default.conf:
  apache_site.disabled:
    - name: 000-default

/var/www/html/index.html:
  file.absent


{# enable FFDD server page #}
/etc/apache2/sites-enabled/001-freifunk.conf:
  file.managed:
    - source: salt://apache2/etc/apache2/sites-enabled/001-freifunk.conf.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/var/www_freifunk:
  file.recurse:
    - source: salt://apache2/var/www_freifunk
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


{# check Apache2 Modules #}
apache2_mod_disable:
  apache_module.disabled:
    - names:
      - mpm_event
      - mpm_worker
      - cgi

apache2_mod_enable:
  apache_module.enabled:
    - names:
      - status
      - auth_basic
      - authnz_external
      - mpm_prefork
      - cgid
      - proxy
      - proxy_http
      - proxy_html
      - headers
      - rewrite
      - deflate
      - xml2enc
