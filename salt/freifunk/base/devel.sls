{# Packages for compilling - bmxd / fastd #}
devel:
  pkg.installed:
    - refresh: True
    - names:
      - build-essential
      - cmake
      - pkg-config
      - bison
      - zlibc
      - zlib1g-dev
      - liblzo2-dev
      - libssl-dev
      - libnacl-dev
      - libjson-c-dev

{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'bionic' %}
      - libcurl4

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
      - libcurl4
      {# pkg to build fastd2 #}
      - libmnl-dev

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'buster' %}
      - libcurl4

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'bullseye' %}
      - libcurl4

{# workaround for fastd libjson-c-dev #}
/usr/lib/x86_64-linux-gnu/libjson-c.so.3:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libjson-c.so.5
    - force: true
    - require:
      - pkg: libjson-c-dev

{% else %}
      - libcurl3

{% endif %}
