export EDITOR="/usr/bin/vim"

source ~/.alias

if [[ $(whoami) == "root" ]]; then
    PS1="\[\033[1;31m\]\u\[\033[0m\]@\h (\w) # "
else
    PS1="\[\033[1;34m\]\u\[\033[0m\]@\h (\w) $ "
fi

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

rehash () {
    . ~/.bashrc 2> /dev/null
}
