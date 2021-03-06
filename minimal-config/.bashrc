export HISTCONTROL="ignoredups"
export HISTFILESIZE="10000"

shopt -s checkwinsize

# reload .bashrc
rehash () {
    . ~/.bashrc 2> /dev/null
}

# prevent Ctrl-S from freezing the terminal to use the shortcut in vim.
# only in interactive shells
if [[ -n "$PS1" ]]; then
    bind -r '\C-s'
    stty -ixon
fi

# bash completion on Arch
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# and on Ubuntu
[ -r /etc/bash_completion ] && . /etc/bash_completion

# Simple bash prompt
if [[ $(whoami) == "root" ]]; then
    PS1="\[\033[1;31m\]\u\[\033[0m\] \[\033[1;37m\]at\[\033[m\] \[\033[1;36m\]\h\[\033[m\] \[\033[1;37m\]in\[\033[m\] \[\033[1;32m\]\w\[\033[m\]\n\[\033[1;31m\]#\[\033[m\] "
else
    PS1="\[\033[1;34m\]\u\[\033[0m\] \[\033[1;37m\]at\[\033[m\] \[\033[1;36m\]\h\[\033[m\] \[\033[1;37m\]in\[\033[m\] \[\033[1;32m\]\w\[\033[m\]\n\[\033[1;37m\]$\[\033[m\] "
fi

# enter directories without using 'cd':
shopt -s autocd

# Enable ** globs:
shopt -s globstar

# Save multiline commands in history
shopt -s cmdhist

export EDITOR="/usr/bin/vim"

[ -r ~/.alias ] && . ~/.alias

# A 'polyfill' for ag, if it does not exist
if ! hash ag 2> /dev/null; then
    unalias ag
    function ag () {
        grep --color -E -r "$1" .
    }
fi

# update minimal set of config files
update () {
    wget -q --no-check-certificate -O - https://raw.githubusercontent.com/sharkdp/config-files/master/minimal-config/bootstrap | bash
}

