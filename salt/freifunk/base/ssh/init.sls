ssh:
  pkg.installed:
    - name: 'openssh-server'
  service.running:
    - enable: True
    - restart: True
    - watch:
      - file: /etc/ssh/sshd_config
    - require:
      - file: /etc/ssh/sshd_config

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

/etc/issue.net:
  file.managed:
    - source:
      - salt://ssh/etc/issue.net
    - user: root
    - group: root
    - mode: 644
    - replace: false
