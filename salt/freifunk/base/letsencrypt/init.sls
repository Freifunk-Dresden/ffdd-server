letsencrypt:
  pkg.installed:
    - names:
      - certbot
      - python-certbot-apache


apache2_mod_ssl:
  cmd.run:
    - name: /usr/sbin/a2enmod ssl
    - unless: "[ -f /etc/apache2/mods-enabled/ssl.load ]"


/etc/apache2/conf-enabled/ssl-params.conf:
  file.managed:
    - source:
      - salt://letsencrypt/etc/apache2/conf-enabled/ssl-params.conf
    - user: root
    - group: root
    - mode: 644


#
# autoconfigure a new server
#
generate_dhparam:
  cmd.run:
    - name: /usr/bin/openssl dhparam -out /etc/ssl/certs/freifunk_dhparam.pem 2048
    - unless: "[ -f /etc/ssl/certs/freifunk_dhparam.pem ]"


{% set nodeid = salt['cmd.shell']('/usr/local/bin/nvram get ddmesh_node') %}
{% set nodeip = salt['cmd.shell']("ifconfig bmx_prime | grep inet | awk '/inet/ {print $2}'") %}


{% if nodeip != '' %}
generate_certificate:
  cmd.run:
    - name: /usr/bin/certbot certonly --agree-tos --email webmaster@localhost --webroot -w /var/lib/letsencrypt/ -d {{ nodeid }}.freifunk-dresden.de -d {{ nodeip }}.freifunk-dresden.de
    - unless: "[-f /etc/letsencrypt/live/{{ nodeid }}.freifunk-dresden.de/cert.pem ]"
{% endif %}


{% if salt['file.directory_exists']('/etc/letsencrypt/live/{{ nodeid }}.freifunk-dresden.de/cert.pem') %}
/etc/apache2/sites-enabled/002-freifunk-ssl.conf:
  file.managed:
    - source:
      - salt://letsencrypt/etc/apache2/sites-enabled/002-freifunk-ssl.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644

apache2_ssl:
  service:
    - running
    {% if grains['os'] == 'Debian' or grains['os'] == 'Ubuntu' or grains['os'] == 'Gentoo' %}
    - name: apache2
    {% endif %}
    - enable: True
    - restart: True
    - watch:
      - file: /etc/apache2/sites-enabled/002-freifunk-ssl.conf
      - file: /etc/apache2/conf-enabled/ssl-params.conf

/etc/cron.d/certbot:
  file.managed:
    - source: salt://letsencrypt/etc/cron.d/certbot
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron

{% endif %}
