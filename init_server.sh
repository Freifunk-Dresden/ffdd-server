#!/usr/bin/env bash
#version="1.2.5"
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
	[ -z "$(command -v wget)" ] && "$PKGMNGR" -y install wget
	# repos needs also a check in salt/freifunk/base/salt-minion/init.sls
	case "$1" in
		deb9 )
			wget -O - https://repo.saltstack.com/apt/debian/9/amd64/2018.3/SALTSTACK-GPG-KEY.pub | apt-key add -
			echo 'deb http://repo.saltstack.com/apt/debian/9/amd64/2018.3 stretch main' | tee /etc/apt/sources.list.d/saltstack.list
			;;
		u16 )
			wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3/SALTSTACK-GPG-KEY.pub | apt-key add -
			echo 'deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3 xenial main' | tee /etc/apt/sources.list.d/saltstack.list
			;;
	esac
}

print_usage() {
	printf '\nUsage:\n'
	printf 'install latest stable Release:\n'
	printf '   ./init_server.sh\n\n'
	printf 'install unstable development Release:\n'
	printf '   ./init_server.sh dev\n'
	printf '   ./init_server.sh dev <rev/branch/tag>\n'
	exit 1
}

print_not_supported_os() {
	printf 'OS is not supported! (for more Informations read the Repository README.md)\n'
	printf 'Supported OS List:\n'
	printf ' - Debian (9/10)\n'
	printf ' - Ubuntu Server LTS (16.04/18.04)\n'
	exit 1
}

print_init_notice() {
	printf '%s#\n# Notice:%s\n' "$(tput bold)" "$(tput sgr0)"
	printf ' * Please check your config options in /etc/nvram.conf\n'
	printf ' * /etc/fastd/peers2/\n'
	printf '   # add your first Fastd2 Connection:\n'
	printf '   /etc/init.d/S53backbone-fastd2 add_connect <host> 5002\n'
	printf '   or: /etc/init.d/S53backbone-fastd2 add_connect <host> <port> <key>\n'
	printf '   # and restart Fastd2:\n'
	printf '   /etc/init.d/S53backbone-fastd2 restart\n'
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


#
printf '### FFDD-Server - Initial Setup ###\n'

#
# -- Check & Setup System --

case "$1" in
	-h|--help|?|-\? ) print_usage ;;
esac

printf '\n### Check System ..\n'
if [ "$(id -u)" -ne 0 ]; then printf 'Please run as root!\n'; exit 1 ; fi

if [ ! -f "$INIT_DATE_FILE" ]; then
	printf '\nAre you sure you want to install the FFDD-Server on %s%s%s?\n' "$(tput bold)" "$hostname" "$(tput sgr0)"
	printf 'OS: %s %s | IP: %s\n' "$os_id" "$version_id" "$def_ip"
	select yn in "Yes" "No"; do
	case $yn in
		Yes) break ;;
		No)  exit 1 ; break ;;
	esac ; done
fi

printf '\n# Check github is reachable ..\n'
if ! ping -c1 -W5 github.com >/dev/null ; then
	printf 'network not reachable or name resolution not working!\n'; exit 1
else
	printf '\nOK.\n'
fi

printf '\n# Check tun device is available ..\n'
if [ ! -e /dev/net/tun ]; then
	printf '\tThe TUN device is not available!\nYou need a enabled TUN device (/dev/net/tun) before running this script!\n'
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
if [ "$os_id" = 'debian' ]; then
	case "$version_id" in
		9*)     PKGMNGR='apt-get' ; check_salt_repo deb9 ;;
		10*)    PKGMNGR='apt-get' ;;
		*)      print_not_supported_os ;;
	esac
elif [ "$os_id" = 'ubuntu' ]; then
	case "$version_id" in
		16.04*) PKGMNGR='apt-get' ; check_salt_repo u16 ;;
		18.04*) PKGMNGR='apt-get' ;;
		*)      print_not_supported_os ;;
	esac
else
	print_not_supported_os
fi
printf '\nOK.\n'


printf '\n### Update System ..\n'
"$PKGMNGR" -y update
printf '\n'
"$PKGMNGR" -y dist-upgrade

