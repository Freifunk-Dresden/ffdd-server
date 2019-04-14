{# sysctl #}
reload-sysctl:
  cmd.wait:
    - watch: []
    - name: /sbin/sysctl --system

{# Default Configuration #}
/etc/sysctl.conf:
  file.managed:
    - source: salt://sysctl/etc/sysctl.conf
    - watch_in:
      - cmd: reload-sysctl

{# ffdd modifications #}
/etc/sysctl.d/global.conf:
  file.managed:
    - source: salt://sysctl/etc/sysctl.d/global.conf
    - watch_in:
      - cmd: reload-sysctl
