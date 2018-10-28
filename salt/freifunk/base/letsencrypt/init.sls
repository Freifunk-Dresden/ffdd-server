letsencrypt:
  {% if grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - ppa: certbot/certbot
  {% endif %}
  pkg.installed:
    - name: certbot
    - refresh: True

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


{% from 'config.jinja' import ffdom, hostname %}
{%- set ffip = salt['cmd.shell']("dig " ~ ffdom ~ " +short" ) -%}
{%- set hdns = salt['cmd.shell']("host " ~ hostname ~ " | grep -v " ~ ffip ~ " 2>&1 > /dev/null; if [ $? -eq 0 ]; then ; printf '%s\n' " ~ hostname ~ " ; fi || true") -%}

{% if hdns != '' %}
generate_certificate:
  cmd.run:
    - name: /usr/bin/certbot certonly --agree-tos --email webmaster@localhost --webroot -w /var/lib/letsencrypt/ -d {{ hostname }} --non-interactive
    - unless: "[ -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"


/etc/apache2/sites-enabled/001-freifunk-ssl.conf:
  file.managed:
    - source:
      - salt://letsencrypt/etc/apache2/sites-enabled/001-freifunk-ssl.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - unless: "[ ! -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"

apache2_ssl:
  service:
    - running
    - name: apache2
    - enable: True
    - restart: True
    - watch:
      - file: /etc/apache2/sites-enabled/001-freifunk-ssl.conf
      - file: /etc/apache2/conf-enabled/ssl-params.conf
    - unless: "[ ! -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"


/etc/cron.d/certbot:
  file.managed:
    - source: salt://letsencrypt/etc/cron.d/certbot
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
    - unless: "[ ! -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"

{% endif %}
