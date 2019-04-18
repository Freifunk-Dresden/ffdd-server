{# vim text editor #}
vim:
  pkg.installed:
    - refresh: True
    - name: vim

{# Configuration #}
/etc/vimrc:
  file.managed:
    - source:
      - salt://vim/etc/vim/vimrc
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: vim

/etc/vimrc.tiny:
  file.managed:
    - source:
      - salt://vim/etc/vim/vimrc.tiny
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: vim
