export reset='\x1b[0m'
export blue='\x1b[34;01m'
export turquoise='\x1b[36;01m'
export darkgreen='\x1b[32;06m'
export bold='\x1b[01m'
export brown='\x1b[33;06m'
export purple='\x1b[35;06m'
export fuscia='\x1b[35;01m'
export yellow='\x1b[33;01m'
export darkblue='\x1b[34;06m'
export green='\x1b[32;01m'
export darkred='\x1b[31;06m'
export teal='\x1b[36;06m'
export red='\x1b[31;01m'

export EDITOR="/usr/bin/vim"

source ~/.alias

PS1="\[\033[1;34m\]\u\[\033[0m\] (\w) $ "

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

rehash () {
    . ~/.bashrc 2> /dev/null
}
