# provides /etc/resolv.conf
{%- set resolv_conf = '/etc/resolv.conf' %}

# remove conflicting packages
remove_resolvconf:
  pkg.removed:
    - names:
      - resolvconf

{{ resolv_conf }}:
  file.managed:
    - contents: |
        search ffdd
        nameserver 10.200.0.4
        nameserver 127.0.0.1
    - user: root
    - group: root
    - mode: 644
    - attrs: i

# force chattr +i
{{ resolv_conf }}-locked:
  cmd.run:
    - name: chattr +i {{ resolv_conf }}
    - onchanges:
      - file: {{ resolv_conf }}
