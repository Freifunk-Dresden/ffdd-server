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
      - file: /var/www_freifunk
      - apache2_site_enable_freifunk


{# disable default page #}
apache2_site_disable_default:
  apache_site.disabled:
    - name: 000-default

/var/www/html/index.html:
  file.absent


{# check Apache2 Modules #}
apache2_mod_disable:
  apache_module.disabled:
    - names:
      - mpm_event
      - mpm_worker
      - cgi
    - require:
      - pkg: apache2

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
    - require:
      - pkg: apache2
