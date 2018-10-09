# cleanup old server version

/root/freifunk/vserver-base:
  file.absent


/etc/php5:
  file.absent

/etc/fastd/cmd.sh:
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


/usr/lib/bmxd:
  file.absent


/usr/share/xt_geoip/xt_geoip_build.sh:
  file.absent

/usr/share/doc/libgeoip1/examples/geolitecountryv4.sh:
  file.absent

/usr/share/doc/libgeoip1/examples/geolitecountryv6.sh:
  file.absent


/var/statistic:
  file.absent
