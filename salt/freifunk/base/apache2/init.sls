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
      - file: /etc/apache2/sites-available/001-freifunk.conf
      - file: /etc/apache2/conf-available/letsencrypt.conf
      - file: /etc/apache2/conf-available/bind_stats.conf
      - file: /etc/apache2/conf-available/bind_stats_access.incl
      - file: /etc/apache2/conf-available/monitorix.conf
      - file: /etc/apache2/conf-available/monitorix_access.incl
      - file: /etc/apache2/conf-available/vnstat.conf
    - require:
      - pkg: apache2
      - service: S40network
      - service: S41firewall
      - file: /etc/apache2/sites-available/001-freifunk.conf
      - file: /etc/apache2/conf-available/letsencrypt.conf


{# disable default page #}
apache2_site_disable_default:
  apache_site.disabled:
    - name: 000-default.conf

/var/www/html/index.html:
  file.absent


{# enable FFDD server page #}
/etc/apache2/sites-available/001-freifunk.conf:
  file.managed:
    - source: salt://apache2/etc/apache2/sites-available/001-freifunk.conf.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644

apache2_site_enable_freifunk:
  apache_site.enabled:
    - name: 001-freifunk.conf

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
