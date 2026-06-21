{# FFDD Routing Tables #}
iproute2:
  pkg.installed:
    - refresh: True
    - name: iproute2


{% if grains['os'] == 'Debian' and (grains['oscodename'] == 'bullseye' or grains['oscodename'] == 'buster' ) %}
/etc/iproute2/rt_tables:
{% else %}
/usr/share/iproute2/rt_tables:
{% endif %}
  file.managed:
    - source: salt://iproute2/etc/iproute2/rt_tables
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iproute2
