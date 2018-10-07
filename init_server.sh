#!/usr/bin/env bash
#version 0.01
###
#
#  Freifunk Dresden Server - Installation & Update Script
#
###

#
# -- Global Parameter --
#

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

INSTALL_DIR="/opt/ffdd-server"

#
# -- RUN Installation --
#

# check root permission
if [ "$EUID" -ne 0 ]; then printf 'Please run as root!\n'; exit 0; fi

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
"$PKGMNGR" -y --fix-missing install
"$PKGMNGR" -y dist-upgrade
"$PKGMNGR" -y --fix-broken install

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
	git clone https://github.com/cremesk/ffdd-server.git "$INSTALL_DIR"
else
	cd "$INSTALL_DIR" ; git pull origin master
fi


# small salt fix to create templates (replace: false)
cp /root/.bashrc /root/.bashrc_bak >/dev/null 2>&1
rm /root/.bashrc >/dev/null 2>&1
rm /etc/issue.net >/dev/null 2>&1


# create static nvram.conf
printf '\n### Check "nvram" Setup ..\n';

if [ ! -f /etc/nvram.conf ]; then
	printf '\n### Create New /etc/nvram.conf\n';

	cp -v "$INSTALL_DIR"/salt/freifunk/base/nvram/etc/nvram.conf /etc/nvram.conf
	# for initial nvram autosetup
	cp -v "$INSTALL_DIR"/salt/freifunk/base/nvram/usr/local/bin/nvram /usr/local/bin/
else
	printf '\n### /etc/nvram.conf exists.\n';
	printf '### Create /etc/nvram.conf.default & /etc/nvram.conf.diff\n';
	NOTICE="$(printf '\n# Notice: Please check /etc/nvram.conf.diff ! And fix your config!\n')"

	cp -v "$INSTALL_DIR"/salt/freifunk/base/nvram/etc/nvram.conf /etc/nvram.conf.default
	diff /etc/nvram.conf.default /etc/nvram.conf > /etc/nvram.conf.diff
fi


# create clean salt enviroment
printf '\n### Check Salt Enviroment ..\n';

rm -f /etc/salt/minion.d/*.conf

cat > /etc/salt/minion.d/freifunk-masterless.conf <<EOF
file_client: local
file_roots:
  base:
    - $INSTALL_DIR/salt/freifunk/base
EOF

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

printf '%s\n' "$NOTICE"


# Exit gracefully.
exit 0
