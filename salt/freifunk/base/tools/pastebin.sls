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
      - pkg: devel
      - pb_repo
    - onchanges:
      - pkg: devel
      - pb_repo
