{# sysctl #}
{% set sysctld = "/etc/sysctl.d" %}

{# TMP: clear old env #}
/etc/sysctl.d/panic.conf:
  file.absent

/etc/sysctl.d/forward.conf:
  file.absent

{# forwarding #}
net.ipv4.conf.all.forwarding:
  sysctl.present:
    - value: 1
    - config: {{ sysctld }}/forward.conf

{# increase conntrack hash table #}
net.netfilter.nf_conntrack_max:
  sysctl.present:
    - value: 200000
    - config: {{ sysctld }}/net.conf
