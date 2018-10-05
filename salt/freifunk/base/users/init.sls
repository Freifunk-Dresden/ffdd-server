# ensure user "freifunk" is present
freifunk:
  user.present:
    - fullname: Freifunk
    - shell: /bin/bash
    - createhome: false
    - empty_password: false
    - system: true
    - groups:
      - freifunk
      - www-data
  group.present:
    - system: true
    - members:
      - freifunk

# ensure user "syslog" is present (required in rsyslog)
syslog:
  user.present:
    - shell: /bin/bash
    - createhome: false
    - empty_password: false
    - system: true
    - groups:
      - syslog
      - adm
  group.present:
    - system: true
    - members:
      - syslog
