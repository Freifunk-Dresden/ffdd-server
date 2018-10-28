#!/usr/bin/env bash
### This file managed by Salt, do not edit by hand! ###
#
# remove geoip folder and salt download & build a new state

rm -f /usr/share/xt_geoip/GeoIPCountryWhois.csv
rm -rf /usr/share/xt_geoip/BE
rm -rf /usr/share/xt_geoip/LE

salt-call state.highstate --local >/dev/null 2>&1

exit 0
