#!/bin/sh
REV="T_RELEASE_latest"
REPO_URL='https://github.com/Freifunk-Dresden/ffdd-server'
INSTALL_DIR='/srv/ffdd-server'

if [ "$(id -u)" -ne 0 ]; then printf 'Please run as root!\n'; exit 1 ; fi

nvram set branch "$REV"

[ -n "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
git clone "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR" && git checkout "$REV"

salt-call state.highstate --local -l error

printf 'Please check the changelog for the case there are config deprecations, special update steps.\n'
printf '%s/blob/master/CHANGELOG.md\n' "$REPO_URL"

exit 0
