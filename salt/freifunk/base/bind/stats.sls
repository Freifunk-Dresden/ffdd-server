{# bind stats #}
/etc/apache2/conf-available/bind_stats_access.incl:
  file.managed:
    - source: salt://bind/etc/apache2/conf-available/bind_stats_access.incl
    - user: root
    - group: root
    - mode: 644
    - replace: false
    - require:
      - pkg: apache2

/etc/apache2/conf-available/bind_stats.conf:
  file.managed:
    - source: salt://bind/etc/apache2/conf-available/bind_stats.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2
      - file: /etc/apache2/conf-available/bind_stats_access.incl

apache2_conf_enable_bind_stats:
  apache_conf.enabled:
    - name: bind_stats
    - require:
      - pkg: apache2
      - file: /etc/apache2/conf-available/bind_stats.conf


/var/www_bind/named.stats:
  file.symlink:
    - makedirs: true
    - target: /var/cache/bind/named.stats
    - user: www-data
    - group: www-data

bind_stats:
  cmd.run:
    - name: /usr/sbin/rndc stats
    - unless: "[ -f /var/cache/bind/named.stats ]"
    - require:
      - bind


/etc/cron.d/bind_stats:
  file.managed:
    - contents: |
        ### This file managed by Salt, do not edit by hand! ###
        SHELL=/bin/sh
        PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
        MAILTO=""
        #
        # renew bind-stats every hour
        0 * * * *  root  truncate -s 0 /var/cache/bind/named.stats ; rndc stats
    - user: root
    - group: root
    - mode: 600
    - require:
      - pkg: cron
      - pkg: bind
