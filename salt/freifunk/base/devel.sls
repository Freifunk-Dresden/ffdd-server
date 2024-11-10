{# Packages for compilling - bmxd / fastd #}
devel:
  pkg.installed:
    - refresh: True
    - names:
      - build-essential
      - cmake
      - pkg-config
      - bison
      - zlib1g-dev
      - liblzo2-dev
      - libssl-dev
      - libnacl-dev
      - libjson-c-dev
      {# dep. to build fastd2 #}
      - libmnl-dev

{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'noble' %}
      - libcurl4t64
{% else %}
      - libcurl4
{% endif %}

{% if grains['os'] == 'Debian' and grains['oscodename'] == 'bullseye' %}
{# workaround for fastd libjson-c-dev #}
/usr/lib/x86_64-linux-gnu/libjson-c.so.3:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libjson-c.so.5
    - force: true
    - require:
      - pkg: libjson-c-dev
{% endif %}
