# PHP and Apache2 Extension
{% set php_version = salt['cmd.shell']("apt-cache search ^php$ | grep metapackage | awk '{print $1}' | head -1") %}

php:
  pkg.installed:
    - refresh: True
    - name: php

{% if php_version != '' %}
apache2_mod_php:
  pkg.installed:
    - refresh: True
    - name: "libapache2-mod-{{ php_version }}"
  apache_module.enabled:
    - name: "{{ php_version }}"
    - require:
      - pkg: apache2
      - pkg: php
{% endif %}


{% if salt['file.directory_exists' ]('/etc/apache2/mods-available/') %}
{%- set old_php_version = salt['cmd.shell']("cd /etc/apache2/mods-available/ ; find . -name 'php*.load' ! -name " ~ php_version ~ ".load | sed -e 's/.\///g' -e 's/.load//g'") -%}

{% if old_php_version != '' %}
apache2_mod_php_disable_old:
  cmd.run:
    - name: "a2dismod {{ old_php_version }} ; systemctl restart apache2 ; apt purge -y {{ old_php_version }}"
    - require:
      - apache2
      - php
{% endif %}

{% endif %}
