{# remove conflicting packages #}
remove_pkg:
  pkg.removed:
    - names:
      - iptables-persistent
      - bluez
      - unbound
      - pdnsd
      - pdns-server
