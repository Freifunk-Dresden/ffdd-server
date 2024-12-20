#!/usr/bin/env bash
#version="1.6.2"

# check if user has set the environment variable REV, then use this
REV="T_RELEASE_latest" # means git rev/branch/tag
REPO_URL='https://github.com/Freifunk-Dresden/ffdd-server'
#
INSTALL_DIR='/srv/ffdd-server'
INIT_DATE_FILE='/etc/freifunk-server-initdate'
###
#
#  Freifunk Dresden Server - Installation & Update Script
#
###

check_salt_repo() {
	# repos needs also a check in salt/freifunk/base/salt-minion/init.sls
	[ ! -d /etc/apt/keyrings ] && mkdir /etc/apt/keyrings
	curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring.pgp https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
	curl -fsSL -o /etc/apt/sources.list.d/salt.sources https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources
	tee /etc/apt/preferences.d/salt-pin-1001 <<EOF
Package: salt-*
Pin: version 3007.*
Pin-Priority: 1001
EOF
}

install_uci() {
	DL_URL='http://download.freifunk-dresden.de/server/packages'

	## the pkg version must also be changed in uci/init.sls
	libubox='libubox_20200227_amd64.deb'
	libuci='libuci_20200427_amd64.deb'
	uci='uci_20200427_amd64.deb'

	PKGS=("$libubox" "$libuci" "$uci")
	DIST="$1"

	printf '\n### Install UCI ..\n'

	for PKG in "${PKGS[@]}"; do
		PKG_NAME="$(echo "$PKG" | cut -d'_' -f 1)"
		PKG_VERSION="$(echo "$PKG" | cut -d'_' -f 2 | grep -o '[0-9]*')"
		# check pkg is not installed or has another version
		if [ "$(dpkg-query -W -f='${Status}' "$PKG_NAME" 2>/dev/null | grep -c "ok installed")" -eq 0 ] || \
			[ "$(dpkg-query -W -f='${Version}' "$PKG_NAME")" != "$PKG_VERSION" ]; then
				TEMP_DEB="$(mktemp)" &&
				wget -O "$TEMP_DEB" "$DL_URL/$DIST/$PKG" &&
				dpkg -i "$TEMP_DEB"
				rm -f "$TEMP_DEB"
		fi
	done
	ldconfig
}


print_usage() {
	printf '\nUsage:\n'
	printf ' init_server.sh [-i] [-b [rev/branch/tag] | -u] [-d error|info|debug]\n'
	printf ' -i                    runs the installation for version: %s\n' "${REV}"
	printf ' -b [rev/branch/tag]   installs specified version\n'
	printf ' -u                    do not download repository. This is helpful\n'
	printf '                       when repository was downloaded (git clone) already\n'
	printf ' -h      print this help\n\n'
	printf ' Examples: \n\n'
	printf '  # install Release: %s\n' "${REV}"
	printf '    ./init_server.sh -i\n\n'
	printf '  DEVELOPMENT:\n'
	printf '  # install master (devel) branch\n'
	printf '    ./init_server.sh -i -b\n'
	printf '    ./init_server.sh -i -b <rev/branch/tag>\n\n'
	printf '  # disable git update to use local changes\n'
	printf '    ./init_server.sh -i -u\n\n'
}

print_not_supported_os() {
	printf 'OS is not supported! (for more Informations read the Repository README.md)\n'
	printf 'Supported OS List:\n'
	printf ' - Debian (11/12)\n'
	printf ' - Ubuntu Server LTS (20.04/22.04/24.04)\n'
	exit 1
}

