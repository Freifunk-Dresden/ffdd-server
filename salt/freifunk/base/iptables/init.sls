iptables:
  pkg.installed:
    - names:
      - iptables


# IPv4 Firewall
/etc/init.d/S41firewall:
  file.managed:
    - source: salt://iptables/etc/init.d/S41firewall
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables

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

rc.d_S41firewall:
  cmd.run:
    - name: /usr/sbin/update-rc.d S41firewall defaults
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
      - file: /etc/init.d/S41firewall
      - file: /etc/firewall.user
      - service: S40network
    - require:
      - pkg: iptables
      - service: S40network
      - file: /etc/firewall.user


# IPv6 Firewall
/etc/init.d/S42firewall6:
  file.managed:
    - source: salt://iptables/etc/init.d/S42firewall6
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iptables

rc.d_S42firewall6:
  cmd.run:
    - name: /usr/sbin/update-rc.d S42firewall6 defaults
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
