{# Network Time Protocol #}
ntp:
  pkg.installed:
    - refresh: true
    - name: ntp
  service:
    - running
    - enable: true
    - restart: true
    - reload: true
    - watch:
      - file: /etc/ntp.conf
    - require:
      - pkg: ntp
      - file: /etc/ntp.conf
{% if grains['os'] == 'Debian' and grains['oscodename'] == 'stretch' or grains['os'] == 'Ubuntu' and grains['oscodename'] == 'xenial' %}
      - file: /etc/init.d/ntp
      - cmd: rc.d_ntp
{% else %}
      - file: /lib/systemd/system/ntp.service
{% endif %}


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
