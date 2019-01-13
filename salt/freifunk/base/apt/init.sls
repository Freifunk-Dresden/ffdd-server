# Package Management System
apt:
  pkg.installed:
    - names:
      - apt
      - apt-transport-https
      - ca-certificates
      - unattended-upgrades

# Configuration
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

# automatic (crontab) - apt update
/etc/cron.d/apt-update:
  file.managed:
    - source: salt://apt/etc/cron.d/apt-update
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: apt
      - pkg: cron

# automatic security upgrades
unattended-upgrades:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/apt/apt.conf.d/50unattended-upgrades
    - require:
      - pkg: apt
      - pkg: cron
