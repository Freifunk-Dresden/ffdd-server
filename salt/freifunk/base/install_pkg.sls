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
      - rsync
      - most
      - nano
      - vim
      - less
      - at

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
      {# purge old kernels #}
      - byobu

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

      - jq

{% if grains['os'] == 'Debian' and grains['oscodename'] == 'bullseye' %}
      - python-apt-common
      - iptraf-ng
{% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'jammy' %}
      - python3-apt
      - python3-pycurl
      - iptraf-ng
{% else %}
      - python-apt
      - iptraf
{% endif %}


{% if grains['os'] == 'Debian' %}
      - firmware-linux
{% elif grains['os'] == 'Ubuntu' %}
      - linux-firmware
      - software-properties-common
{% endif %}


{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
      - python-pycurl
{% endif %}
