{# FFDD Salt-Minion (masterless) #}
{% from 'config.jinja' import devmode, ctime, install_dir %}

{# Package #}
{# repos needs also a check in init_server.sh #}
salt_keyring:
  cmd.run:
    - name: curl -L https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public -o /etc/apt/keyrings/salt-archive-keyring.pgp
    - creates: /etc/apt/keyrings/salt-archive-keyring.pgp
    - require:
      - file: /etc/apt/keyrings

/etc/apt/preferences.d/salt-pin-1001:
  file.managed:
    - contents: |
        Package: salt-*
        Pin: version 3007.*
        Pin-Priority: 1001'
    - user: root
    - user: root
    - mode: 644

/etc/apt/sources.list.d/salt.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Salt Project
        Description: Salt has many possible uses, including configuration management.
          Built on Python, Salt is an event-driven automation tool and framework to deploy,
          configure, and manage complex IT systems. Use Salt to automate common
          infrastructure administration tasks and ensure that all the components of your
          infrastructure are operating in a consistent desired state.
          - Website: https://saltproject.io
          - Public key: https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
        Enabled: yes
        Types: deb
        URIs: https://packages.broadcom.com/artifactory/saltproject-deb
        Signed-By: /etc/apt/keyrings/salt-archive-keyring.pgp
        Suites: stable
        Components: main

salt-minion:
  pkg.installed:
    - refresh: True
    - name: salt-minion
    - require:
      - salt_keyring
      - file: /etc/apt/sources.list.d/salt.sources
      - file: /etc/apt/preferences.d/salt-pin-1001
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
