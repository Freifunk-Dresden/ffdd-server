base:
  '*':
    - apt

    {# remove conflicting packages #}
    - remove_pkg
    {# basic software and tools #}
    - install_pkg
    - tools

    {# system defaults #}
    - root
    - users

    - bash
    - inputrc
    - vim

    - locales
    - timezone
    - ntp

    - kernel
    - kernel.sysctl

    - systemd
    - sudo
    - rsyslog
    - logrotate
    - cron

    {# core-tools #}
    - salt-minion
    - ddmesh
    - nvram

    {# compilling #}
    - devel
    - bmxd
    - fastd
    {#- cjdns #}

    {# networking / firewall #}
    - iproute2
    - network
    - iptables
    - conntrack

    {# f2b with ipset #}
    - fail2ban

    {# services #}
    - ssh
    - openvpn
    - wireguard
    - bind

    - iperf3
    - apache2
    - php
    - letsencrypt
    - monitorix
    - vnstat

    {# /etc/resolv.conf#}
    - resolv
