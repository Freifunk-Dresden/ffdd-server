{# HTTPS-Cert from Let's Encrypt #}
letsencrypt:
  {% if grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - ppa: certbot/certbot
  {% endif %}
  pkg.installed:
    - name: certbot
    - refresh: True

{# Configuration #}
/etc/letsencrypt/cli.ini:
  file.managed:
    - source: salt://letsencrypt/etc/letsencrypt/cli.ini
    - user: root
    - group: root
    - mode: 644


{# SSL Apache2 Module #}
apache2_mod_ssl:
  apache_module.enabled:
    - name: ssl
    - require:
      - pkg: apache2

{# letsencrypt requirements #}
/etc/apache2/conf-available/letsencrypt.conf:
  file.managed:
    - source: salt://letsencrypt/etc/apache2/conf-available/letsencrypt.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2

apache2_conf_enable_letsencrypt:
  apache_conf.enabled:
    - name: letsencrypt
    - require:
      - pkg: apache2
      - file: /etc/apache2/conf-available/letsencrypt.conf

/var/lib/letsencrypt/.well-known:
  file.directory:
    - user: www-data
    - group: www-data
    - file_mode: 755
    - dir_mode: 755
    - makedirs: true
