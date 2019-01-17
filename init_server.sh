#!/usr/bin/env bash
#version="1.0.3"
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


# function: find default gateway interface
get_default_interface() {
	def_if="$(awk '$2 == 00000000 { print $1 }' /proc/net/route)"
}

#
# -- Check & Setup System --
#

# kill running instance
mypid="$$"
pname="${0##*/}"
IFS=' '
printf '%s pid: %s\n' "$pname" "$mypid"
for i in $(pidof "$pname")
do
	test "$i" != "$mypid" && printf 'kill %s\n' "$i" && kill -9 "$i"
done

# check root permission
if [ "$EUID" -ne 0 ]; then printf 'Please run as root!\n'; exit 0; fi

# check tun device is available
if [ ! -e /dev/net/tun ]; then
	printf '\tThe TUN device is not available!\nYou need to enable TUN before running this script!\n'
	exit 0
fi

# check Distribution
if [ -f /etc/debian_version ]; then
	PKGMNGR='apt-get';
elif [ -f /etc/centos-release ] ; then
	printf 'Centos is not supported yet!\n'; exit 0;
	#PKGMNGR='yum'
elif [ -f /etc/fedora-release ] ; then
	printf 'Fedora is not supported yet!\n'; exit 0;
	#PKGMNGR='dnf'
else
	printf 'OS not supported yet!\n'; exit 0;
fi


# update system
printf '\n### Update System ..\n';

"$PKGMNGR" update
"$PKGMNGR" -y upgrade
"$PKGMNGR" -y dist-upgrade


# install basic software
printf '\n### Instaĺl Basic Software..\n';

"$PKGMNGR" -y install git salt-minion


# check users are present
printf '\n### Check users are present..\n';

for users in freifunk syslog
do
	if ! /usr/bin/id "$users" >/dev/null 2>&1 ; then
		adduser --shell /bin/bash --disabled-login --disabled-password --system --group --no-create-home "$users"
	fi
done


# install/update repository
printf '\n### Install/Update Repository..\n';

if [ ! -d "$INSTALL_DIR" ]; then
	git clone https://github.com/Freifunk-Dresden/ffdd-server "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"

	git fetch
	git checkout "$tag"
	git pull -f origin "$tag"


# small helper for salt to create templates (replace: false)
cp -fv /root/.bashrc /root/.bashrc_bak >/dev/null 2>&1
rm -f /root/.bashrc >/dev/null 2>&1
rm -f /etc/inputrc >/dev/null 2>&1


# ensure nvram and nvram.conf are present and correct
printf '\n### Check "nvram" Setup ..\n';

	cp -fv "$INSTALL_DIR"/salt/freifunk/base/nvram/usr/local/bin/nvram /usr/local/bin/

	if [ ! -f /etc/nvram.conf ]; then
		printf '\n### Create New /etc/nvram.conf and /usr/local/bin/nvram\n';

		cp -fv "$INSTALL_DIR"/salt/freifunk/base/nvram/etc/nvram.conf /etc/nvram.conf

	else
		# Temp.-Part to update old servers
		printf '\n### /etc/nvram.conf exists.\n';
		printf '### Create /etc/nvram.conf.default & /etc/nvram.conf.diff\n';

		# check new options are set
		# check autoupdate
		if [ -z "$(nvram get autoupdate)" ]; then
			sed -i '1s/^/\nautoupdate=1\n\n/' /etc/nvram.conf
			sed -i '1s/^/\n# set autoupdate (0=off 1=on)/' /etc/nvram.conf
		fi
		# check release
		if [ -z "$(nvram get branch)" ]; then
			sed -i '1s/^/\nbranch=T_RELEASE_latest\n\n/' /etc/nvram.conf
			sed -i '1s/^/\n# Git-Branch/' /etc/nvram.conf
		fi
		# check install path
		if [ -z "$(nvram get install_dir)" ]; then
			{ printf '# install_dir !Please do not touch!\ninstall_dir=%s\n\n' $INSTALL_DIR; cat /etc/nvram.conf; } >/etc/nvram.conf.new
				mv /etc/nvram.conf.new /etc/nvram.conf
		fi

		cp -fv "$INSTALL_DIR"/salt/freifunk/base/nvram/etc/nvram.conf /etc/nvram.conf.default
		diff /etc/nvram.conf.default /etc/nvram.conf > /etc/nvram.conf.diff
	fi

	# check default Interface is correct set
	get_default_interface
	if [ "$(nvram get ifname)" != "$def_if" ]; then
		nvram set ifname "$def_if"
	fi

	# check install_dir is correct set
	if [ "$(nvram get install_dir)" != "$INSTALL_DIR" ]; then
		nvram set install_dir "$INSTALL_DIR"
	fi


# create clean masterless salt enviroment
printf '\n### Check Salt Enviroment ..\n';

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


# ensure running services are stopped
printf '\n### Ensure Services are Stopped ..\n';

services='S40network S41firewall S42firewall6 S52batmand S53backbone-fastd2 S90iperf3 fail2ban bind9 apache2 monitorix openvpn@openvpn openvpn@openvpn1'
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

printf '\n### Start Initial System. (please wait!)\n';

salt-call state.highstate --local


#
# -- Cleanup System --
#

printf '\n### .. All done! Cleanup System ..\n';

"$PKGMNGR" autoremove

printf '\n# Notice:\n  * Please check config options in /etc/nvram.conf\n'
printf '\n  * /etc/fastd/peers2/\n\t# To Create a Fastd2 Connection use:\n'
printf '\t/etc/init.d/S53backbone-fastd2 add_connect vpn/nodeX.freifunk-dresden.de 5002\n'

# Exit gracefully.
exit 0
