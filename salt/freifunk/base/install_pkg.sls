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
      - unzip
      - gzip

      # purge old kernels
      - byobu

      - ethtool
      - psmisc
      - bridge-utils
      - tcpdump
      - netcat
      - lftp
      - inetutils-ping
      - dnsutils

      # network traffic measurements
      - bwm-ng
      - iptraf

      - python-apt
      - jq
      - grepcidr

{% if grains['os'] == 'Ubuntu' %}
      - software-properties-common
      - python-pycurl
{% endif %}
