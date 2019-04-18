{# System and Service Manager #}
systemd:
  pkg.installed:
    - refresh: True
    - name: systemd
