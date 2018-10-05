salt-minion:
  pkg:
    - installed
  service:
    - dead
    - enable: False

/etc/salt/minion.d/freifunk-masterless.conf:
  file.exists
