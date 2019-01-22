# provides /etc/resolv.conf

# remove conflicting packages
remove_resolvconf:
  pkg.removed:
    - names:
      - resolvconf

/etc/resolv.conf:
  file.managed:
    - contents: |
        search ffdd
        nameserver 10.200.0.4
        nameserver 127.0.0.1
    - user: root
    - group: root
    - mode: 755
    - attrs: i
