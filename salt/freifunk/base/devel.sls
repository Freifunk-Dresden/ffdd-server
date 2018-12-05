# Packages for compilling - bmxd / fastd
devel:
  pkg.installed:
    - names:
      - build-essential
      - zlib1g-dev
      - liblzo2-dev
      - libssl-dev
      - bison
      - flex
      - zlibc
{% if grains['os'] == 'Ubuntu' and grains['osrelease'] == '18.04' %}
      - libcurl4
{% else %}
      - libcurl3
{% endif %}


devel_fastd:
  pkg.installed:
    - names:
      - libjson-c-dev
      - pkg-config
      - cmake
