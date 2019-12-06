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
  file.absent

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
apache2_mod_authnz_external:
  cmd.run:
    - name: /usr/sbin/a2enmod authnz_external
    - unless: "[ -f /etc/apache2/mods-enabled/authnz_external.load ]"


apache2_mod_mpmevent:
  cmd.run:
    - name: /usr/sbin/a2dismod mpm_event
    - unless: "[ ! -f /etc/apache2/mods-enabled/mpm_event.load ]"

apache2_mod_mpmworker:
  cmd.run:
    - name: /usr/sbin/a2dismod mpm_worker
    - unless: "[ ! -f /etc/apache2/mods-enabled/mpm_worker.load ]"

apache2_mod_mpmprefork:
  cmd.run:
    - name: /usr/sbin/a2enmod mpm_prefork
    - unless: "[ -f /etc/apache2/mods-enabled/mpm_prefork.load ]"


apache2_mod_cgi:
  cmd.run:
    - name: /usr/sbin/a2dismod cgi
    - unless: "[ ! -f /etc/apache2/mods-enabled/cgi.load ]"

apache2_mod_cgid:
  cmd.run:
    - name: /usr/sbin/a2enmod cgid
    - unless: "[ -f /etc/apache2/mods-enabled/cgid.load ]"


apache2_mod_proxy:
  cmd.run:
    - name: /usr/sbin/a2enmod proxy
    - unless: "[ -f /etc/apache2/mods-enabled/proxy.load ]"

apache2_mod_proxy_http:
  cmd.run:
    - name: /usr/sbin/a2enmod proxy_http
    - unless: "[ -f /etc/apache2/mods-enabled/proxy_http.load ]"

apache2_mod_proxy_html:
  cmd.run:
    - name: /usr/sbin/a2enmod proxy_html
    - unless: "[ -f /etc/apache2/mods-enabled/proxy_html.load ]"

apache2_mod_rewrite:
  cmd.run:
    - name: /usr/sbin/a2enmod rewrite
    - unless: "[ -f /etc/apache2/mods-enabled/rewrite.load ]"

apache2_mod_deflate:
  cmd.run:
    - name: /usr/sbin/a2enmod deflate
    - unless: "[ -f /etc/apache2/mods-enabled/deflate.load ]"

apache2_mod_xml2enc:
  cmd.run:
    - name: /usr/sbin/a2enmod xml2enc
    - unless: "[ -f /etc/apache2/mods-enabled/xml2enc.load ]"

apache2_mod_headers:
  cmd.run:
    - name: /usr/sbin/a2enmod headers
    - unless: "[ -f /etc/apache2/mods-enabled/headers.load ]"
