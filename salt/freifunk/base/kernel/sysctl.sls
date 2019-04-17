{# sysctl #}
{% set sysctld = "/etc/sysctl.d" %}

{# Reboot 1 second after kernel panic, oops or BUG #}
kernel.panic:
  sysctl.present:
    - value: 1
    - config: {{ sysctld }}/panic.conf

kernel.panic_on_oops:
  sysctl.present:
    - value: 1
    - config: {{ sysctld }}/panic.conf

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
