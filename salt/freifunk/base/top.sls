base:
  '*':
    {# cleanup old server version #}
    - clear_oldenv

    - apt

    {# remove conflicting packages #}
    - remove_pkg
    {# basic software and tools #}
    - install_pkg
    - tools

    - root
    - users

    - bash
    - inputrc
    - vim

    - locales
    - timezone
    - ntp
    - cron
    - sysctl
    - systemd
    - sudo
    - rsyslog
    - logrotate

    {# Compilling #}
    - devel
    - bmxd
    - fastd
    {#- cjdns #}

    - salt-minion
    - ddmesh
    - nvram

    {# Networking / Firewall #}
    - iproute2
    - network
    - iptables
    - conntrack

    {# F2B with ipset #}
    - fail2ban

    {# Services #}
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
