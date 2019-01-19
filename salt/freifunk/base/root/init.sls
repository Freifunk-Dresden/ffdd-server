# default root env
/root/.bashrc:
  file.managed:
    - source: salt://root/.bashrc
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bash

# define aliases
/root/.bash_aliases:
  file.managed:
    - source: salt://root/.bash_aliases
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - pkg: bash
