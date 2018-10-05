#
# sysctl
#
reload-sysctl:
  cmd.wait:
    - watch: []
    - name: /sbin/sysctl --system

/etc/sysctl.conf:
  file.managed:
    - source: salt://sysctl/etc/sysctl.conf
    - watch_in:
      - cmd: reload-sysctl

/etc/sysctl.d/global.conf:
  file.managed:
    - source: salt://sysctl/etc/sysctl.d/global.conf
    - watch_in:
      - cmd: reload-sysctl
