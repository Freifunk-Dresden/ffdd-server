# network performance measurement
iperf3:
  pkg.installed:
    - name: iperf3


# Service Configuration
/etc/init.d/S90iperf3:
  file.managed:
    - source: salt://iperf3/etc/init.d/S90iperf3
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: iperf3

rc.d_S90iperf3:
  cmd.run:
    - name: /usr/sbin/update-rc.d S90iperf3 defaults ; systemctl daemon-reload
    - require:
      - file: /etc/init.d/S90iperf3
    - onchanges:
      - file: /etc/init.d/S90iperf3

S90iperf3:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/init.d/S90iperf3
    - require:
      - pkg: iperf3
