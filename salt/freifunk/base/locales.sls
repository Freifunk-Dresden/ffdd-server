{# Locale and Language Settings #}
locales:
  pkg.installed:
    - name: locales

en_US.UTF-8:
  locale.present

de_DE.UTF-8:
  locale.present

en_US.UTF-8_default:
  locale.system:
    - require:
      - locale: en_US.UTF-8
