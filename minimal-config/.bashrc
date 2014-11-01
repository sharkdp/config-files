export HISTCONTROL="ignoredups"
export HISTFILESIZE="1000"

shopt -s checkwinsize

# reload .bashrc
rehash () {
    . ~/.bashrc 2> /dev/null
}

# prevent Ctrl-S from freezing the terminal to use the shortcut in vim
bind -r '\C-s'
stty -ixon

if [[ $(whoami) == "root" ]]; then
    PS1="\[\033[1;31m\]\u\[\033[0m\]@\h (\w) # "
else
    PS1="\[\033[1;34m\]\u\[\033[0m\]@\h (\w) $ "
fi

# bash completion on Arch
[ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion

# and on Ubuntu
[ -r /etc/bash_completion   ] && . /etc/bash_completion

export EDITOR="/usr/bin/vim"

source ~/.alias