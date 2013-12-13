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

export PATH="${PATH}:/usr/sbin/:/home/shark/.cabal/bin"
export EDITOR="/usr/bin/vim"

include="/etc/profile.d/bash-completion"
include="$include ${HOME}/.alias"

for inc in $include
do
    [ -f $inc ] && source $inc
done

eval `dircolors -b ~/.dir_colors`

PS1="\[\033[1;34m\]\u\[\033[0m\] (\w) $ "

case ${TERM} in
    xterm*|rxvt|Eterm|eterm)
        PS1="${PS1}\[\e]0;\w\a\]"
        ;;
esac

export HISTCONTROL="ignoredups"
export HISTFILESIZE="1000"

shopt -s checkwinsize

export GTK2_RC_FILES=$HOME/.gtkrc-2.0

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

rehash () {
    . ~/.bashrc 2> /dev/null
}

nwlook() {
    avahi-browse -t -a | grep --color=never IPv4
}

remotenwlook() {
    ssh peter@sultan.theo3.physik.uni-stuttgart.de 'avahi-browse -t -a | grep --color=never IPv4 | grep -v mvagusta;avahi-browse -t -a  | grep --color=never IPv4'
}

pdfFontToOutlines() {
    gs -sDEVICE=pswrite -dNOCACHE -sOutputFile=- -q -dbatch -dNOPAUSE -dQUIET "$1" -c quit | ps2pdf - "$2"
}

notify() {
    /home/shark/.nwlook/notify.sh &
}

# removes all those anoying files from LaTeX working directories
cleanLatexFolder() {
    for file in *.aux *.toc *.blg *.bbl *.synctex.gz *.dvi *.fdb_latexmk *.out *.ps *Notes.bib *.log; do
       if [ -e "$file" ]; then
            echo -n "Delete '$file' [y]: "
            read answ
            if [ x"$answ" == x"y" ] || [ x"$answ" == x"" ]; then
                rm "$file"
            fi
        fi
    done
}

# prevent Ctrl-S from freezing the terminal to use the shortcut in vim
bind -r '\C-s'
stty -ixon

# the only real way to use gnuplot is via killall
gp() {
    killall gnuplot 2> /dev/null
    gnuplot -persist < "$1"
}

# call with 'trigger <cmd> <file1> <file2>'
#
# This will run the command 'cmd' every time one
# of the files is changed
#
# In the command string, #1, #2, can be used as a
# synonym for file1, file2, ..
#
# Example: trigger 'python #1' run.py config.py
#
trigger() {
    cmd="$1"
    cmd="${cmd//#1/$2}"
    cmd="${cmd//#2/$3}"
    cmd="${cmd//#3/$4}"
    cmd="${cmd//#4/$5}"
    cmd="${cmd//#5/$6}"

    echo -e "$red>>>$reset Initial run of '$cmd'"
    eval "$cmd"
    echo

    while cfile="`inotifywait -q --format '%w' -e close_write ${*:2}`"; do
        echo -e "$red>>>$reset File '$cfile' has been changed"
        eval "$cmd"
        echo
    done
}
