# Secure Shell
ssh:
  pkg.installed:
    - name: openssh-server
  service.running:
    - enable: True
    - restart: True
    - watch:
      - file: /etc/ssh/sshd_config
    - require:
      - file: /etc/ssh/sshd_config

# SSH Installation Check
ssh_check:
  cmd.run:
    - name: mkdir -p /var/run/sshd ; /etc/init.d/ssh restart
    - unless: "[ -d /var/run/sshd ]"

# Configuration
/etc/ssh/sshd_config:
  file.managed:
    - source:
      - salt://ssh/etc/ssh/sshd_config
    - user: root
    - group: root
    - mode: 644
    #- replace: false
    - watch_in:
      - service: ssh

# SSH-Login Information
/etc/issue.net:
  file.managed:
    - source:
      - salt://ssh/etc/issue.net.tmpl
    - template: jinja
    - user: root
    - group: root
    - mode: 644
