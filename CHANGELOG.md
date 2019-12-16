# Freifunk Dresden: ffdd-server - Changelog
`current version:` ![calver](https://img.shields.io/github/v/release/freifunk-dresden/ffdd-server?sort=semver)

## version 1.1.0

	- bind9
		- some optimations for different DNS states: "default gw" / "master" and "slave" Server
		- enable dnssec
		- add stats to ffdd status page
	- bmxd
		- update to version 0.5-freifunk-dresden
		- remove trailing spaces from scripts
		- fix '__FUNCTION__' in gcc extension, use '__func__' now.
	- fastd
		- change repo url to github
		- change to master rev
	- nvram
		- get current version branch by git
		- fix get: get only first entry when the user has duplicated option entries
		- change ffdd-server version output
	- apache2/php
		- optimize salt state
		- move ffdd-server webpage states to ddmesh.serverpage directory/state
		- some optimations for php installation
	- letsencrypt
		- optimize state
		- move ffdd apache part to ddmesh.startpage_ssl
	- openvpn/wireguard: check service is stopped and disable then no config file available
	- monitorix
		- update config options remove some issues
		- enable bind stats
		- disable proc and fail2ban graph
	- vnstat: change git source to a stable rev/commit
	- init_server.sh
		- add salt repo for debian 9 and ubuntu 16
		- a bit makeup for the script
		- add a small ping check
	- other changes and optimations
		- update README
		- remove temp parts and optimize some scripts and salt states
		- fixes in freifunk-gatewaycheck when we have a vpn network interface and ok='false'
		- check we can set sysctl tcp_syncookies
		- add an sysctl.d/ipv6.conf template to deactivate ipv6
		- make a shorter bash_alias help output
		- add `pb` (pastebin tool for 0x0 on envs.sh)

## version 1.0.15

	- update README
	- do not install resolvconf per default
	- remove old fail2ban rules from ipset-conf
	- letsencrypt/ssl: extend fqdn-check and ensure ssl-site is absent then deactivated
	- change gateway-check ip's
	- fix kernel-headers package check
	- fix wireguard gen-config predown

## version 1.0.14

	- fail2ban changes:
		- add ignored private IP's
		- remove jail: apache-fakegooglebot , apache-botsearch

## version 1.0.13

	- fix bind9 db.root check

## version 1.0.12

	- fix init.d S52batmand and S53backbone-fastd2
	- fix ffdd-autoupdate
	- add/reanable cleanup_old_env
	- add a faster speedtest to .bash_alias
	- small readme and comments changes

## version 1.0.11

	- add CHANGELOG.md
	- update fastd2 source
	- update nvram.conf
	    - add 'ssh_pwauth' option to enable/disable password-authentification
	- some more small improvements

## version 1.0.10

	- some improvements
	- update/fix vnstat and vnstat-dashboard
	- fix fastd2 service
	- fix nvram autosetup

## version 1.0.9

	- fix bind9
	- fix f2b cleanup
	- fix nvram
	- fix nvram autosetup
	- fix salt-minion packages on debian stretch
	- enable ssh X11 forwarding
	- update README.md
	- update init_server.sh for dev-installtions

## version 1.0.8

	- add mosh support
	- add routing rule for DNS servers that are only accessable via tunnel

## version 1.0.7

	- add Debian 10 (buster) support
	- update Debian Security Repo and Information
	- small Bugfixes
		- bind root.hints
		- vnstat dir perms

## version 1.0.6_fix6

	- update apt autoupdate
	- add freifunk_repo to config file and update letsencrypt NAT'd check

## version 1.0.6_fix5

	- fastd: add support to restrict any new connection to a server. should be used when server has too much connections and is overloaded. in this case we must change backbones in clients

## version 1.0.6_fix4

	- apt: provide default sources.list for debian
	- fastd2/bmxd: update docs url
	- root: bash_aliases typo fix

## version 1.0.6_fix3

	- add systemtools and linux-firmware
	- f2b: remove old hopglass server from ignore list
	- bash_aliases add htop/psa, conntrack notice

## version 1.0.6_fix2

	- fix Service requirements and watches
	- fix salt and script code
	- optimze nvram autosetup
	- remove temp. clear old server enviroment

## version 1.0.6_fix1

	- nvram: show version-fix
	- fix bind9
	- fix locales

## version 1.0.6

	- remove Debian 8 (jessie) support

	- update init_server: extend OS-Check
	- update helper packages
	- update aliases
	- optimze
		- enable package refresh
		- timezone state
		- locales state
		- nvram get version

	- fix sysctl options
	- fix S42firewall6
		- Required-Start
		- Wait for the xtables lock

## version 1.0.5

	- add root bash_user_aliases for user definded aliases

	- update sysctl and kernel managment
	- update ntp server to public "de" pool (de.pool.ntp.org)
	- update letsencrypt
		- optimize install process
		- change ssl dhparm to 2048bit
	- update sysinfo.json to version 15
		- fix cpuinfo
		- add cpucount info
	- update openvpn and wireguard init
	- update crontabs disable send mails
	- update freifunk-server autoupdate
	- update freifunk-server-version info
	- update freifunk-gateway-status.sh
	- update bash aliases

	- fix salt code comments
	- fix fastd2 service watch src
	- fix bind requirements
	- fix f2b-ipset clear once per week
	- fix www_Freifunk
		- force symlink creation
		- make sure that only files that are set up by salt
	- fix monitorix owner for images

## version 1.0.4

	- add Wireguard VPN Support
	- add default resolv.conf with dynamic resolvconf
	- add check for tun device in 'init_server.sh'
	- add fail2ban apache-auth jail
	- add ipset for f2b-blacklist
	- add Code Comments

	- update Server Page
	- update freifunk-gateway-check.sh
	- update Configurations
		- ntp
		- rsyslog
		- monitorix
		- vnstat

	- small Bugfixes
		- apache2 service requierement
		- fastd2/bmxd service requirements
		- sysinfo.json: check gps coordinates are set
		- ssh/fail2ban installation check
		- letsencrypt email validation
		- fix/update vnstat Traffic Dashboard

	- other changes
		- pkg for ping
		- bashrc and aliases
		- letsencrypt (ssl): increase dhparm and rsa-key to 4096 bit
		- bind: rename openvpn.forwarder vpn.forwarder to generalize
		- clear old HNA

## version 1.0.3

	- add vnstat Traffic Statistik Dashboard
	- update README.md
	- update clear_oldenv
	- small Bugfixes
		- ff-www: change encoding to utf-8

## version 1.0.2

	- fix letsencrypt service and add hostname - fqdn check

	- add Support for Ubuntu 18.04 LTS
	- add Connection Test to freifunk-autoupdate

	- update README.md
	- update sysinfo.json to version 14
	- update Server Webpage
	- update openvpn service for vpn1
	- update openvpn gen-config for vpn1

	- cleanup old code
	- Bugfixes and Optimation

## version 1.0.1_fix1

	- fix letsencrypt service and add hostname fqdn check
	- fix openvpn service
	- Readme.md corrections
	- cleanup old code
	- bugfixes and optimation

## version 1.0.1

	- add branch and tag git-system
	- add Autosetup for new Servers (without _/etc/nvram.conf_)
	- _nvram/etc/nvram.conf_
		> add config option for 'install_dir' , 'autoupdate' and 'release'
	- _nvram/usr/local/bin/nvram_
		> add function 'set', 'unset' and 'version'
	- add _/etc/freifunk-server-version_
	- add _/usr/local/src/bmxd_revision_
	- add _/etc/firewall.users_
		> for user defined firewall rules - includes in _/etc/init.d/S41firewall_
	- add letsencrypt https support
	- add fail2ban as IPS
	- bugfixes and optimation


# Archiv - v0.0.X

## version 0.0.10

	* Bugfixes and Optimizing
		- fix bmxd revison_version
		- add release version
		- add branch and tag system

## version 0.0.9

	* Bugfixes and Optimizing
		- fix nvram autosetup
		- fix apache2 _001-freifunk.conf_
		- fix fastd _S53backbone-fastd_ add_connect
		- fix bmxd revison_version
		- add crontab variant minute

## version 0.0.8

	* Bugfixes and Optimizing
		- fix jinja syntax
		- add config.jinja
		- change configs header
		- add monitorix name and interface variable

## version 0.0.7

	* Bugfixes and Optimizing
		- small changes in cron.d
		- small fixes in letsencrypt (+ ENABLED)
		- fix monitorix restrictions

## version 0.0.6

	* Bugfixes and Optimizing
		- fix sysinfo.json version number
		- fix crontabs
	* (#add letsencrypt for https support)

## version 0.0.5

	* Optimizing and Cleanup
		- clear old icvpn stuff
		- remove pkg: php
		- remove ddmesh - _freifunk-services.sh_

## version 0.0.4

	* Bugfix
		- fix: add fail2ban ignore rule for 10.200.0.1

## version 0.0.3

	* Bugfixes and Optimizing
		- bmxd path fixing in _apache2/var/www_freifunk/index.cgi_
		* init_server.sh
				- add check for 'install_dir'
				- fix ensure _/usr/local/bin/nvram_ is present
		- fix old file list
		- add new alias ('freifunk-call') for '_salt-call state.highstate --local_'

## version 0.0.2

	* Bugfixes and Optimizing</br>
		- change binaray path to _/usr/local/bin/_
		- change source path to _/usr/local/src/_
		- change server path to _/srv/ffdd-server/_
		- _nvram/etc/nvram.conf_
				> add config option for 'install_dir' and 'autoupdate'
		- _nvram/usr/local/bin/nvram_
				> add function 'set', 'unset' and 'version'
		- _fastd/compiled-tools/fastd/build.sh_
				> correct needed lib 'libjson0-dev' to 'libjson-c-dev'
		- _bmxd/init.sls_ - compile_bmxd
				> change cp bmxd to /usr/local/bin/
		- _network/etc/init.d/S40network_
				> add check if param. hashsize available to set
		- _apache2/var/www_freifunk/sysinfo.json_
				> add stats for autoupdate, firmware, hostinfo's
		- check old files and cleanup
	* add _/etc/freifunk-server-version_
	* add _/etc/firewall.users
		- for user defined firewall rules - includes in _/etc/init.d/S41firewall_
	* add Autosetup for new Servers (without configured nvram.conf
		- salt check if not 'ddmesh_registerkey' set in _/etc/nvram.conf_ and run: _nvram/usr/.../freifunk-nvram_autosetup.sh_

## version 0.01

### Initial Commit from old Git-Repository <ddmesh/vserver-base>
