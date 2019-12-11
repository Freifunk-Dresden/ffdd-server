{# Fail2ban (intrusion prevention system) #}
fail2ban:
  pkg.installed:
    - refresh: True
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
      - file: /etc/fail2ban/fail2ban.conf
      - file: /etc/fail2ban/jail.d/freifunk.conf


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
    - refresh: True
    - name: ipset

/etc/init.d/S43ipset_f2b:
  file.managed:
    - source: salt://fail2ban/etc/init.d/S43ipset_f2b
    - user: root
    - group: root
    - mode: 755

rc.d_S43ipset_f2b:
  cmd.run:
    - name: /usr/sbin/update-rc.d S43ipset_f2b defaults ; systemctl daemon-reload
    - require:
      - file: /etc/init.d/S43ipset_f2b
    - onchanges:
      - file: /etc/init.d/S43ipset_f2b

S43ipset_f2b:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pkg: iptables
      - pkg: ipset
      - service: S41firewall
      - file: /usr/local/sbin/ipset-fail2ban.sh
    - require:
      - pkg: iptables
      - pkg: ipset
      - service: S41firewall
      - service: fail2ban
      - file: /etc/init.d/S43ipset_f2b
      - file: /usr/local/sbin/ipset-fail2ban.sh
      - file: /etc/ipset-fail2ban/ipset-fail2ban.conf
      - cmd: rc.d_S43ipset_f2b
      - ipset-f2b-init


/usr/local/sbin/ipset-fail2ban.sh:
  file.managed:
    - source: salt://fail2ban/usr/local/sbin/ipset-fail2ban.sh
    - user: root
    - group: root
    - mode: 755

{# Configuration #}
/etc/ipset-fail2ban/ipset-fail2ban.conf:
  file.managed:
    - source: salt://fail2ban/etc/ipset-fail2ban/ipset-fail2ban.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: true

{# local f2b actions overwrite defaults #}
/etc/fail2ban/action.d/iptables-allports.local:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/action.d/iptables-allports.local
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban

/etc/fail2ban/action.d/iptables-multiport.local:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/action.d/iptables-multiport.local
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban

{# cron #}
/etc/cron.d/blacklist_fail2ban:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        #
        # update list every 30min
        0-59/30 * * * *  root  /usr/local/sbin/ipset-fail2ban.sh /etc/ipset-fail2ban/ipset-fail2ban.conf >/dev/null 2>&1
        # clear list once per day
        0 0 * * *        root  /usr/local/sbin/ipset-fail2ban.sh /etc/ipset-fail2ban/ipset-fail2ban.conf -c >/dev/null 2>&1
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: fail2ban
      - pkg: ipset
      - pkg: cron

{# first time exec #}
ipset-f2b-init:
  cmd.run:
    - name: /usr/local/sbin/ipset-fail2ban.sh /etc/ipset-fail2ban/ipset-fail2ban.conf >/dev/null 2>&1; exit 0
    - unless: "[ -f /etc/ipset-fail2ban/ipset-fail2ban.restore ]"
    - require:
      - service: fail2ban

{# unban helper-script #}
/usr/local/bin/f2b-unban:
  file.managed:
    - contents: |
        #!/usr/bin/env bash
        ### This file managed by Salt, do not edit by hand! ###
        if [ -n "$1" ]; then
          /usr/bin/fail2ban-client set sshd unbanip "$1"
          /bin/sed -i "/$1/d" /etc/ipset-fail2ban/ipset-fail2ban.list
          /sbin/ipset del blacklist_fail2ban "$1"
        fi
        exit 0
    - user: root
    - group: root
    - mode: 755
