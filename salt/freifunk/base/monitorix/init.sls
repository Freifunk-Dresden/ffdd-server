monitorix:
  pkgrepo.managed:
    - humanname: Monitorix
    - name: deb http://apt.izzysoft.de/ubuntu generic universe
    - dist: generic
    - file: /etc/apt/sources.list.d/monitorix.list
    - gpgcheck: 1
    - key_url: http://apt.izzysoft.de/izzysoft.asc
  pkg.installed:
    - names:
      - monitorix
    - require:
      - pkgrepo: monitorix
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pkg: monitorix
      - service: S41firewall
      - file: /etc/monitorix/monitorix.conf
    - require:
      - pkg: monitorix
      - pkg: apache2

/etc/monitorix/monitorix.conf:
  file.managed:
    - source:
      - salt://monitorix/etc/monitorix/monitorix.conf
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - pkg: monitorix

apache2_mod_status:
  cmd.run:
    - name: /usr/sbin/a2enmod status
    - require:
      - pkg: apache2
    - unless: "[ -f /etc/apache2/mods-enabled/status.load ]"

/etc/apache2/conf-enabled/monitorix.conf:
  file.managed:
    - source:
      - salt://monitorix/etc/apache2/conf-enabled/monitorix.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2
