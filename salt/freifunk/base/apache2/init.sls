apache2:
  pkg.installed:
    - name: apache2
  service:
    - running
    - name: apache2
    - enable: True
    - restart: True
    - watch:
      - pkg: apache2
      - file: /etc/apache2/sites-enabled/001-freifunk.conf
      - file: /etc/apache2/conf-enabled/letsencrypt.conf
      - file: /etc/apache2/conf-enabled/monitorix.conf
    - require:
      - pkg: apache2
      - service: S40network

apache2_pkgs:
  pkg.installed:
    - names:
      - apache2-utils
      - libapache2-mod-fcgid
      - libapache2-mod-auth-plain
      - libapache2-mod-authnz-pam
      - pwauth


/etc/apache2/sites-enabled/000-default.conf:
  file.absent

/var/www/html/index.html:
  file.absent


/etc/apache2/sites-enabled/001-freifunk.conf:
  file.managed:
    - source:
      - salt://apache2/etc/apache2/sites-enabled/001-freifunk.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/apache2/conf-enabled/letsencrypt.conf:
  file.managed:
    - source:
      - salt://apache2/etc/apache2/conf-enabled/letsencrypt.conf
    - user: root
    - group: root
    - mode: 644


/var/lib/letsencrypt/.well-known:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - makedirs: True

/var/www_freifunk:
  file.recurse:
    - source:
      - salt://apache2/var/www_freifunk
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - recurse:
      - user
      - group


apache2_mod_authnz_external:
  cmd.run:
    - name: /usr/sbin/a2enmod authnz_external
    - unless: "[ -f /etc/apache2/mods-enabled/authnz_external.load ]"

apache2_mod_cgi:
  cmd.run:
    - name: /usr/sbin/a2enmod cgi
    - unless: "[ -f /etc/apache2/mods-enabled/cgi.load ]"

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
