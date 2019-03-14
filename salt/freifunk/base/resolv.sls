# provides /etc/resolv.conf
{%- set resolv_conf = '/etc/resolvconf/resolv.conf.d/head' %}

# temp. remove old chattr on /etc/resolv.conf
/etc/resolv.conf-unlock:
  cmd.run:
    - name: chattr -i /etc/resolv.conf
#

pkg_resolvconf:
  pkg.installed:
    - name: resolvconf

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

{{ resolv_conf }}-update:
  cmd.run:
    - name: resolvconf -u
    - onchanges:
      - file: {{ resolv_conf }}
