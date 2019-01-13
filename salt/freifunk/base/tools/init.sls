# merging tool idiff
/usr/local/bin/idiff:
  file.managed:
    - source: salt://tools/usr/local/bin/idiff
    - user: root
    - group: root
    - mode: 755

# helper symlinks
/bin/sh:
  file.symlink:
    - target: /bin/bash
    - force: True

/usr/bin/editor:
  file.symlink:
    - target: /usr/bin/vi
    - force: True
