{# Package Management System #}
apt:
  pkg.installed:
    - refresh: True
    - names:
      - apt
      - apt-transport-https
      - ca-certificates
      - unattended-upgrades

{# sources.list #}
{% if grains['os'] == 'Debian' %}
/etc/apt/sources.list:
  file.managed:
    - contents: |
        ##### Debian Main Repos #####
        deb http://deb.debian.org/debian/ stretch main contrib non-free
        deb-src http://deb.debian.org/debian/ stretch main contrib non-free
        # stable-updates
        deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
        deb-src http://deb.debian.org/debian/ stretch-updates main contrib non-free
        # security-updates
        deb http://deb.debian.org/debian-security stretch/updates main
        deb-src http://deb.debian.org/debian-security stretch/updates main
    - user: root
    - group: root
    - mode: 600
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
      - pkg: cron
      - pkg: unattended-upgrades
      - file: /etc/apt/apt.conf.d/50unattended-upgrades

{# cron #}
/etc/cron.d/apt-update:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        3 */6 * * *  root  su -c "apt-get update > /dev/null 2>&1"
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: apt
      - pkg: cron

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
