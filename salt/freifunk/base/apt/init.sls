{# Package Management System #}
apt:
  pkg.installed:
    - refresh: True
    - names:
      - apt
      - ca-certificates
      - unattended-upgrades
{% if grains['os'] == 'Debian' %}
      - apt-transport-https
{% endif %}

{# sources.list #}
{% if grains['os'] == 'Debian' and grains['oscodename'] == 'bullseye' %}
/etc/apt/sources.list:
  file.managed:
    - contents: |
        ##### Debian Main Repos #####
        deb http://deb.debian.org/debian/ bullseye main contrib non-free
        deb-src http://deb.debian.org/debian/ bullseye main contrib non-free
        # stable-updates
        deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free
        deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free
        # security-updates
        deb http://security.debian.org/debian-security bullseye-security main contrib non-free
        deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free
        # backports
        deb http://ftp.debian.org/debian bullseye-backports main contrib non-free
    - user: root
    - group: root
    - mode: 644

{% elif grains['os'] == 'Debian' and grains['oscodename'] == 'bookworm' %}
/etc/apt/sources.list:
  file.managed:
    - contents: |
        ##### Debian Main Repos #####
        deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
        deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
        # stable-updates
        deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
        deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
        # security-updates
        deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
        deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
        # backports
        deb http://ftp.debian.org/debian bookworm-backports main contrib non-free non-free-firmware
    - user: root
    - group: root
    - mode: 644
{% endif %}

{# Configuration #}
/etc/apt/apt.conf.d/20auto-upgrades:
  file.managed:
    - source: salt://apt/etc/apt/apt.conf.d/20auto-upgrades
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apt

/etc/apt/apt.conf.d/50unattended-upgrades:
  file.managed:
    - source: salt://apt/etc/apt/apt.conf.d/50unattended-upgrades
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apt

{# automatic security upgrades #}
unattended-upgrades:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/apt/apt.conf.d/50unattended-upgrades
    - require:
      - pkg: apt
      - pkg: unattended-upgrades
      - file: /etc/apt/apt.conf.d/50unattended-upgrades

{# purge_old_kernels and update grub #}
/etc/cron.d/purge-old-kernels:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        23 5 * * *  root  /usr/bin/purge-old-kernels --keep 2 -qy ; update-grub2
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: install_pkg
      - pkg: cron
