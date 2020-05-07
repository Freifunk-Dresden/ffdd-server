{# uci - config management helper #}
uci_repo:
  git.latest:
    - name: https://git.openwrt.org/project/uci.git
    - rev: master
    - target: /opt/uci
    - update_head: True
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git

libubox_repo:
  git.latest:
    - name: https://github.com/xfguo/libubox.git
    - rev: master
    - target: /opt/libubox
    - update_head: True
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git


libubox_make:
  cmd.run:
    - name: |
        cd /opt/libubox
        mkdir build ; cd build ; cmake .. ; make ubox
        mkdir -p /usr/local/include/libubox
        cp ../*.h /usr/local/include/libubox
        cp libubox.so /usr/local/lib
        ldconfig
    - require:
      - pkg: devel
      - libubox_repo
    - onchanges:
      - pkg: devel
      - libubox_repo

uci_make:
  cmd.run:
    - name: |
        cd /opt/uci
        cmake [-D BUILD_LUA:BOOL=OFF] . ; make uci cli
        mkdir -p /usr/local/include/uci
        cp uci.h uci_config.h /usr/local/include/uci
        cp uci_blob.h ucimap.h /usr/local/include/uci
        cp libuci.so /usr/local/lib
        cp uci /usr/local/bin
        ldconfig
    - require:
      - pkg: devel
      - uci_repo
      - libubox_repo
    - onchanges:
      - pkg: devel
      - uci_repo
      - libubox_repo

{# config #}
/etc/uci.conf:
  file.managed:
    - source: salt://uci/etc/uci.conf
    - user: root
    - group: root
    - mode: 644
    - replace: false

/etc/config:
  file.symlink:
    - makedirs: true
    - target: /etc/uci.conf
    - user: root
    - group: root

{# sample config (default) #}
/etc/uci_sample.conf:
  file.managed:
    - source: salt://uci/etc/uci.conf
    - user: root
    - group: root
    - mode: 644
