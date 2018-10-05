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
      - libcurl3
      #- gnupg-curl

devel_fastd:
  pkg.installed:
    - names:
      - libjson-c-dev
      - pkg-config
      - cmake
