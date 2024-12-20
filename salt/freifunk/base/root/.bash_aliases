# ~/.bash_aliases: Alias definitions

#
# Custom User Aliases
#

if [ -f ~/.bash_user_aliases ]; then
    . ~/.bash_user_aliases
fi

#
# Freifunk Aliases
#

alias freifunk-bmxd='/etc/init.d/S52batmand'
alias freifunk-fastd='/etc/init.d/S53backbone-fastd2'

alias freifunk-version='cat /etc/freifunk-server-version'
alias freifunk-gw-status='/usr/local/bin/freifunk-gateway-status.sh'

alias init_server='/srv/ffdd-server/init_server.sh'
alias freifunk-manuell-update='/usr/local/bin/freifunk-manuell_update.sh'
alias freifunk-manuell-update-online='bash -c "$(wget http://2ffd.de/ffdd-server_manuell_update -O -)"'
alias salt_call='salt-call state.highstate --local -l error'
alias freifunk-call='salt_call'

alias f2b-list='/sbin/ipset list blacklist_fail2ban'

alias psa='ps -axuwf'
alias conntrack='tail /var/log/conntrack.log'

alias showip='printf "IP: %s\n" "$(curl -sL ip.envs.net)"'
alias speedtest='wget -O /dev/null http://90.130.70.73/10GB.zip --report-speed=bits'
alias speedtest-ovh='wget -O /dev/null http://213.186.33.6/files/10Gb.dat --report-speed=bits'
alias speedtest-belwue='wget -O /dev/null http://speedtest.belwue.net/10G --report-speed=bits'

# Git diff
alias gitdiff='git difftool -t idiff -y'

# LOG
alias jwarn='journalctl --system -x | grep warn'
alias jfail='journalctl --system -x | grep fail'
alias jerr='journalctl --system -x | grep error'
alias jdeni='journalctl --system -x | grep denied'

# Add an "alert" alias for long running commands. Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# add freifunk specifics to prompt, because on some vservers /etc/hostname is
# always replaced after booting
PS1="${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$(uci -qX get ffdd.sys.contact_note)\[\033[00m\] #
\[\033[01;37m\]\w\[\033[00m\] > "


cat <<EOM
-----------------------------------------------------------------
# tools:
    init_server -i          ( update OS and Firmware )
    freifunk-manuell-update ( reset and update Firmware )
    freifunk-call           ( run salt )

    uci                     ( config management helper )
    freifunk-version        ( show Server Version and Branch )
    freifunk-gw-status      ( show GW-Country )
    showip                  ( show own public IP )

    f2b-list                ( show blocked IP's )
    f2b-unban <IP>          ( unban blocked IP )

    htop / psa              ( show processes list )
    conntrack               ( show more with -n LINENUM )
    vnstat                  ( network traffic monitor )
    pb                      ( command line pastebin - man pb )

    speedtest / speedtest-ovh / speedtest-belwue

# server logs:
    journalctl -efx
    journalctl -efu <service>
-----------------------------------------------------------------
EOM
