{# FFDD Salt-Minion (masterless) #}
{% from 'config.jinja' import ctime, install_dir %}

{# Package #}
{# repos needs also a check in init_server.sh #}
salt-minion:
  {% if grains['os'] == 'Debian' and grains['oscodename'] == 'stretch' %}
  pkgrepo.managed:
    - humanname: SaltStack
    - name: deb http://repo.saltstack.com/apt/debian/9/amd64/2018.3 stretch main
    - dist: stretch
    - file: /etc/apt/sources.list.d/saltstack.list
    - require_in:
      - pkg: salt-minion
    - gpgcheck: 1
    - key_url: https://repo.saltstack.com/apt/debian/9/amd64/2018.3/SALTSTACK-GPG-KEY.pub

  {% elif grains['os'] == 'Ubuntu' and grains['oscodename'] == 'xenial' %}
  pkgrepo.managed:
    - humanname: SaltStack
    - name: deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3 xenial main
    - dist: xenial
    - file: /etc/apt/sources.list.d/saltstack.list
    - require_in:
      - pkg: salt-minion
    - gpgcheck: 1
    - key_url: https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3/SALTSTACK-GPG-KEY.pub

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
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        # Execute a local salt-call every hour
        {{ ctime }} */1 * * *  root  /usr/bin/salt-call state.highstate --local
        # Execute after boot
        @reboot       root  /usr/bin/salt-call state.highstate --local
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
