{# clear old env #}

{# apt #}
/etc/cron.d/apt-update:
  file.absent

{# resolvconf #}
{%- set resolv_conf = '/etc/resolvconf/resolv.conf.d/head' %}

{# Configuration #}
{{ resolv_conf }}:
  file.managed:
    - contents: 
    - user: root
    - group: root
    - mode: 644

{# force chattr +i #}
resolvconf-locked:
  cmd.run:
    - name: chattr -i {{ resolv_conf }}
    - onchanges:
      - file: {{ resolv_conf }}