printf '\n### Install Basic Software ..\n'
"$PKGMNGR" -y install git salt-minion

# run salt-minion only as masterless. disable the service:
systemctl disable salt-minion ; systemctl stop salt-minion &


printf '\n### Install/Update ffdd-server Git-Repository ..\n'

if [ -f /usr/local/bin/nvram ] && [ -f /etc/nvram.conf ]; then
	CUSTOM_REPO_URL="$(nvram get freifunk_repo)"
	[ -n "$CUSTOM_REPO_URL" ] && [ "$CUSTOM_REPO_URL" != "$REPO_URL" ] && REPO_URL="$CUSTOM_REPO_URL"

	CUSTOM_REV="$(nvram get branch)"
	[ -n "$CUSTOM_REV" ] && [ "$CUSTOM_REV" != "$REV" ] && REV="$CUSTOM_REV"

	# notice: we do not need to replace the REPO in the next step.
	# salt_call will do that for us later.
fi

if [ -d "$INSTALL_DIR" ]; then
	cd "$INSTALL_DIR" || exit 1
	git stash
	git fetch
else
	git clone "$REPO_URL" "$INSTALL_DIR"
	cd "$INSTALL_DIR" || exit 1
fi
# check rev/branch/tag for initial
if [ "$1" = 'dev' ]; then
	if [ -z "$2" ]; then
		git checkout master
		git pull -f origin master
	else
		git checkout "$2"
		git pull -f origin "$2"
	fi
else
	# T_RELEASE_latest OR $CUSTOM_REV
	git checkout "$REV"
	git pull -f origin "$REV"
fi


printf '\n### Backup old User configs ..\n'

cp -vf /root/.bashrc /root/.bashrc_bak >/dev/null 2>&1
test -f /root/.bash_aliases && cp -vf /root/.bash_aliases /root/.bash_aliases_bak >/dev/null 2>&1
mv -vf /etc/inputrc /etc/inputrc_bak >/dev/null 2>&1


# ensure nvram and nvram.conf are present
printf '\n### Check nvram Setup ..\n'
cp -fv "$INSTALL_DIR"/salt/freifunk/base/nvram/usr/local/bin/nvram /usr/local/bin/

if [ ! -f /etc/nvram.conf ]; then
	printf '\n### Create New /etc/nvram.conf and /usr/local/bin/nvram ..\n'
	cp -fv "$INSTALL_DIR"/salt/freifunk/base/nvram/etc/nvram.conf /etc/nvram.conf
fi

#
# check basic nvram options
# check install_dir
[ "$(nvram get install_dir)" != "$INSTALL_DIR" ] && nvram set install_dir "$INSTALL_DIR"

# check repo_url
[ -z $(nvram get freifunk_repo) ] && nvram set freifunk_repo "$REPO_URL"

# check branch
if [ "$1" = 'dev' ]; then
	if [ -n "$2" ]; then
		[ "$(nvram get branch)" != "$2" ] && nvram set branch "$2"
	else
		[ "$(nvram get branch)" != 'master' ] && nvram set branch master
	fi
else
	# T_RELEASE_latest OR $CUSTOM_REV
	[ "$(nvram get branch)" != "$REV" ] && nvram set branch "$REV"
fi

# check autoupdate
[ "$(nvram get autoupdate)" == '' ] && nvram set autoupdate 1

# check default Interface
[ "$(nvram get ifname)" != "$def_if" ] && nvram set ifname "$def_if"

# ssh_pwauth
[ "$(nvram get ssh_pwauth)" == '' ] && nvram set ssh_pwauth 1
#
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

salt_call() { salt-call state.highstate --local -l error ; }

_scriptfail='0'
_init_run='0'
if [ -f "$INIT_DATE_FILE" ]; then
	printf '\n### run salt ..\n'
else
	printf '\n### Start Initial System .. please wait! Coffee Time ~ 10min ..\n'
	printf '# Please do not delete this file!\n#\nFFDD-Server - INIT DATE: %s\n' "$(date -u)" > "$INIT_DATE_FILE"
	chmod 600 "$INIT_DATE_FILE"
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
