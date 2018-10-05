#!/usr/bin/env bash
# (Salt managed)
#
# remove geoip folder and salt download & build a new state

rm -f /usr/share/xt_geoip/GeoIPCountryWhois.csv
rm -rf /usr/share/xt_geoip/BE
rm -rf /usr/share/xt_geoip/LE

salt-call state.highstate --local 2>&1 > /dev/null

exit 0
