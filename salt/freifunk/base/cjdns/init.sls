# cjdns

cjdns_clone_repo:
  git.latest:
    - name: https://github.com/cjdelisle/cjdns.git
    - target: /usr/local/src/cjdns/
    - onlyif: test ! -d /usr/local/src/cjdns
    - require:
      - pkg: devel

cjdns_update_repo:
  cmd.run:
    - name: cd /usr/local/src/cjdns/ && git pull
    - onlyif: test -d /usr/local/src/cjdns
    - require:
      - pkg: devel
    - onfail:
       - git: cjdns_clone_repo


# Compiling
# needs devel.sls (compiling tools)
cjdns_src:
  file.exist

cjdns_build_repo:
  cmd.run:
    - name: |
        ./do
        test ! -f /usr/bin/cjdroute && ln -s /usr/local/src/cjdns/cjdroute /usr/bin/
        test ! -f /etc/cjdroute.conf && (umask 077 && ./cjdroute --genconf > /etc/cjdroute.conf)
        test ! -f /etc/systemd/system/cjdns.service && cp contrib/systemd/cjdns.service /etc/systemd/system/
    - cwd: /usr/local/src/cjdns/
    - onchanges:
      - file: /usr/local/src/cjdns/
    - require:
      - git: cjdns_update_repo


# Service
cjdns:
  service:
    - running
    - enable: False
    - restart: False
    - watch:
      - file: /etc/cjdroute.conf
      - service: S41firewall
    - require:
      - service: S40network
      - service: S41firewall
