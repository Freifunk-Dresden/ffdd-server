{# clear old obsolete files from old versions #}

remove_old_pkg:
  pkg.removed:
    - names:
      - vnstat
      - composer

clean_old_vnstat:
  file.absent:
    - name: /etc/vnstat.conf
    - name: /var/lib/vnstat
    - name: /var/lib/vnstat
    - name: /opt/vnstat-dashboard
    - name: /var/www_vnstat/
    - name: /etc/apache2/conf-available/vnstat.conf
    - name: /etc/apache2/conf-enabled/vnstat.conf


/root/freifunk/vserver-base:
  file.absent


/etc/apache2/sites-enabled/001-freifunk.conf:
  file.absent:
    - onlyif: test ! -L /etc/apache2/sites-enabled/001-freifunk.conf

/etc/apache2/sites-enabled/001-freifunk-ssl.conf:
  file.absent:
    - onlyif: test ! -L /etc/apache2/sites-enabled/001-freifunk-ssl.conf


/etc/apache2/conf-enabled/bind_stats_access.incl:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/bind_stats_access.incl

/etc/apache2/conf-enabled/bind_stats.conf:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/bind_stats.conf

/etc/apache2/conf-enabled/letsencrypt.conf:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/letsencrypt.conf

/etc/apache2/conf-enabled/monitorix_access.incl:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/monitorix_access.incl

/etc/apache2/conf-enabled/monitorix.conf:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/monitorix.conf

/etc/apache2/conf-enabled/ssl-params.conf:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/ssl-params.conf

/etc/apache2/conf-enabled/vnstat.conf:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/vnstat.conf

/etc/apache2/conf-enabled/vnstat_access.incl:
  file.absent:
    - onlyif: test ! -L /etc/apache2/conf-enabled/vnstat_access.incl


/etc/sysctl.d/global.conf:
  file.absent

/etc/cron.d/apt-update:
  file.absent

/etc/cron.d/freifunk-autoupdate:
  file.absent

/etc/cron.d/update-blacklist_fail2ban:
  file.absent

/etc/php5:
  file.absent

/etc/fastd/cmd2.sh:
  file.absent

/etc/init.d/S52bmx6:
  file.absent

/etc/init.d/S53backbone:
  file.absent

/etc/init.d/S53backbone-fastd:
  file.absent

/etc/init.d/S90nuttcp:
  file.absent

/etc/nvram.conf:
  file.absent


/usr/bin/nvram:
  file.absent

/usr/bin/bmxd:
  file.absent

/usr/bin/conntrack.sh:
  file.absent

/usr/bin/ddmesh-ipcalc.sh:
  file.absent

/usr/bin/ddmesh-nuttcp.sh:
  file.absent

/usr/bin/freifunk-gateway-check.sh:
  file.absent

/usr/bin/freifunk-gateway-info.sh:
  file.absent

/usr/bin/freifunk-gateway-status.sh:
  file.absent

/usr/bin/freifunk-register-local-node.sh:
  file.absent

/usr/bin/freifunk-services.sh:
  file.absent

/usr/local/bin/freifunk-autoupdate:
  file.absent

/usr/local/bin/f2b-unban.sh:
  file.absent

/usr/lib/bmxd:
  file.absent

/usr/local/bin/bmxd:
  file.absent

/usr/local/bin/freifunk-nvram_autosetup.sh:
  file.absent

/usr/local/src/bmxd:
  file.absent

/usr/local/src/bmxd_revision:
  file.absent

/usr/local/src/freifunk-get_bmxd_revision.sh:
  file.absent


/var/statistic:
  file.absent

/var/www_freifunk/robots.txt:
  file.absent:
    - onlyif: grep -q '# Alle Robots' /var/www_freifunk/robots.txt
