#!/usr/bin/env bash
#version="1.0.9"
#branch="B_RELEASE"
#fix=""
tag="T_RELEASE_latest"
###
#
#  Freifunk Dresden Server - Installation & Update Script
#
###

#
# -- Global Parameter --
#

export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

INSTALL_DIR='/srv/ffdd-server'

# function: print helper "os is not supported"
print_not_supported_os() {
	printf 'OS is not supported! (for more Informations read the Repository README.md)\n'
	printf 'Supported OS List:\n\t- Debian (9/10)\n'
	printf '\t- Ubuntu LTS (16.04/18.04)\n'
	exit 1
}

print_usage() {
	printf 'FFDD-Server | Setup\n\n'
	printf 'Usage:\t./init_server.sh\t - initial Install from latest Release\n'
	printf '\t./init_server.sh dev\t - initial DEV-Install\n'
	printf '\t./init_server.sh dev <branch/tag>\n'
	exit 1
}

#
# -- Check & Setup System --
#

if [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$1" = '?' ]; then
	print_usage;
fi

#
# check root permission
[[ "$EUID" -ne 0 ]] && printf 'Please run as root!\n' && exit 1

#
# check tun device is available
if [ ! -e /dev/net/tun ]; then
	printf '\tThe TUN device is not available!\nYou need a enabled TUN device (/dev/net/tun) before running this script!\n'; exit 1
fi

#
# check Distribution
os_id="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
version_id="$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"')"

if [ "$os_id" = 'debian' ]; then
	case "$version_id" in
		9*)		PKGMNGR='apt-get' ;;
		10*)	PKGMNGR='apt-get' ;;
		*)		print_not_supported_os ;;
	esac

elif [ "$os_id" = 'ubuntu' ]; then
	case "$version_id" in
		16.04*)	PKGMNGR='apt-get' ;;
		18.04*)	PKGMNGR='apt-get' ;;
		*)		print_not_supported_os ;;
	esac

elif [ "$os_id" = 'centos' ]; then
	case "$version_id" in
		*)		printf 'Centos is not supported yet!\n'; exit 1 ;;
	esac
else
	print_not_supported_os
fi

#
# update system
printf '\n### Update System ..\n'

"$PKGMNGR" -y update
"$PKGMNGR" -y upgrade

#
# install basic software
printf '\n### Instaĺl Basic Software ..\n'

"$PKGMNGR" -y install git salt-minion

#
# check users are present
printf '\n### Check users are present ..\n'

for users in freifunk syslog
do
	if ! /usr/bin/id "$users" >/dev/null 2>&1 ; then
		adduser --shell /bin/bash --disabled-login --disabled-password --system --group --no-create-home "$users"
	fi
done

#
# install/update repository
printf '\n### Install/Update Repository ..\n'

test ! -d "$INSTALL_DIR" && git clone https://github.com/Freifunk-Dresden/ffdd-server "$INSTALL_DIR"
cd "$INSTALL_DIR"

# check branch/tag for initial
if [ "$1" = 'dev' ]; then
	# DEV
	if [ ! -z "$2" ]; then
		git fetch
		git checkout "$2"
		git pull -f origin "$2"
	fi
else
	# T_RELEASE_latest
	git fetch
	git checkout "$tag"
	git pull -f origin "$tag"
fi

#
# backup old user configs
cp -f /root/.bashrc /root/.bashrc_bak >/dev/null 2>&1
test -f /root/.bash_aliases && cp /root/.bash_aliases /root/.bash_aliases_bak >/dev/null 2>&1
mv /etc/inputrc /etc/inputrc_bak >/dev/null 2>&1

#
# ensure nvram and nvram.conf are present
printf '\n### Check "nvram" Setup ..\n'

	cp -fv "$INSTALL_DIR"/salt/freifunk/base/nvram/usr/local/bin/nvram /usr/local/bin/

	if [ ! -f /etc/nvram.conf ]; then
		printf '\n### Create New /etc/nvram.conf and /usr/local/bin/nvram\n'

		cp -fv "$INSTALL_DIR"/salt/freifunk/base/nvram/etc/nvram.conf /etc/nvram.conf
	fi

	# check branch
	if [ "$1" = 'dev' ]; then
		if [ ! -z "$2" ]; then
			[[ "$(nvram get branch)" != "$2" ]] && nvram set branch "$2"
		else
			[[ "$(nvram get branch)" != 'master' ]] && nvram set branch master
		fi
	fi

	# check default Interface
	def_if="$(awk '$2 == 00000000 { print $1 }' /proc/net/route)"
	[[ "$(nvram get ifname)" != "$def_if" ]] && nvram set ifname "$def_if"

	# check install_dir
	[[ "$(nvram get install_dir)" != "$INSTALL_DIR" ]] && nvram set install_dir "$INSTALL_DIR"

#
# create clean masterless salt enviroment
printf '\n### Check Salt Enviroment ..\n'

rm -fv /etc/salt/minion.d/*.conf

cat > /etc/salt/minion.d/freifunk-masterless.conf <<EOF
### This file managed by Salt, do not edit by hand! ###
#
# ffdd-server - salt-minion masterless configuration file
#

file_client: local
file_roots:
  base:
    - $INSTALL_DIR/salt/freifunk/base

EOF

#
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
#

printf '\n### Start Initial System. (please wait! Coffee Time ca.10min)\n'

salt-call state.highstate --local


#
# -- Cleanup System & Print Notice --
#

printf '\n### .. All done! Cleanup System ..\n'

"$PKGMNGR" autoremove

printf '\n# Notice:\n'
printf ' * Please check config options in /etc/nvram.conf\n'
printf ' * /etc/fastd/peers2/\n'
printf '\t# To Create a Fastd2 Connection use:\n'
printf '\t/etc/init.d/S53backbone-fastd2 add_connect vpn/nodeX.freifunk-dresden.de 5002\n'
printf ' * /etc/openvpn\n'
printf '\t# To Create a openvpn configuration use:\n'
printf '\t/etc/openvpn/gen-config vpn0 <original-provider-config-file>\n'
printf ' * /etc/wireguard/\n'
printf '\t# To Create a wireguard configuration use:\n'
printf '\t/etc/wireguard/gen-config vpn1 <original-provider-config-file>\n'


# Exit gracefully.
exit 0
