{# clear old env #}

{# apt #}
/etc/cron.d/apt-update:
  file.absent

{# resolvconf #}
{%- set resolv_conf = '/etc/resolvconf/resolv.conf.d/head' %}
resolvconf-clean:
  cmd.run:
    - name: chattr -i {{ resolv_conf }} ; truncate -s 0 {{ resolv_conf }}
    - onlyif: test -s {{ resolv_conf }}
