{# sysctl #}
{% from 'config.jinja' import chassis %}
{% set sysctld = "/etc/sysctl.d" %}

net.ipv4.conf.all.forwarding:
  sysctl.present:
    - value: 1
    - config: {{ sysctld }}/forward.conf

{# bmxd doesnt like rp_filter #}

net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1
    - config: {{ sysctld }}/net.conf

{# increase conntrack hash table #}
{% if chassis != 'container' %}

net.netfilter.nf_conntrack_max:
  sysctl.present:
    - value: 200000
    - config: {{ sysctld }}/net.conf

{% endif %}
