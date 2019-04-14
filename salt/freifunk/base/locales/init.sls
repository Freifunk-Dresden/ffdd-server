{# Locale and Language Settings #}
locales:
  pkg.installed:
    - name: locales

/etc/locale.gen:
  file.managed:
    - source: salt://locales/etc/locale.gen
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: locales

locale-gen:
  cmd.wait:
    - require:
      - file: /etc/locale.gen
    - watch:
      - file: /etc/locale.gen

en_US.UTF-8:
  locale.system:
    - require:
      - file: /etc/locale.gen
