{# FFDD Salt-Minion (masterless) #}
{% from 'config.jinja' import devmode, ctime, install_dir %}

{# Package #}
{# repos needs also a check in init_server.sh #}
salt-minion:
  {% if grains['os'] == 'Debian' and grains['oscodename'] == 'bookworm' %}
  pkgrepo.managed:
    - humanname: SaltStack
    - name: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/12/amd64/latest bookworm main
    - dist: bookworm
    - file: /etc/apt/sources.list.d/saltstack.list
    - require_in:
      - pkg: salt-minion
    - gpgcheck: 1
    - key_url: https://repo.saltproject.io/salt/py3/debian/12/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg

  {% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
  pkgrepo.managed:
    - humanname: SaltStack
    - name: deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main
    - dist: focal
    - file: /etc/apt/sources.list.d/saltstack.list
    - require_in:
      - pkg: salt-minion
    - gpgcheck: 1
    - key_url: https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg

  {% else %}
  file.absent:
    - name: /etc/apt/sources.list.d/saltstack.list

  {% endif %}

  pkg.installed:
    - refresh: True
    - name: salt-minion
  service:
    - dead
    - enable: False

{# Configuration #}
/etc/salt/minion.d/freifunk-masterless.conf:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        #
        # ffdd-server - salt-minion masterless configuration file
        #
        master_type: disable
        file_client: local
        file_roots:
          base:
            - {{ install_dir }}/salt/freifunk/base
    - user: root
    - group: root
    - mode: 644

{# cron #}
/etc/cron.d/freifunk-masterless:
  {% if devmode == '0' or devmode == '' %}
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        # Execute after boot
        @reboot       root  nice -n19 /usr/bin/salt-call state.highstate --local
        # Execute a regular salt-call
        {{ ctime }} */1 * * *  root  nice -n19 /usr/bin/salt-call state.highstate --local
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron

  {% else %}
  file.absent:
    - name: /etc/cron.d/freifunk-masterless

  {% endif %}
