{# Packages for compilling - bmxd / fastd #}
devel:
  pkg.installed:
    - refresh: True
    - names:
      - build-essential
      - nodejs
      - zlib1g-dev
      - liblzo2-dev
      - libssl-dev
      - libnacl-dev
      - libjson-c-dev
      - bison
      - flex
      - zlibc
      - pkg-config
      - cmake

{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'bionic' %}
      - libcurl4

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'buster' %}
      - libcurl4

{% else %}
      - libcurl3

{% endif %}
