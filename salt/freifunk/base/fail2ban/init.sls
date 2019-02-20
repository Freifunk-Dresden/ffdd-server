# Fail2ban (intrusion prevention system)
fail2ban:
  pkg.installed:
    - name: fail2ban
  service:
    - running
    - name: fail2ban
    - enable: True
    - restart: True
    - watch:
      - pkg: fail2ban
      - service: S41firewall
      - file: /etc/fail2ban/fail2ban.conf
      - file: /etc/fail2ban/jail.d/freifunk.conf
    - require:
      - pkg: fail2ban
      - service: S40network
      - service: S41firewall

# Fail2ban Installation Check
fail2ban_check:
  cmd.run:
    - name: mkdir -p /var/run/fail2ban ; /etc/init.d/fail2ban restart
    - unless: "[ -d /var/run/fail2ban ]"

# Configuration
/etc/fail2ban/fail2ban.conf:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/fail2ban.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban

/etc/fail2ban/jail.d/freifunk.conf:
  file.managed:
    - source: salt://fail2ban/etc/fail2ban/jail.d/freifunk.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: fail2ban
