{# FFDD - HTTPS Server Page #}
{% from 'config.jinja' import ffddip, hostname %}

{# check hostname has the correct format and is not NAT'd over freifunk-dresden.de or use internal domain 'ffdd' #}
{%- set check_fqdn = salt['cmd.shell']("h=" ~ hostname ~ " ; [[ ${h//[^.]} != '' ]] && [[ $(echo $h | awk -F'.' '{print $2}') != 'ffdd' ]] && host $h | grep -v " ~ ffddip ~ " > /dev/null ; if [ $? -eq 0 ]; then echo $h ; fi || true") -%}

{% if check_fqdn != '' %}

generate_dhparam:
  cmd.run:
    - name: /usr/bin/openssl dhparam -out /etc/ssl/certs/freifunk_dhparam.pem 2048
    - unless: "[ -f /etc/ssl/certs/freifunk_dhparam.pem ]"
    - unless: "[ -s /etc/ssl/certs/freifunk_dhparam.pem ]"

generate_certificate:
  cmd.run:
    - name: /usr/bin/certbot certonly --agree-tos --email hostmaster@freifunk-dresden.de --webroot -w /var/lib/letsencrypt/ -d {{ hostname }} --non-interactive
    - unless: "[ -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"


{# enable Apache2 SSL Webpage for FFDD #}
/etc/apache2/conf-available/ssl-params.conf:
  file.managed:
    - source: salt://ddmesh/etc/apache2/conf-available/ssl-params.conf
    - user: root
    - group: root
    - mode: 644

apache2_conf_enable_ssl:
  apache_conf.enabled:
    - name: ssl-params
    - require:
      - pkg: apache2


/etc/apache2/sites-available/001-freifunk-ssl.conf:
  file.managed:
    - source: salt://ddmesh/etc/apache2/sites-available/001-freifunk-ssl.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - unless: "[ ! -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"
    - require:
      - pkg: apache2

/etc/apache2/additional_443.conf:
  file.managed:
    - contents:
      - '# additional config for virtualhost on port 443'
    - replace: false
    - require:
      - pkg: apache2

apache2_site_enable_freifunk-ssl:
  apache_site.enabled:
    - name: 001-freifunk-ssl
    - require:
      - pkg: apache2
      - file: /etc/apache2/sites-available/001-freifunk-ssl.conf
      - file: /etc/apache2/additional_443.conf
      - file: /etc/apache2/conf-available/ssl-params.conf

apache2_ssl:
  service:
    - running
    - name: apache2
    - enable: True
    - restart: True
    - watch:
      - file: /etc/apache2/conf-available/ssl-params.conf
      - file: /etc/apache2/sites-available/001-freifunk-ssl.conf
      - file: /etc/apache2/additional_443.conf
      - apache2_mod_ssl
    - require:
      - file: /etc/apache2/conf-available/ssl-params.conf
      - file: /etc/apache2/sites-available/001-freifunk-ssl.conf
      - file: /etc/apache2/additional_443.conf
      - apache2_site_enable_freifunk-ssl
      - apache2_conf_enable_ssl
    - unless: "[ ! -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"


{# cron: automatically renew certs #}
/etc/cron.d/certbot:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        #
        # renew any ssl certificate 30 days before its expiration.
        0 */12 * * *  root  certbot -q renew --renew-hook "systemctl reload apache2" >/dev/null 2>&1
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
    - unless: "[ ! -f /etc/letsencrypt/live/{{ hostname }}/cert.pem ]"


{# Temp. Force Renew dhparm and certs #}
{# Activated Force-Renew #}
{#
force-renew-ssl:
  cmd.run:
    - name: "touch /etc/ssl/temp-check-ssl ; /usr/bin/openssl dhparam -out /etc/ssl/certs/freifunk_dhparam.pem 4096 ; /usr/bin/certbot -q renew --force-renewal --renew-hook 'systemctl reload apache2'"
    - unless: "[ -f /etc/ssl/temp-check-ssl ]"
#}

{# Deactivated Force-Renew #}
/etc/ssl/temp-check-ssl:
  file.absent


{% else %}

{# ensure ssl-site is absent then deactivated #}
apache2_site_disable_freifunk-ssl:
  apache_site.disabled:
    - name: 001-freifunk-ssl
    - require:
      - pkg: apache2

apache2_conf_disable_ssl:
  apache_conf.disabled:
    - name: ssl-params
    - require:
      - pkg: apache2

{% endif %}
