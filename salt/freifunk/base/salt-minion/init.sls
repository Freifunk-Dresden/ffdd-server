salt-minion:
  pkg.installed:
    - name: salt-minion
  service:
    - dead
    - enable: False

/etc/salt/minion.d/freifunk-masterless.conf:
  file.exists
