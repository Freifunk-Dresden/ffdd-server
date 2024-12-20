{# System Monitor (Webpage) #}
monitorix:
  pkgrepo.managed:
    - humanname: Monitorix
    - name: deb [arch=all] https://apt.izzysoft.de/ubuntu generic universe
    - file: /etc/apt/sources.list.d/monitorix.list
    - clean_file: true
    - gpgcheck: 1
    - key_url: https://apt.izzysoft.de/izzysoft.asc
  pkg.installed:
    - refresh: True
    - names:
      - monitorix
    - require:
      - pkgrepo: monitorix
      - file: /etc/monitorix/monitorix.conf
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pkg: monitorix
      - file: /etc/monitorix/monitorix.conf
    - require:
      - pkg: monitorix
      - pkg: apache2
      - service: S40network
      - file: /etc/monitorix/monitorix.conf
      - file: /var/lib/monitorix/www/imgs


{# Configuration #}
/etc/monitorix/monitorix.conf:
  file.managed:
    - source: salt://monitorix/etc/monitorix/monitorix.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - makedirs: true


{# enable monitorix Apache2 config #}
/etc/apache2/conf-available/monitorix_access.incl:
  file.managed:
    - source: salt://monitorix/etc/apache2/conf-available/monitorix_access.incl
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - pkg: apache2

/etc/apache2/conf-available/monitorix.conf:
  file.managed:
    - source: salt://monitorix/etc/apache2/conf-available/monitorix.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2
      - file: /etc/apache2/conf-available/monitorix_access.incl

apache2_conf_enable_monitorix:
  apache_conf.enabled:
    - name: monitorix
    - require:
      - pkg: apache2
      - file: /etc/apache2/conf-available/monitorix.conf

{# Monitorix Images Permissions #}
/var/lib/monitorix/www/imgs:
  file.directory:
    - user: www-data
    - group: www-data
    - recurse:
      - user
      - group
    - require:
      - pkg: monitorix
