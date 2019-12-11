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

{# Custom User Firewall-Rules #}
/etc/firewall.user:
  file.managed:
    - source: salt://iptables/etc/firewall.user
    - user: root
    - group: root
    - mode: 644
    - replace: false

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
      - file: /etc/init.d/S41firewall
      - file: /etc/firewall.user
    - require:
      - pkg: iptables
      - service: S40network
      - service: S52batmand
      - service: S53backbone-fastd2
      - file: /etc/init.d/S41firewall
      - file: /etc/firewall.user
      - cmd: rc.d_S41firewall
      - file: /usr/local/bin/ddmesh-ipcalc.sh
      - file: /usr/local/bin/nvram
      - file: /etc/nvram.conf


{# IPv6 Firewall #}
/etc/init.d/S42firewall6:
  file.managed:
    - source: salt://iptables/etc/init.d/S42firewall6
    - user: root
    - group: root
    - mode: 755

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
      - pkg: iptables
      - service: S40network
      - file: /etc/init.d/S42firewall6
    - require:
      - pkg: iptables
      - service: S40network
      - service: S52batmand
      - service: S53backbone-fastd2
      - file: /etc/init.d/S42firewall6
      - cmd: rc.d_S42firewall6
      - file: /usr/local/bin/ddmesh-ipcalc.sh
      - file: /usr/local/bin/nvram
      - file: /etc/nvram.conf
