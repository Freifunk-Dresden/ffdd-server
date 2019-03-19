# HTTPS-Cert from Let's Encrypt
letsencrypt:
  {% if grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - ppa: certbot/certbot
  {% endif %}
  pkg.installed:
    - name: certbot
    - refresh: True

# Configuration
/etc/letsencrypt/cli.ini:
  file.managed:
    - source:
      - salt://letsencrypt/etc/letsencrypt/cli.ini
    - user: root
    - group: root
    - mode: 644


# SSL Apache2 Module
apache2_mod_ssl:
  cmd.run:
    - name: /usr/sbin/a2enmod ssl
    - unless: "[ -f /etc/apache2/mods-enabled/ssl.load ]"


# letsencrypt requirements
/etc/apache2/conf-enabled/letsencrypt.conf:
  file.managed:
    - source:
      - salt://letsencrypt/etc/apache2/conf-enabled/letsencrypt.conf
    - user: root
    - group: root
    - mode: 644

/etc/apache2/conf-enabled/ssl-params.conf:
  file.managed:
    - source:
      - salt://letsencrypt/etc/apache2/conf-enabled/ssl-params.conf
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


#
# autoconfigure a new server
#
generate_dhparam:
  cmd.run:
    - name: /usr/bin/openssl dhparam -out /etc/ssl/certs/freifunk_dhparam.pem 4096
    - unless: "[ -f /etc/ssl/certs/freifunk_dhparam.pem ]"


# check hostname has the correct format and is not NAT'd over freifunk-dresden.de
{% from 'config.jinja' import ffdom, hostname %}
{%- set ffip = salt['cmd.shell']("dig " ~ ffdom ~ " +short || true") -%}
{%- set check_fqdn = salt['cmd.shell']("h=" ~ hostname ~ " ; [[ ${h//[^.]} != '' ]] && host $h | grep -v " ~ ffip ~ " 2>&1 > /dev/null ; if [ $? -eq 0 ]; then echo $h ; fi || true") -%}

{% if check_fqdn != '' %}

generate_certificate:
  cmd.run:
    - name: /usr/bin/certbot certonly --agree-tos --email hostmaster@freifunk-dresden.de --webroot -w /var/lib/letsencrypt/ -d {{ hostname }} --non-interactive
    - unless: "[ -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"


# enable Apache2 SSL Webpage for FFDD
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


#
# automatically renew certs
/etc/cron.d/certbot:
  file.managed:
    - source: salt://letsencrypt/etc/cron.d/certbot
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
    - unless: "[ ! -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"


#
# Temp. Force Renew dhparm and certs
#
#force-renew-ssl:
#  cmd.run:
#    - name: "touch /etc/ssl/temp-check-ssl ; /usr/bin/openssl dhparam -out /etc/ssl/certs/freifunk_dhparam.pem 4096 ; /usr/bin/certbot -q renew --force-renewal --renew-hook 'systemctl reload apache2'"
#    - unless: "[ -f /etc/ssl/temp-check-ssl ]"

# Deativated Force-Renew
/etc/ssl/temp-check-ssl:
  file.absent

{% endif %}
