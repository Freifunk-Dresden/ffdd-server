{# merging tool idiff #}
/usr/local/bin/idiff:
  file.managed:
    - source: salt://tools/usr/local/bin/idiff
    - user: root
    - group: root
    - mode: 755

{# helper symlinks #}
/bin/sh:
  file.symlink:
    - target: /bin/bash
    - force: True

{# 0x0 pastebin util #}
pb_repo:
  git.latest:
    - name: https://git.envs.net/envs/pb.git
    - rev: master
    - target: /opt/pb
    - update_head: True
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git

pb_make:
  cmd.run:
    - name: "cd /opt/pb ; make install"
    - require:
      - pb_repo
    - onchanges:
      - pb_repo
