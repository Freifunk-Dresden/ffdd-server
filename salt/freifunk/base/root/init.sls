# default root env
/root/.bashrc:
  file.managed:
    - source: salt://root/.bashrc
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - pkg: bash
