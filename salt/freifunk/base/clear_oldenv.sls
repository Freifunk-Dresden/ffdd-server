{# cleanup old server version #}

/root/freifunk/vserver-base:
  file.absent


/etc/apache2/conf-enabled/vnstat_access.incl:
  file.absent

/etc/bind/openvpn.forwarder:
  file.absent

/etc/sysctl.d/global.conf:
  file.absent

/etc/cron.d/freifunk-autoupdate:
  file.absent

/etc/php5:
  file.absent

/etc/fastd/cmd.sh:
  file.absent

/etc/init.d/S52bmx6:
  file.absent

/etc/init.d/S53backbone:
  file.absent

/etc/init.d/S53backbone-fastd:
  file.absent

/etc/init.d/S90nuttcp:
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

/usr/lib/bmxd:
  file.absent


/usr/share/xt_geoip:
  file.absent

/usr/share/doc/libgeoip1/examples/geolitecountryv4.sh:
  file.absent

/usr/share/doc/libgeoip1/examples/geolitecountryv6.sh:
  file.absent


/var/statistic:
  file.absent

/var/www_freifunk/04-monitorix:
  file.absent

/var/www_freifunk/05-status:
  file.absent

/var/www_freifunk/06-nodes:
  file.absent

/var/www_freifunk/06-monitorix:
  file.absent

/var/www_freifunk/functions.sh:
  file.absent

/var/www_freifunk/infopage:
  file.absent

/var/www_freifunk/images/flags:
  file.absent

/var/www_freifunk/js:
  file.absent

/var/www_freifunk/services.cgi:
  file.absent

/var/www_freifunk/sysinfo-json.cgi:
  file.absent:
    - onlyif:
      - test ! -L /var/www_freifunk/sysinfo-json.cgi

{# remove old packages #}
remove_old_pkg:
  pkg.removed:
    - names:
      - libtext-csv-xs-perl
      - geoip-database
      - xtables-addons-dkms
