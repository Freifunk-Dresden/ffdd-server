# Freifunk Dresden: ffdd-server - Changelog
`current version:` ![calver](https://img.shields.io/github/v/release/freifunk-dresden/ffdd-server?sort=semver)

## version 1.4.0rc1
	- remove ubuntu 16.04 support
	- add support for debian 11
	- update missing deps for ubuntu 20.04 support
	- update fastd2 to v22
	- update bmxd to version 1.1
		- move bmxd build script to [ffdd-bmxd repo](https://github.com/Freifunk-Dresden/ffdd-bmxd)
	- add ipip tunnel as alternative to bat0
	- add check-script for new uci config options
	- add speedtest-backend for speedtest.ffdd
	- some small bug fixes

## version 1.3.0
**Notice:**
In the current version the configuration management changes from `nvram` (*/etc/nvram.conf*) to `uci` (*/etc/config/ffdd*)!
*You can find a complete example configuration in [/etc/config/ffdd_sample](https://github.com/Freifunk-Dresden/ffdd-server/blob/master/salt/freifunk/base/uci/etc/config/ffdd).*

The current nvram.conf will be migrated automatically to uci!

***This update is not carried out automatically and must be done manually be performed.
use: `bash -c "$(wget http://2ffd.de/ffdd-server_manuell_update -O -)"` or `freifunk-manuell_update.sh`***

we also update development commands in the `init_server.sh` - please see [readme.md](https://github.com/Freifunk-Dresden/ffdd-server#development) part.

***Please reboot the Server after upgrade.***

## version 1.3.0rc10
	- typo fix in README.md
	- optimize fastd.sls
	- apache: ssl dhparm creation fix
	- uci: add develop mode option to disable automatic salt runs and autoupdates.
	- monitorix/vnstat: add tbb_wg backbone interface
	- sysinfo:
		- update to v17
		- display wg_pubkey
	- wireguard:
		- optimize wg-backbone / wg.cgi apache directory solution
		- add /usr/local/bin/wg-backbone.sh start after boot
		- update wg.cgi and add config file

## version 1.3.0rc9
	- reduce amount of looging to /var/log/* for openvpn and fastd (disk-full)
	- add missing parameter when updating server (init_server.sh)

## version 1.3.0rc8
	- logrotate after 1M log file sizes (avoid disk-full issues)

## version 1.3.0rc7
	- Fix MTU for wireguard interface on DS-Lite
	- wg-register API added (still testing)

## version 1.3.0rc6
	- add ubuntu 20.04 support
	- add wireguard outgoing connections
	- change some options for init_server.sh (so it does not start installation without "-i" option. this is more secure and analog to other tools like dpkg, apt-get, apt and more. This is crucial to avoid accidental installations on wrong systems (the Y/N questions did not help me, to prevent that). Also user will see that there is a "help" provided with this script. I also added an option to define debug level during salt operation. vpn1, vpn12 and node 0 are running this version currently

## version 1.3.0rc5
This release adds an extra rule to redirect local generated icmp "fragmentation needed" to vpn tunnel instead of server network interface.
The problem is that Hetzner "disconnects" the host from network when it detects traffic that does not belong to any traffic it knows.

When a freifunk client makes a request to external web servers, this request goes out through a VPN tunnel. Answers that are too big to fit into tbb_fastd2 network interface because of the lower MTU 1200, will cause the kernel to generate icmp "fragmentation needed". Normally those packets travel through the gateway. But those answers must go back through the VPN tunnel.

## version 1.3.0rc4
	- fastd build process
	- wireguard repo Ausschluss (unstable)
	- salt repo for Debian 9 und Ubuntu 16.04 (update)

## version 1.3.0rc3
	- fix openvpn dns

## version 1.3.0rc2
	- fix openvpn bind configuration
	- fix wireguard-backbone script source and cronjob

## version 1.3.0rc1
	- add uci config management
		- change nvram to uci
	- bmxd:
		- change from manuell build to package installation
		- allow to define a list of mesh interfaces (ffdd.sys.bmxd_mesh_if)
	- fastd:
		- update to v21
		- add white/blacklists for better connection control
		- fix `add_connect`
	- internal dns:
		- update zone .ffdd
		- add wildcard entries for gateway subdomains
	- apache:
		- add option to disable apache ddos prevention
		- allow additional config for virtualhost on port 80 and 443
	- add wan-traffic stat to sysinfo.json
	- optimize freifunk-manuell_update.sh to use init_server.sh
	- reduced process priority for salt
	- increase fail2ban maxretry
	- fix ntp.service to wait for bat0 interface
	- fix pb requirement
	- fix some bugs in network and firewall scripts
	- some small code optimizations

## version 1.2.7
	- fix wireguard for ubuntu

## version 1.2.6
	- fix fastd build script

## version 1.2.5
	- fix freifunk-manuell_update.sh
	- turn autoupdate off. here it is better if the admin carries out the update manually.
	  ( after the update, the auto-update becomes active again if it is enabled in /etc/config/ffdd. )

## version 1.2.4
	- add fallback dns for tunnel provider and make it configurable

## version 1.2.3
	- bind: add {c3d2,zentralwerk}.ffdd delegations

## version 1.2.2
	- fix gateway-check (get tunnel_dns_servers)
	- check default openvpn service 'openvpn@openvpn.service' is dead

## version 1.2.1
	- prevent usage of self created communities

## version 1.2.0

	- add the default nvram.conf as a sample to `/etc/nvram_sample.conf`
	- new `/etc/nvram.conf` config option:
		- allow user to change the repo url
		  `freifunk_repo=https://github.com/Freifunk-Dresden/ffdd-server`
	- add nvram edit
	- init-server.sh:
		- change check for autoupdate (do not overwrite user config)
		- add a check for CUSTOM REPO and REV
		- add check for nvram option "ssh_pwauth"
	- www status.cgi - add alt text for status images
	- update bash_aliases and print output
		- add `init_server` alias (OS and Firmware Update)

## version 1.1.0
**Notice:**
This update is not carried out automatically and must be done manually be performed.

***Please reboot the Server after upgrade.***

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
		- move ffdd-server webpage states to ddmesh.serverpage directory/state
		- some optimations for php installation
	- letsencrypt: move ffdd apache part to ddmesh.startpage_ssl
	- openvpn/wireguard: check service is stopped and disable then no config file available
	- monitorix
		- update config options remove some issues
		- disable proc and fail2ban graph
	- vnstat: change git source to a stable rev/commit
	- init_server.sh
		- add salt repo for debian 9 and ubuntu 16
		- a bit makeup for the script
		- add a small ping check
		- add check to install ffdd-server on host
		- check salt_call is possible
	- generally changes and optimizations
		- update README
		- remove temp parts
		- optimize some scripts and salt states
		- fixes in freifunk-gatewaycheck when we have a vpn network interface and ok='false'
		- fix freifunk-register-local-node.sh - get nodeid
		- check we can set sysctl tcp_syncookies
		- add an sysctl.d/ipv6.conf template to deactivate ipv6
		- make a shorter bash_alias help output
		- add /etc/freifunk-server-initdate
		- add /usr/local/bin/freifunk-manuell_update.sh
		- add `pb` (pastebin tool for 0x0 on https://envs.sh)

## version 1.0.16

	- turn autoupdate off. the next release needs a reboot after update.
	  here it is better if the admin carries out the update manually and then restarts the server.
	  ( after the update, the auto-update becomes active again if it is enabled in nvram.conf. )

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

## version 1.0.6

	- remove Debian 8 (jessie) support

	- update init_server: extend OS-Check
	- update helper packages
	- update aliases
	- update apt autoupdate
	- optimze
		- enable package refresh
		- timezone state
		- locales state
		- nvram get version
		- nvram autosetup

	- add freifunk_repo to config file and update letsencrypt NAT'd check
	- add systemtools and linux-firmware
	- add bash_aliases: htop/psa, conntrack notice
	- f2b: remove old hopglass server from ignore list
	- apt: provide default sources.list for debian
	- fastd2/bmxd: update docs url
	- fastd: add support to restrict any new connection to a server. should be used when server has too much connections and is overloaded. in this case we must change backbones in clients

	- fix Service requirements and watches
	- fix salt and script code
	- fix sysctl options
	- fix bind9
	- fix locales
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
	- Readme.md corrections
	- cleanup old code
	- bugfixes and optimation


# Archiv - v0.0.X

## version 0.0.10

	- Bugfixes and Optimizing
		- fix bmxd revison_version
		- add release version
		- add branch and tag system

## version 0.0.9

	- Bugfixes and Optimizing
		- fix nvram autosetup
		- fix apache2 _001-freifunk.conf_
		- fix fastd _S53backbone-fastd_ add_connect
		- fix bmxd revison_version
		- add crontab variant minute

## version 0.0.8

	- Bugfixes and Optimizing
		- fix jinja syntax
		- add config.jinja
		- change configs header
		- add monitorix name and interface variable

## version 0.0.7

	- Bugfixes and Optimizing
		- small changes in cron.d
		- small fixes in letsencrypt (+ ENABLED)
		- fix monitorix restrictions

## version 0.0.6

	- Bugfixes and Optimizing
		- fix sysinfo.json version number
		- fix crontabs
	- (#add letsencrypt for https support)

## version 0.0.5

	- Optimizing and Cleanup
		- clear old icvpn stuff
		- remove pkg: php
		- remove ddmesh - _freifunk-services.sh_

## version 0.0.4

	- Bugfix
		- fix: add fail2ban ignore rule for 10.200.0.1

## version 0.0.3

	- Bugfixes and Optimizing
		- bmxd path fixing in _apache2/var/www_freifunk/index.cgi_
		- init_server.sh
			- add check for 'install_dir'
			- fix ensure _/usr/local/bin/nvram_ is present
		- fix old file list
		- add new alias ('freifunk-call') for '_salt-call state.highstate --local_'

## version 0.0.2

	- Bugfixes and Optimizing</br>
		- change binaray path to _/usr/local/bin/_
		- change source path to _/usr/local/src/_
		- change server path to _/srv/ffdd-server/_
		- _nvram/etc/nvram.conf_
			- add config option for 'install_dir' and 'autoupdate'
		- _nvram/usr/local/bin/nvram_
			- add function 'set', 'unset' and 'version'
		- _fastd/compiled-tools/fastd/build.sh_
			- correct needed lib 'libjson0-dev' to 'libjson-c-dev'
		- _bmxd/init.sls_ - compile_bmxd
			- change cp bmxd to /usr/local/bin/
		- _network/etc/init.d/S40network_
			- add check if param. hashsize available to set
		- _apache2/var/www_freifunk/sysinfo.json_
			- add stats for autoupdate, firmware, hostinfo's
		- check old files and cleanup
	- add _/etc/freifunk-server-version_
	- add _/etc/firewall.users
		- for user defined firewall rules - includes in _/etc/init.d/S41firewall_
	- add Autosetup for new Servers (without configured nvram.conf
		- salt check if not 'ddmesh_registerkey' set in _/etc/nvram.conf_ and run: _nvram/usr/.../freifunk-nvram_autosetup.sh_

## version 0.01

### Initial Commit from old Git-Repository <ddmesh/vserver-base>
