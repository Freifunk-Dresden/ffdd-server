# ~/.bash_aliases: Alias definitions

#
# Custom User Aliases
#

# default 'ls'-alias in .bashrc
# alias ls='ls -lah -F --color=auto'

# create our aliases here:



#
# Freifunk Aliases
#

alias freifunk-call='salt-call state.highstate --local'

alias psa='ps -axuwf'

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

alias showip='printf "IP: %s\n" "$(curl -s ifconfig.me/ip)"'
alias speedtest-ovh='wget -O /dev/null http://213.186.33.6/files/10Gb.dat --report-speed=bits'
alias speedtest-belwue='wget -O /dev/null http://speedtest.belwue.net/10G --report-speed=bits'

cat <<EOM
-----------------------------------------------------
tools:
    freifunk-autoupdate
    freifunk-call ( salt-call state.highstate --local )
    showip
    speedtest-ovh
    speedtest-belwue
-----------------------------------------------------
EOM
