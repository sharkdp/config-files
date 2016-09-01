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
    PS1="\[\033[1;31m\]\u\[\033[0m\]@\h (\w) # "
else
    PS1="\[\033[1;34m\]\u\[\033[0m\]@\h (\w) $ "
fi

# enter directories without using 'cd':
shopt -s autocd

# Enable ** globs:
shopt -s globstar

# Save multiline commands in history
shopt -s cmdhist

export EDITOR="/usr/bin/vim"

[ -r ~/.alias ] && . ~/.alias

# update minimal set of config files
update () {
    wget -q --no-check-certificate -O - https://raw.githubusercontent.com/sharkdp/config-files/master/minimal-config/bootstrap | bash
}

