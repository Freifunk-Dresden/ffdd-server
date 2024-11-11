{# Secure Shell #}
{% from 'config.jinja' import freifunk_version, servername %}

ssh:
  pkg.installed:
    - refresh: True
    - name: openssh-server
    - name: mosh
  service.running:
    - enable: True
    - restart: True
    - watch:
      - file: /etc/ssh/sshd_config
    - require:
      - file: /etc/ssh/sshd_config

{# SSH Installation Check #}
ssh_check:
  cmd.run:
    - name: logger -t "rc.local" "restart sshd" ; mkdir -p /var/run/sshd ; /usr/sbin/service ssh restart
    - unless: "[ -d /var/run/sshd ]"

{# Configuration #}
/etc/ssh/sshd_config:
  file.managed:
    - source: salt://ssh/etc/ssh/sshd_config.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: ssh

{# SSH-Login Information #}
/etc/issue.net:
  file.managed:
    - contents: |
        -----------------------------------------------------------------
         Freifunk {{ servername }}

         Version: {{ freifunk_version }}
        -----------------------------------------------------------------
    - user: root
    - group: root
    - mode: 644
