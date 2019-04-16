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

alias freifunk-version='cat /etc/freifunk-server-version'
alias freifunk-call='salt-call state.highstate --local'
alias freifunk-gw-status='/usr/local/bin/freifunk-gateway-status.sh'

alias f2b-list='/sbin/ipset list blacklist_fail2ban'

alias psa='ps -axuwf'
alias conntrack='tail /var/log/conntrack.log'

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

alias showip='printf "IP: %s\n" "$(curl -sL whois.envs.net)"'
alias speedtest-ovh='wget -O /dev/null http://213.186.33.6/files/10Gb.dat --report-speed=bits'
alias speedtest-belwue='wget -O /dev/null http://speedtest.belwue.net/10G --report-speed=bits'

cat <<EOM
-----------------------------------------------------
tools:
	freifunk-version	( show Server Version and Branch )
    freifunk-call	( salt-call state.highstate --local )
    freifunk-gw-status	( show GW-Country )
    f2b-list		( show blocked IP's )
    f2b-unban <IP>	( unban blocked IP )
    showip
    speedtest-ovh
    speedtest-belwue
-----------------------------------------------------
EOM