print_init_notice() {
	printf '%s#\n# Notice:%s\n' "$(tput bold)" "$(tput sgr0)"
	printf ' * Please check your config options in /etc/config/ffdd\n'
	printf '   - autoupdate should be set to 1, it is disabled per default\n'
	printf ' * Create your first Backbone Connection:\n'
	printf '   * fastd2 /etc/fastd/peers2/\n'
	printf '     /etc/init.d/S53backbone-fastd2 add_connect <vpnX>.freifunk-dresden.de 5002\n'
	printf '     or: /etc/init.d/S53backbone-fastd2 add_connect <host> <port> <key>\n'
	printf '     # and restart Fastd2:\n'
	printf '     /etc/init.d/S53backbone-fastd2 restart\n'
	printf '   * wireguard /etc/wireguard/\n'
	printf '     /usr/local/bin/wg-backbone.sh register <vpnX>.freifunk-dresden.de\n'
	printf '     or: /usr/local/bin/wg-backbone.sh connect <host> <port> <node> <key>\n'
	printf '\nOptional:\n'
	printf ' * /etc/openvpn\n'
	printf '   # To Create a openvpn configuration use:\n'
	printf '   /etc/openvpn/gen-config vpn0 <original-provider-config-file>\n'
	printf ' * /etc/wireguard/\n'
	printf '   # To Create a wireguard configuration use:\n'
	printf '   /etc/wireguard/gen-config vpn1 <original-provider-config-file>\n'
	printf '\n%sPLEASE READ THE NOTICE AND\nREBOOT THE SYSTEM WHEN EVERYTHING IS DONE!%s\n' "$(tput bold)" "$(tput sgr0)"
}


hostname="$(cat /etc/hostname)"
def_if="$(awk '$2 == 00000000 { print $1 }' /proc/net/route)"
def_addr="$(ip addr show dev "$def_if" | awk '/inet/ {printf "%s\n",$2}' | head -1)"
def_ip="${def_addr//\/*/}"

os_id="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
version_id="$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')"


# move this code to here, to be able to display REV in usage information
if [ -f /usr/local/bin/nvram ] && [ -f /etc/nvram.conf ] && ! [ -L /etc/nvram.conf ]; then
	CUSTOM_REPO_URL="$(nvram get freifunk_repo)"
	[ -n "$CUSTOM_REPO_URL" ] && [ "$CUSTOM_REPO_URL" != "$REPO_URL" ] && REPO_URL="$CUSTOM_REPO_URL"

	CUSTOM_REV="$(nvram get branch)"
	[ -n "$CUSTOM_REV" ] && [ "$CUSTOM_REV" != "$REV" ] && REV="$CUSTOM_REV"

elif [ -f /usr/local/sbin/uci ] && [ -f /etc/config/ffdd ]; then
	CUSTOM_REPO_URL="$(uci -qX get ffdd.sys.freifunk_repo)"
	[ -n "$CUSTOM_REPO_URL" ] && [ "$CUSTOM_REPO_URL" != "$REPO_URL" ] && REPO_URL="$CUSTOM_REPO_URL"

	CUSTOM_REV="$(uci -qX get ffdd.sys.branch)"
	[ -n "$CUSTOM_REV" ] && [ "$CUSTOM_REV" != "$REV" ] && REV="$CUSTOM_REV"
fi


DO_INSTALL=0
OPT_DEBUG='error'
while getopts ":ihbud:" opt "${@}"; do
	case $opt in
	  i)	DO_INSTALL=1 ;;

	  b)	OPT_BRANCH="$OPTARG"
		[ -z "$OPT_BRANCH" ] && OPT_BRANCH='master'
		;;

	  u)	OPT_UPDATE="0" ;;

	  d)	OPT_DEBUG="${OPTARG}"
		case ${OPT_DEBUG} in
			debug)  ;;
			info)  ;;
			error)  ;;
			*) printf 'Invalid debug level: %s\n' "$OPTARG"; exit 1  ;;
		esac
		;;
	  \?)  printf 'Invalid option: -%s\n' "$OPTARG" ; print_usage; exit 1 ;;
	  h|*) print_usage; exit 0 ;;
	esac
done

# only install when option "-i" is given. If this option is not used, than user
# will get the usage-info. This adds a little protection when installing on wrong systems
# in addition to question that is displayed later
if [ $DO_INSTALL != 1 ]; then
	print_usage
	exit 1
fi


printf '### FFDD-Server - Initial Setup ###\n'

#
# -- Check & Setup System --

printf '\n### Check System ..\n'
if [ "$(id -u)" -ne 0 ]; then printf 'Please run as root!\n'; exit 1 ; fi

if [ ! -f "$INIT_DATE_FILE" ]; then
	printf '\nAre you sure you want to install the FFDD-Server on %s%s%s?\n' "$(tput bold)" "$hostname" "$(tput sgr0)"
	printf 'OS: %s %s | IP: %s\n' "$os_id" "$version_id" "$def_ip"
	select yn in "Yes" "No"; do
	case $yn in
		Yes) break ;;
		No)  printf '\n.. Installation canceled!\n'; exit 1 ;;
	esac ; done
