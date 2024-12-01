#!/usr/bin/env sh
### This file managed by Salt, do not edit by hand! ###
#
# Freifunk - Manuell Server Update
#

REPO_URL='https://github.com/Freifunk-Dresden/ffdd-server'
REV='T_RELEASE_latest'
INSTALL_DIR='/srv/ffdd-server'


CUSTOM_REPO_URL="$(uci -qX get ffdd.sys.freifunk_repo)"
[ -n "$CUSTOM_REPO_URL" ] && [ "$CUSTOM_REPO_URL" != "$REPO_URL" ] && REPO_URL="$CUSTOM_REPO_URL"

CUSTOM_REV="$(uci -qX get ffdd.sys.branch)"
[ -n "$CUSTOM_REV" ] && [ "$CUSTOM_REV" != "$REV" ] && REV="$CUSTOM_REV"

CUSTOM_INSTALL_DIR="$(uci -qX get ffdd.sys.install_dir)"
[ -n "$CUSTOM_INSTALL_DIR" ] && [ "$CUSTOM_INSTALL_DIR" != "$INSTALL_DIR" ] && INSTALL_DIR="$CUSTOM_INSTALL_DIR"


if [ "$(id -u)" -ne 0 ]; then printf 'Please run as root!\n'; exit 1 ; fi

[ -d "$INSTALL_DIR" ] && rm -rf "$INSTALL_DIR"
git clone "$REPO_URL" "$INSTALL_DIR"
cd "$INSTALL_DIR" && git checkout "$REV"

"$INSTALL_DIR"/init_server.sh -i

printf '\nPlease check the changelog for the case there are config deprecations, special update steps.\n'
printf '%s/blob/master/CHANGELOG.md\n' "$REPO_URL"

exit 0
