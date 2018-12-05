# Packages without needed Configuration
install_pkg:
  pkg.installed:
    - names:
      - lsb-release

      - zsh
      - zsh-syntax-highlighting

      - htop
      - screen
      - tmux
      - rsync
      - most
      - nano
      - vim
      - less

      - gnupg
      - wget
      - curl
      - git
      - links

      # misc
      - mlocate
      - gawk
      - zip
      - gzip

      # purge old kernels
      - byobu

      - ethtool
      - psmisc
      - bridge-utils
      - tcpdump
      - netcat
      - lftp
      - fping
      - dnsutils

      # network traffic measurements
      - bwm-ng
      - iptraf
      - vnstat

      - python-apt
      - jq

{% if grains['os'] == 'Ubuntu' %}
      - software-properties-common
      # - python-software-properties
      - python-pycurl
{% endif %}
