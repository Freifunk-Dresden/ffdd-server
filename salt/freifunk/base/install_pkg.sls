{# Packages without needed Configuration #}
install_pkg:
  pkg.installed:
    - refresh: True
    - names:
      - dbus
      - lsb-release
      - dmidecode
      - irqbalance
      - cpufrequtils

      - htop
      - screen
      - tmux
      - byobu
      - rsync
      - most
      - nano
      - vim
      - less
      - at
      - jq

      - gnupg
      - wget
      - curl
      - git

      - gawk
      - tar
      - bzip2
      - zip
      - unzip
      - gzip

      - net-tools
      - grepcidr
      - ethtool
      - psmisc
      - bridge-utils
      - tcpdump
      - lftp
      - iputils-ping
      - dnsutils
      - whois
      - ltrace
      - strace
      - mtr-tiny
      - bwm-ng


{% if grains['os'] == 'Debian' %}
      - firmware-linux
      - python-apt-common
      - iptraf-ng
{% elif grains['os'] == 'Ubuntu' %}
      - linux-firmware
      - software-properties-common
{% endif %}


{% if grains['os'] == 'Debian' and grains['oscodename'] == 'bullseye' %}
      - python3-pip
      - python3-yaml
      - python3-msgpack
      - python3-distro
      - python3-jinja2
      - python3-tornado
      - python3-looseversion
      - python3-packaging

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
      - python-apt
      - python-pycurl
      - iptraf

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'jammy' %}
      - python3-apt
      - python3-pycurl
      - iptraf-ng

{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'noble' %}
      - python3-apt
      - python3-pycurl
      - iptraf-ng

{% endif %}
