{# Network Time Protocol #}
{% from 'config.jinja' import nodeid, ddmesh_registerkey %}

ntp:
  pkg.installed:
    - refresh: true
    - name: ntp
  service:
    - running
    - enable: true
    - restart: true
    - watch:
      - file: /etc/ntp.conf
{% if nodeid != '' and nodeid != '-' or ddmesh_registerkey != '' and ddmesh_registerkey != '-' %}
      - service: S52batmand
      - service: S53backbone-fastd2
{% endif %}
    - require:
      - pkg: ntp
      - file: /etc/ntp.conf
{% if grains['os'] == 'Debian' and grains['oscodename'] == 'stretch' or grains['os'] == 'Ubuntu' and grains['oscodename'] == 'xenial' %}
      - file: /etc/init.d/ntp
      - cmd: rc.d_ntp
{% else %}
      - file: /lib/systemd/system/ntp.service
{% endif %}
      - service: S40network
      - service: S41firewall


{# Configuration #}
/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/etc/ntp/ntp.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: ntp


{# Service #}
{% if grains['os'] == 'Debian' and grains['oscodename'] == 'stretch' or grains['os'] == 'Ubuntu' and grains['oscodename'] == 'xenial' %}

/etc/systemd/system/multi-user.target.wants/ntp.service:
  file.absent

/lib/systemd/system/ntp.service:
  file.absent

/etc/init.d/ntp:
  file.managed:
    - source: salt://ntp/etc/init.d/ntp
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: ntp
    - require_in:
      - service: ntp

rc.d_ntp:
  cmd.run:
    - name: /usr/sbin/update-rc.d ntp defaults ; systemctl daemon-reload
    - require:
      - file: /etc/init.d/ntp
    - onchanges:
      - file: /etc/init.d/ntp

{% else %}

/lib/systemd/system/ntp.service:
  file.managed:
    - source: salt://ntp/lib/systemd/system/ntp.service
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: systemd
      - pkg: ntp
    - require_in:
      - service: ntp
{% endif %}
