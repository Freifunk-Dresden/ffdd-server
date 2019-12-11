#!/usr/bin/env bash
#version="1.1.0"
tag="T_RELEASE_latest"
REPO_URL='https://github.com/Freifunk-Dresden/ffdd-server'
INSTALL_DIR='/srv/ffdd-server'
###
#
#  Freifunk Dresden Server - Installation & Update Script
#
###

print_usage() {
	printf 'FFDD-Server - Initial Setup\n\nUsage:\n'
	printf 'install latest stable Release:\n'
	printf '   ./init_server.sh\n\n'
	printf 'install unstable development Release:\n'
	printf '   ./init_server.sh dev\n'
	printf '   ./init_server.sh dev <branch/tag>\n'
	exit 1
}

print_not_supported_os() {
	printf 'OS is not supported! (for more Informations read the Repository README.md)\n'
	printf 'Supported OS List:\n'
	printf ' - Debian (9/10)\n'
	printf ' - Ubuntu Server LTS (16.04/18.04)\n'
	exit 1
}

print_notice() {
	printf '\n# Notice:\n'
	printf ' * Please check your config options in /etc/nvram.conf\n'
	printf ' * /etc/fastd/peers2/\n'
	printf '   # add your first Fastd2 Connection:\n'
	printf '   /etc/init.d/S53backbone-fastd2 add_connect <vpnX>.freifunk-dresden.de 5002\n'
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

#
# -- Check & Setup System --

if [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = '?' ]; then
	print_usage
fi

printf '\n### Check System ..\n'

if [ "$EUID" -ne 0 ];  then
	printf 'Please run as root!\n' ; exit 1
fi

if ! ping -c1 -W5 github.com >/dev/null ; then
	printf 'network not reachable or name resolution not working!\n' ; exit 1
fi

printf '\n# Check tun device is available ..\n'
if [ ! -e /dev/net/tun ]; then
	printf '\tThe TUN device is not available!\nYou need a enabled TUN device (/dev/net/tun) before running this script!\n'; exit 1
fi

printf '\n# Check users are present ..\n'
for users in freifunk syslog
do
	if ! /usr/bin/id "$users" >/dev/null 2>&1 ; then
		adduser --shell /bin/bash --disabled-login --disabled-password --system --group --no-create-home "$users"
	fi
done


printf '\n# Check System Distribution ..\n'
os_id="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
version_id="$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')"

check_wget() { [[ -z "$(command -v wget)" ]] && "$1" -y install wget ; }

if [ "$os_id" = 'debian' ]; then
	case "$version_id" in
		9*)     PKGMNGR='apt-get' ; check_wget "$PKGMNGR"
                wget -O - https://repo.saltstack.com/apt/debian/9/amd64/2018.3/SALTSTACK-GPG-KEY.pub | apt-key add -
                echo 'deb http://repo.saltstack.com/apt/debian/9/amd64/2018.3 stretch main' | tee /etc/apt/sources.list.d/saltstack.list
                ;;
		10*)    PKGMNGR='apt-get' ;;
		*)      print_not_supported_os ;;
	esac
elif [ "$os_id" = 'ubuntu' ]; then
	case "$version_id" in
		16.04*) PKGMNGR='apt-get' ; check_wget "$PKGMNGR"
                wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3/SALTSTACK-GPG-KEY.pub | apt-key add -
                echo 'deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3 xenial main' | tee /etc/apt/sources.list.d/saltstack.list
                ;;
		18.04*) PKGMNGR='apt-get' ;;
		*)      print_not_supported_os ;;
	esac
else
	print_not_supported_os
fi


printf '\n### Update System ..\n'
"$PKGMNGR" -y update
"$PKGMNGR" -y dist-upgrade

printf '\n### Install Basic Software ..\n'
"$PKGMNGR" -y install git salt-minion
# run salt-minion only as masterless. disable the service:
systemctl disable salt-minion ; systemctl stop salt-minion


printf '\n### Install/Update ffdd-server Git-Repository ..\n'
if [ -d "$INSTALL_DIR" ]; then
	cd "$INSTALL_DIR" || exit 1
	git fetch
else
	git clone "$REPO_URL" "$INSTALL_DIR"
	cd "$INSTALL_DIR" || exit 1
fi
# check branch/tag for initial
if [ "$1" = 'dev' ]; then
	if [ -z "$2" ]; then
		git checkout master
		git pull -f origin master
	else
		git checkout "$2"
		git pull -f origin "$2"
	fi
else
	# T_RELEASE_latest
	git checkout "$tag"
	git pull -f origin "$tag"
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

	# check branch
	if [ "$1" = 'dev' ]; then
		if [ -n "$2" ]; then
			[[ "$(nvram get branch)" != "$2" ]] && nvram set branch "$2"
		else
			[[ "$(nvram get branch)" != 'master' ]] && nvram set branch master
		fi
	fi

	# check install_dir
	[[ "$(nvram get install_dir)" != "$INSTALL_DIR" ]] && nvram set install_dir "$INSTALL_DIR"

	# check autoupdate
	[[ "$(nvram get autoupdate)" != "1" ]] && nvram set autoupdate 1

	# check default Interface
	def_if="$(awk '$2 == 00000000 { print $1 }' /proc/net/route)"
	[[ "$(nvram get ifname)" != "$def_if" ]] && nvram set ifname "$def_if"

#
# create clean masterless salt enviroment
printf '\n### Check Salt Enviroment ..\n'

rm -fv /etc/salt/minion.d/*.conf

cat > /etc/salt/minion.d/freifunk-masterless.conf <<EOF
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


# ensure running services are stopped
printf '\n### Ensure Services are Stopped ..\n'

services='S40network S41firewall S42firewall6 S52batmand S53backbone-fastd2 S90iperf3 fail2ban apache2 monitorix openvpn@openvpn-vpn0 openvpn@openvpn-vpn1 wg-quick@vpn0 wg-quick@vpn1'
for s in $services
do
	# check service exists
	if [ "$(systemctl list-units | grep -c "$s")" -ge 1 ]; then
		# true: stop it
		if [ "$(systemctl show -p ActiveState "$s" | cut -d'=' -f2 | grep -c inactive)" -lt 1 ]; then
			systemctl stop "$s" >/dev/null 2>&1
		fi
	fi
done

#
# -- Initial System --

printf '\n### Start Initial System.. please wait! Coffee Time ~ 10-30min ..\n'

salt-call state.highstate --local -l error

#
# -- Cleanup System & Print Notice --

printf '\n### .. All done! Cleanup System ..\n'

"$PKGMNGR" autoremove
print_notice

#
# Exit gracefully.
exit 0