fi

printf '\n# Check network and name resolution is working ..\n'
if ! ping -c1 -W5 github.com >/dev/null; then
	printf 'network not reachable or name resolution not working!\n'; exit 1
fi
if ! ping -c1 -W5 download.freifunk-dresden.de >/dev/null; then
	printf 'download.freifunk-dresden.de is not reachable. please try again later!\n'; exit 1
else
	printf '\nOK.\n'
fi

printf '\n# Check tun device is available ..\n'
if [ ! -e /dev/net/tun ]; then
	printf '\tThe TUN device is not available!\nYou need an enabled TUN device (/dev/net/tun) before running this script!\n'
	exit 1
else
	printf '\nOK.\n'
fi

printf '\n# Check users are present ..\n'
for users in freifunk syslog
do
	if ! /usr/bin/id "$users" >/dev/null 2>&1 ; then
		adduser --shell /bin/bash --disabled-login --disabled-password --system --group --no-create-home "$users"
	fi
done
printf '\nOK.\n'


printf '\n# Check System Distribution ..\n'
[ -z "$(command -v curl)" ] && "$PKGMNGR" -y install curl
[ -z "$(command -v wget)" ] && "$PKGMNGR" -y install wget

if [ "$os_id" = 'debian' ]; then
	case "$version_id" in
		11*)	PKGMNGR='apt-get'
				install_uci debian11
		;;
		12*)	PKGMNGR='apt-get'
				install_uci debian12
		;;
		*)		print_not_supported_os ;;
	esac
elif [ "$os_id" = 'ubuntu' ]; then
	case "$version_id" in
		20.04*) PKGMNGR='apt-get'
				install_uci ubuntu20
		;;
		22.04*) PKGMNGR='apt-get'
				install_uci ubuntu22
		;;
		24.04*) PKGMNGR='apt-get'
				install_uci ubuntu24
		;;
		*)		print_not_supported_os ;;
	esac
else
	print_not_supported_os
fi
printf '\nOK.\n'


printf '\n### Install Salt Sources ..\n'
check_salt_repo

printf '\n### Update System ..\n'
"$PKGMNGR" -y update
printf '\n'
"$PKGMNGR" -y dist-upgrade

printf '\n### Install Basic Software ..\n'
"$PKGMNGR" -y install git salt-minion

# fix: install needed deps. for salt-minion on debian 11
if [ "$os_id" = 'debian' ] && [ "$version_id" = '11' ]; then
	"$PKGMNGR" -y install python3-yaml python3-msgpack python3-distro python3-jinja2 python3-tornado python3-packaging python3-looseversion
fi

# disable salt-minion service
systemctl disable salt-minion ; systemctl stop salt-minion &


printf '\n### Install/Update ffdd-server Git-Repository ..\n'

if [ -d "$INSTALL_DIR" ]; then
	cd "$INSTALL_DIR" || exit 1
	[ "$OPT_UPDATE" != '0' ] && git stash
	git fetch
else
	git clone "$REPO_URL" "$INSTALL_DIR"
	cd "$INSTALL_DIR" || exit 1
fi
if [ "$OPT_UPDATE" != '0' ]; then
	# check rev/branch/tag for initial
	if [ -n "$OPT_BRANCH" ]; then
		git checkout "$OPT_BRANCH"
		git pull -f origin "$OPT_BRANCH"
	else
		# T_RELEASE_latest OR $CUSTOM_REV
		git checkout "$REV"
		git pull -f origin "$REV"
	fi
fi


printf '\n### Backup old User configs ..\n'

cp -vf /root/.bashrc /root/.bashrc_bak >/dev/null 2>&1
test -f /root/.bash_aliases && cp -vf /root/.bash_aliases /root/.bash_aliases_bak >/dev/null 2>&1
mv -vf /etc/inputrc /etc/inputrc_bak >/dev/null 2>&1
printf '\nOK.\n'


# ensure uci and /etc/config/ffdd are present
printf '\n### Check uci Setup ..\n'

# uci config
if [ ! -f /etc/config/ffdd ]; then
	printf '\n# Create New /etc/config/ffdd ..\n'
	[ ! -d /etc/config ] && mkdir /etc/config
	cp -fv "$INSTALL_DIR"/salt/freifunk/base/uci/etc/config/ffdd /etc/config/ffdd
