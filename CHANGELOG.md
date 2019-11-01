# Freifunk Dresden: ffdd-server Updates
`current version 1.0.11`

<br/>

_**version 1.0.11**_

	- fix init.d S52batmand
	- add CHANGELOG.md
	- update fastd2 source
	- update nvram.conf
	    - add 'ssh_pwauth' option to enable/disable password-authentification
	- some more small improvements

<br />

_**version 1.0.10**_

	- some improvements
	- update/fix vnstat and vnstat-dashboard
	- fix fastd2 service
	- fix nvram autosetup

<br />

_**version 1.0.9**_

	- fix bind9
	- fix f2b cleanup
	- fix nvram
	- fix nvram autosetup
	- fix salt-minion packages on debian stretch
	- enable ssh X11 forwarding
	- update README.md
	- update init_server.sh for dev-installtions

<br/>

_**version 1.0.8**_

	- add mosh support
	- add routing rule for DNS servers that are only accessable via tunnel

<br/>

_**version 1.0.7**_

	- add Debian 10 (buster) support
	- update Debian Security Repo and Information
	- small Bugfixes
		- bind root.hints
		- vnstat dir perms

<br/>

_**version 1.0.6_fix6**_

	- update apt autoupdate
	- add freifunk_repo to config file and update letsencrypt NAT'd check

<br/>

_**version 1.0.6_fix5**_

	- fastd: add support to restrict any new connection to a server. should be used when server has too much connections and is overloaded. in this case we must change backbones in clients

<br/>

_**version 1.0.6_fix4**_

	- apt: provide default sources.list for debian
	- fastd2/bmxd: update docs url
	- root: bash_aliases typo fix

<br/>

_**version 1.0.6_fix3**_

	- add systemtools and linux-firmware
	- f2b: remove old hopglass server from ignore list
	- bash_aliases add htop/psa, conntrack notice

<br/>

_**version 1.0.6_fix2**_

	- fix Service requirements and watches
	- fix salt and script code
	- optimze nvram autosetup
	- remove temp. clear old server enviroment

<br/>

_**version 1.0.6_fix1**_

	- nvram: show version-fix
	- fix bind9
	- fix locales

<br/>

_**version 1.0.6**_

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

<br/>

_**version 1.0.5**_

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

<br/>

_**version 1.0.4**_

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

<br/>

_**version 1.0.3**_

	- add vnstat Traffic Statistik Dashboard
	- update README.md
	- update clear_oldenv
	- small Bugfixes
		- ff-www: change encoding to utf-8

<br/>

_**version 1.0.2**_

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

<br/>

_**version 1.0.1_fix1**_

	- fix letsencrypt service and add hostname fqdn check
	- fix openvpn service
	- Readme.md corrections
	- cleanup old code
	- bugfixes and optimation

<br/>

_**version 1.0.1**_

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

<br/>

# Updates Archiv - v0.0.X
<br/>

_**version 0.0.10**_

	* Bugfixes and Optimizing
		- fix bmxd revison_version
		- add release version
		- add branch and tag system
<br/>

_**version 0.0.9**_

	* Bugfixes and Optimizing
		- fix nvram autosetup
		- fix apache2 _001-freifunk.conf_
		- fix fastd _S53backbone-fastd_ add_connect
		- fix bmxd revison_version
		- add crontab variant minute

<br/>

_**version 0.0.8**_

	* Bugfixes and Optimizing
		- fix jinja syntax
		- add config.jinja
		- change configs header
		- add monitorix name and interface variable

<br/>

_**version 0.0.7**_

	* Bugfixes and Optimizing
		- small changes in cron.d
		- small fixes in letsencrypt (+ ENABLED)
		- fix monitorix restrictions

<br/>

_**version 0.0.6**_

	* Bugfixes and Optimizing
		- fix sysinfo.json version number
		- fix crontabs
	* (#add letsencrypt for https support)

<br/>

_**version 0.0.5**_

	* Optimizing and Cleanup
		- clear old icvpn stuff
		- remove pkg: php
		- remove ddmesh - _freifunk-services.sh_

<br/>

_**version 0.0.4**_

	* Bugfix
		- fix: add fail2ban ignore rule for 10.200.0.1

<br/>

_**version 0.0.3**_

	* Bugfixes and Optimizing
		- bmxd path fixing in _apache2/var/www_freifunk/index.cgi_
		* init_server.sh
				- add check for 'install_dir'
				- fix ensure _/usr/local/bin/nvram_ is present
		- fix old file list
		- add new alias ('freifunk-call') for '_salt-call state.highstate --local_'

<br/>

_**version 0.0.2**_

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
	* add _/etc/firewall.users_<br/>
		- for user defined firewall rules - includes in _/etc/init.d/S41firewall_
	* add Autosetup for new Servers (without configured nvram.conf)<br/>
		- salt check if not 'ddmesh_registerkey' set in _/etc/nvram.conf_ and run: _nvram/usr/.../freifunk-nvram_autosetup.sh_

<br/>

_**version 0.01**_

_**Initial Commit from Git-Repository [ddmesh/vserver-base](https://github.com/ddmesh/vserver-base)**_
