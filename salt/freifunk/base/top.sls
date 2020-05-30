base:
  '*':
    - apt

    {# remove conflicting packages/files #}
    - remove_pkg

    {# clear old obsolete states from old versions #}
    - clear_old_env

    {# basic software and tools #}
    - install_pkg
    - devel
    - tools

    {# system defaults #}
    - root
    - users

    - bash
    - inputrc

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
    - uci

    - bmxd
    - fastd

    - ddmesh
    - ddmesh.autoconfig
    - ddmesh.autoupdate

    {# networking / firewall #}
    - iproute2
    - network
    - iptables
    - conntrack

    {# f2b with ipset #}
    - fail2ban
    - fail2ban.ipset

    {# services #}
    - ssh
    - bind
    - openvpn
    - wireguard

    - iperf3
    - vnstat
    - apache2
    - php
    - letsencrypt

    {# server webpages #}
    - ddmesh.serverpage
    - ddmesh.serverpage_ssl
    - monitorix
    - bind.stats
    - vnstat.dashboard
