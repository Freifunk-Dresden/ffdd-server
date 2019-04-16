{# Fail2ban (intrusion prevention system) #}
fail2ban:
  pkg.installed:
    - name: fail2ban
  service:
    - running
    - name: fail2ban
    - enable: True
    - restart: True
    - watch:
      - pkg: fail2ban
      - service: S41firewall
      - file: /etc/fail2ban/fail2ban.conf
      - file: /etc/fail2ban/jail.d/freifunk.conf
    - require:
      - pkg: fail2ban
      - service: S40network
      - service: S41firewall

{# Fail2ban Installation Check #}
fail2ban_check:
  cmd.run:
    - name: logger -t "rc.local" "restart fail2ban" ; mkdir -p /var/run/fail2ban ; /usr/sbin/service fail2ban restart
    - unless: "[ -d /var/run/fail2ban ]"

{# Configuration #}
/etc/fail2ban/fail2ban.conf:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/fail2ban.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban

/etc/fail2ban/jail.d/freifunk.conf:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/jail.d/freifunk.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban


{# ipset for fail2ban blacklist #}
{# source: https://github.com/ritsu/ipset-fail2ban #}
ipset:
  pkg.installed:
    - name: ipset

/usr/local/sbin/ipset-fail2ban.sh:
  file.managed:
    - source: salt://fail2ban/usr/local/sbin/ipset-fail2ban.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: fail2ban
      - pkg: ipset

{# Configuration #}
/etc/ipset-fail2ban/ipset-fail2ban.conf:
  file.managed:
    - source: salt://fail2ban/etc/ipset-fail2ban/ipset-fail2ban.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - require:
      - pkg: fail2ban
      - pkg: ipset

{# local f2b actions overwrite defaults #}
/etc/fail2ban/action.d/iptables-allports.local:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/action.d/iptables-allports.local
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
      - pkg: ipset

/etc/fail2ban/action.d/iptables-multiport.local:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/action.d/iptables-multiport.local
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
      - pkg: ipset

{# cron #}
/etc/cron.d/blacklist_fail2ban:
  file.managed:
    - source: salt://fail2ban/etc/cron.d/blacklist_fail2ban
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
      - pkg: ipset

{# first time exec #}
ipset-f2b-init:
  cmd.run:
    - name: /usr/local/sbin/ipset-fail2ban.sh /etc/ipset-fail2ban/ipset-fail2ban.conf
    - unless: "[ -f /etc/ipset-fail2ban/ipset-fail2ban.restore ]"
    - require:
      - pkg: fail2ban
      - pkg: ipset

{# unban helper-script #}
/usr/local/bin/f2b-unban.sh:
  file.managed:
    - contents: |
        #!/usr/bin/env bash
        /usr/bin/fail2ban-client set sshd unbanip "$1"
        /bin/sed -i "/$1/d" /etc/ipset-fail2ban/ipset-fail2ban.list
        /sbin/ipset del blacklist_fail2ban "$1"
    - user: root
    - group: root
    - mode: 755
