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

{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
      - libcurl4
      {# dep. to build fastd2 #}
      - libmnl-dev

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'jammy' %}
      - libcurl4
      {# dep. to build fastd2 #}
      - libmnl-dev

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'bullseye' %}
      - libcurl4
      {# dep. to build fastd2 #}
      - libmnl-dev

{# workaround for fastd libjson-c-dev #}
/usr/lib/x86_64-linux-gnu/libjson-c.so.3:
  file.symlink:
    - target: /usr/lib/x86_64-linux-gnu/libjson-c.so.5
    - force: true
    - require:
      - pkg: libjson-c-dev

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'bookworm' %}
      - libcurl4
      {# dep. to build fastd2 #}
      - libmnl-dev

{% else %}
      - libcurl3

{% endif %}