fi

# nvram migration
if [ -f /etc/nvram.conf ] && ! [ -L /etc/nvram.conf ]; then
	printf '\n# migrate old nvram to uci ..\n'
	"$INSTALL_DIR"/salt/freifunk/base/uci/usr/local/bin/nvram-migration.sh

	# remove old nvram
	mv /etc/nvram.conf /etc/nvram.backup
	rm -f /etc/nvram.conf* /etc/nvram_sample.conf /usr/local/bin/nvram
fi

# check basic uci options
# check install_dir
[ "$(uci -qX get ffdd.sys.install_dir)" != "$INSTALL_DIR" ] && uci set ffdd.sys.install_dir="$INSTALL_DIR"

# check repo_url
[ -z "$(uci -qX get ffdd.sys.freifunk_repo)" ] && uci set ffdd.sys.freifunk_repo="$REPO_URL"

# check branch
if [ -n "$OPT_BRANCH" ]; then
	[ "$(uci -qX get ffdd.sys.branch)" != "$OPT_BRANCH" ] && uci set ffdd.sys.branch="$OPT_BRANCH"
else
	# T_RELEASE_latest OR $CUSTOM_REV
	[ "$(uci -qX get ffdd.sys.branch)" != "$REV" ] && uci set ffdd.sys.branch="$REV"
fi

# check autoupdate
[ "$(uci -qX get ffdd.sys.autoupdate)" == '' ] && uci set ffdd.sys.autoupdate='1'
if [ "$OPT_UPDATE" = '0' ]; then
	# disable temporary autoupdate
	tmp_au="$(uci -qX get ffdd.sys.autoupdate)"
	uci set ffdd.sys.autoupdate='0'
fi

# check default Interface
[ "$(uci -qX get ffdd.sys.ifname)" != "$def_if" ] && uci set ffdd.sys.ifname="$def_if"

# ssh_pwauth
[ "$(uci -qX get ffdd.sys.ssh_pwauth)" == '' ] && uci set ffdd.sys.ssh_pwauth='1'
#
uci commit
printf '\nOK.\n'


#
# create clean masterless salt enviroment
printf '\n### Check Salt Enviroment ..\n'

rm -f /etc/salt/minion.d/*.conf

printf '\n# add salt freifunk-masterless.conf\n\n'
tee /etc/salt/minion.d/freifunk-masterless.conf <<EOF
### This file managed by Salt, do not edit by hand! ###
#
# ffdd-server - salt-minion masterless configuration file
#
master_type: disable
file_client: local
file_roots:
  base:
    - $INSTALL_DIR/salt/freifunk/base
EOF
printf '\nOK.\n'

#
# -- Initial System --

salt_call() { salt-call state.highstate --local -l "${OPT_DEBUG}" ; }

_scriptfail='0'
_init_run='0'
if [ -f "$INIT_DATE_FILE" ]; then
	printf '\n### run salt ..\n'
else
	printf '\n### Start Initial System .. please wait! Coffee Time ~ 5-10min ..\n'
	printf '# Please do not delete this file!\n#\nFFDD-Server - INIT DATE: %s\n' "$(date -u)" > "$INIT_DATE_FILE"
	chmod 600 "$INIT_DATE_FILE" ; chattr +i "$INIT_DATE_FILE"
	_init_run='1'
fi

if salt_call ; then
	printf '\nOK.\n'
else
	printf '\ntry to fix some mistakes ..\n'
	if salt_call ; then
		printf '\nOK.\n'
	else
		printf '\nFAIL!\nSorry, you need to check some errors. Please check your salt-output and logs.\n'
		_scriptfail='1'
	fi
fi

#
# -- Cleanup System & Print Notice --

if [ "$OPT_UPDATE" = '0' ]; then
	# reset temporary disabled autoupdate
	uci set ffdd.sys.autoupdate="$tmp_au" ; uci commit
fi

printf '\n### Cleanup System ..\n\n'
"$PKGMNGR" -y autoremove

printf '\n### .. All done! Exit script.\n'
[ "$_init_run" -eq 1 ] && print_init_notice

#
# -- Exit --
if [ "$_scriptfail" -eq 0 ]; then
	exit 0
else
	exit 1
fi
