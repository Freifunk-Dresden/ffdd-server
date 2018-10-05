bash:
  pkg.installed:
    - names:
      - bash
      - bash-completion

/etc/bash.bashrc:
  file.managed:
    - source: salt://bash/etc/bash.bashrc
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: bash
