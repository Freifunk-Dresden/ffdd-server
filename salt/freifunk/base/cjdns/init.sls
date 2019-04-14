{# cjdns #}

cjdns_clone_repo:
  git.latest:
    - name: https://github.com/cjdelisle/cjdns.git
    - target: /usr/local/src/cjdns/
    - require:
      - pkg: devel

{# Compiling #}
{# needs devel.sls (compiling tools) #}
cjdns_build_repo:
  cmd.run:
    - name: |
        ./do
        test ! -f /usr/bin/cjdroute && ln -s /usr/local/src/cjdns/cjdroute /usr/bin/ || true
        test ! -f /etc/cjdroute.conf && ./cjdroute --genconf > /etc/cjdroute.conf || true
        test ! -f /etc/systemd/system/cjdns.service && cp contrib/systemd/cjdns.service /etc/systemd/system/ || true
    - cwd: /usr/local/src/cjdns/
    - onchanges:
      - git: cjdns_clone_repo

{#
# Service
cjdns:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/cjdroute.conf
      - service: S41firewall
    - require:
      - file: /etc/cjdroute.conf
      - service: S40network
      - service: S41firewall
#}
