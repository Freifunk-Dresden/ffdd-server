base:
  '*':
    # cleanup old server version
    - clear_oldenv

    - apt
    # remove conflicting packages
    - remove_pkg
    # basic software and tools
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

    # Compilling
    - devel
    - bmxd
    - fastd

    - salt-minion
    - ddmesh
    - nvram

    # Networking / Firewall
    - iproute2
    - network
    - iptables
    - conntrack

    - fail2ban

    # Services
    - ssh
    - openvpn
    - bind

    - iperf3
    - apache2
    - php
    - letsencrypt
    - monitorix
    - vnstat
