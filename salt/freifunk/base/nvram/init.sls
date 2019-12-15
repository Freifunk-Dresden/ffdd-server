{# config management helper #}
/usr/local/bin/nvram:
  file.managed:
    - source: salt://nvram/usr/local/bin/nvram
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /etc/nvram.conf

{# default config #}
/etc/nvram.conf:
  file.managed:
    - source: salt://nvram/etc/nvram.conf
    - user: root
    - group: root
    - mode: 644
    - replace: false
