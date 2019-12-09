{# FFDD Firewall #}
iptables:
  pkg.installed:
    - refresh: True
    - names:
      - iptables


{# IPv4 Firewall #}
/etc/init.d/S41firewall:
  file.managed:
    - source: salt://iptables/etc/init.d/S41firewall
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables

{# Custom User Firewall-Rules #}
/etc/firewall.user:
  file.managed:
    - source: salt://iptables/etc/firewall.user
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - file: /etc/init.d/S41firewall
      - pkg: iptables

{# IPv4 Service #}
rc.d_S41firewall:
  cmd.run:
    - name: /usr/sbin/update-rc.d S41firewall defaults ; systemctl daemon-reload
    - require:
      - file: /etc/init.d/S41firewall
    - onchanges:
      - file: /etc/init.d/S41firewall

S41firewall:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pkg: iptables
      - pkg: ipset
      - service: S40network
      - service: monitorix
      - file: /etc/init.d/S41firewall
      - file: /etc/firewall.user
    - require:
      - pkg: iptables
      - pkg: ipset
      - service: S40network
      - file: /etc/init.d/S41firewall
      - file: /etc/firewall.user
      - file: /usr/local/sbin/ipset-fail2ban.sh
      - file: /etc/ipset-fail2ban/ipset-fail2ban.conf


{# IPv6 Firewall #}
/etc/init.d/S42firewall6:
  file.managed:
    - source: salt://iptables/etc/init.d/S42firewall6
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables

{# IPv6 Service #}
rc.d_S42firewall6:
  cmd.run:
    - name: /usr/sbin/update-rc.d S42firewall6 defaults ; systemctl daemon-reload
    - require:
      - file: /etc/init.d/S42firewall6
    - onchanges:
      - file: /etc/init.d/S42firewall6

S42firewall6:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/init.d/S42firewall6
      - service: S40network
    - require:
      - pkg: iptables
      - service: S40network
