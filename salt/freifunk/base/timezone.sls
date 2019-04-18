timezone:
  pkg.installed:
    - refresh: True
    - name: tzdata

  timezone.system:
    - name: Europe/Berlin
    - utc: True
